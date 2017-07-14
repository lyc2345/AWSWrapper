//
//  DynamoSyncTests.m
//  AWSWrapper
//
//  Created by Stan Liu on 03/07/2017.
//  Copyright © 2017 lyc2345. All rights reserved.
//

#import <XCTest/XCTest.h>
@import Specta;
@import AWSWrapper;

@interface DSTests2 : XCTestCase <DynamoSyncDelegate>

@property BookmarkManager *bookmarkManager;
@property LoginManager *loginManager;
@property DynamoSync *dsync;
@property NSString *userId;
@property NSString *tableName;
@property NSDictionary *shadow;
@property NSDictionary *initailRemoteData;
@property NSDictionary *client;
@property NSString *remoteHash;
@property NSString *commitId;
@property XCTestExpectation *expection;
@property (nonatomic) dispatch_group_t requestGroup;
@property (nonatomic) dispatch_group_t dispatchGroup;

@end

@implementation DSTests2

- (void)setUp {
    [super setUp];

  _tableName = @"Bookmark";
  
  _loginManager = [LoginManager shared];
  _userId = _loginManager.awsIdentityId;
  _bookmarkManager = [[BookmarkManager alloc] init];
  _dsync = [[DynamoSync alloc] init];
  _dsync.delegate = self;

  self.dispatchGroup = dispatch_group_create();
  self.requestGroup = dispatch_group_create();
}

-(void)tearDown {
  [self waitForGroup];
  [super tearDown];
}

-(void)dynamoPushSuccessWithType:(RecordType)type data:(NSDictionary *)data newCommitId:(NSString *)commitId {
  
  _shadow = data[@"_dicts"];
  _commitId = commitId;
}

-(void)dynamoPullFailureWithType:(RecordType)type error:(NSError *)error {
  
}

-(void)performBlock:(void(^)())block {
  
  block();
}

- (void)performGroupedBlock:(dispatch_block_t)block {
  
  dispatch_group_enter(self.dispatchGroup);
  [self performBlock:^{
    block();
  }];
}

-(void)testAll {
  
  [NSThread sleepForTimeInterval: 3.0];
  [self performGroupedBlock:^{
    [self dynamoSync];
    [NSThread sleepForTimeInterval: 1.0];
  }];
  
  [self performGroupedBlock:^{
    [NSThread sleepForTimeInterval: 1.0];
    [self s1p1];
  }];
  
  [self performGroupedBlock:^{
    [NSThread sleepForTimeInterval: 1.0];
    [self s1p2];
  }];
  
  [self performGroupedBlock:^{
    [NSThread sleepForTimeInterval: 1.0];
    [self s2p1];
  }];
  
  [self performGroupedBlock:^{
    [NSThread sleepForTimeInterval: 1.0];
    [self s1p3];
  }];
  
  [self performGroupedBlock:^{
    [NSThread sleepForTimeInterval: 1.0];
    [self finalLoadCheck];
  }];
}

- (void)waitForGroup {
  
  __block BOOL didComplete = NO;
  dispatch_group_notify(self.requestGroup, dispatch_get_main_queue(), ^{
    didComplete = YES;
  });
  while (! didComplete) {
    NSTimeInterval const interval = 0.002;
    if (! [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:interval]]) {
      [NSThread sleepForTimeInterval:interval];
    }
  }
}

-(void)dynamoSync {
  
  self.expection = [self expectationWithDescription: @"Remote Initial"];
  NSDictionary *initData = @{@"_dicts": @{
                             @"A": @{@"author": @"A", @"url": @"A"},
                             @"B": @{@"author": @"B", @"url": @"B"}
                             }
                         };
  _client = initData;
  [_bookmarkManager forcePushWithType: RecordTypeBookmark record: _client userId: _userId completion:^(NSError *error, NSString *commitId, NSString *remoteHash) {
    
    XCTAssertNil(error);
    XCTAssertNotNil(commitId);
    XCTAssertNotNil(remoteHash);
    _shadow = initData[@"_dicts"];
    _commitId = commitId;
    _remoteHash = remoteHash;
    [self.expection fulfill];
  }];
  
  [self waitForExpectationsWithTimeout: 5.0 handler:^(NSError * _Nullable error) {
    if (error) {
      XCTFail(@"expectation failed with error: %@", error);
    }
  }];
}

-(void)s1p1 {

  self.expection = [self expectationWithDescription: @"S1P1"];
  NSDictionary *clientS1P1 = @{@"_commitId": _commitId,
                           @"_remoteHash": _remoteHash,
                           @"_dicts": @{
                               @"A": @{@"author": @"A", @"url": @"A"},
                               @"B": @{@"author": @"B", @"url": @"B"},
                               @"C": @{@"author": @"C", @"url": @"C"},
                               @"D": @{@"author": @"D", @"url": @"D"},
                               @"E": @{@"author": @"E", @"url": @"E"}
                               }
                           };
  NSDictionary *expectShadowS1P1 = @{
                           @"A": @{@"author": @"A", @"url": @"A"},
                           @"B": @{@"author": @"B", @"url": @"B"}
                           };
  
  _client = clientS1P1;
  NSDictionary *expectDiff = [DSWrapper diffWins: clientS1P1[@"_dicts"] loses: expectShadowS1P1];
  XCTAssertTrue([expectShadowS1P1 isEqualToDictionary: _shadow]);
  
  [_dsync syncWithUserId: _userId tableName: _tableName dictionary: _client shadow: _shadow shouldReplace:^BOOL(id oldValue, id newValue) {
    return YES;
  } completion:^(NSDictionary *diff, NSError *error) {
    
    XCTAssertTrue([diff isEqualToDictionary: expectDiff]);
    [self.expection fulfill];
  }];

  [self waitForExpectationsWithTimeout: 8.0 handler:^(NSError * _Nullable error) {
    XCTAssertTrue([_shadow isEqualToDictionary: clientS1P1[@"_dicts"]]);
    if (error) {
      XCTFail(@"expectation failed with error: %@", error);
    }
  }];
}

-(void)s1p2 {

  self.expection = [self expectationWithDescription: @"S1P2"];
  // commitId passes, remoteHash passed.
  NSDictionary *clientS1P2 = @{@"_commitId": _commitId,
                           @"_remoteHash": _remoteHash,
                           @"_dicts": @{
                               @"B": @{@"author": @"B", @"url": @"B"},
                               @"C": @{@"author": @"C", @"url": @"C"},
                               @"E": @{@"author": @"E", @"url": @"E"},
                               @"F": @{@"author": @"F", @"url": @"F"}
                               }
                           };
  NSDictionary *shadowS1P2 = @{
                           @"A": @{@"author": @"A", @"url": @"A"},
                           @"B": @{@"author": @"B", @"url": @"B"},
                           @"C": @{@"author": @"C", @"url": @"C"},
                           @"D": @{@"author": @"D", @"url": @"D"},
                           @"E": @{@"author": @"E", @"url": @"E"}
                           };
  /*
  NSDictionary *remote = @{
                           @"A": @{@"author": @"A", @"url": @"A"},
                           @"B": @{@"author": @"B", @"url": @"B"},
                           @"C": @{@"author": @"C", @"url": @"C"},
                           @"D": @{@"author": @"D", @"url": @"D"},
                           @"E": @{@"author": @"E", @"url": @"E"}
                           };
   */
  
  _client = clientS1P2;
  XCTAssertTrue([shadowS1P2 isEqualToDictionary: _shadow]);
  
  [_dsync syncWithUserId: _userId tableName: _tableName dictionary: _client shadow: _shadow shouldReplace:^BOOL(id oldValue, id newValue) {
    return YES;
  } completion:^(NSDictionary *diff, NSError *error) {
    
    
    NSDictionary *newClient = [DSWrapper mergeInto: clientS1P2[@"_dicts"] applyDiff: diff];
    
    NSDictionary *comparison = @{
                                 @"B": @{@"author": @"B", @"url": @"B"},
                                 @"C": @{@"author": @"C", @"url": @"C"},
                                 @"E": @{@"author": @"E", @"url": @"E"},
                                 @"F": @{@"author": @"F", @"url": @"F"}
                                 };
    
    XCTAssertTrue([newClient isEqualToDictionary: comparison]);
    [self.expection fulfill];
  }];
  
  [self waitForExpectationsWithTimeout: 8.0 handler:^(NSError * _Nullable error) {
    XCTAssertTrue([_shadow isEqualToDictionary: clientS1P2[@"_dicts"]]);
    if (error) {
      XCTFail(@"expectation failed with error: %@", error);
    }
  }];
}

-(void)s2p1 {
  
  self.expection = [self expectationWithDescription: @"S2P1"];
  NSDictionary *clientS2P1 =@{
                              @"_commitId": @"123213123123123",
                              @"_remoteHash": _remoteHash,
                              @"_dicts": @{
                                  @"B": @{@"author": @"B", @"url": @"B"},
                                  @"C": @{@"author": @"C", @"url": @"C"},
                                  @"D": @{@"author": @"D", @"url": @"D"},
                                  @"E": @{@"author": @"E", @"url": @"E"},
                                  @"G": @{@"author": @"G", @"url": @"G"}
                                  }
                              };
  NSDictionary *shadowS2P1 = @{
                           @"A": @{@"author": @"A", @"url": @"A"},
                           @"B": @{@"author": @"B", @"url": @"B"},
                           @"C": @{@"author": @"C", @"url": @"C"},
                           @"D": @{@"author": @"D", @"url": @"D"},
                           @"E": @{@"author": @"E", @"url": @"E"}
                           };
  /*
  NSDictionary *remote = @{
                           @"B": @{@"author": @"B", @"url": @"B"},
                           @"C": @{@"author": @"C", @"url": @"C"},
                           @"E": @{@"author": @"E", @"url": @"E"},
                           @"F": @{@"author": @"F", @"url": @"F"}
                           };
   */
  _client = clientS2P1;
  _shadow = shadowS2P1;
  XCTAssertTrue([shadowS2P1 isEqualToDictionary: _shadow]);
  
  [_dsync syncWithUserId: _userId tableName: _tableName dictionary: _client shadow: _shadow shouldReplace:^BOOL(id oldValue, id newValue) {
    
    return YES;
  } completion:^(NSDictionary *diff, NSError *error) {
    
    [self.expection fulfill];
  }];

  [self waitForExpectationsWithTimeout: 8.0 handler:^(NSError * _Nullable error) {
    NSDictionary *comparison = @{
                                 @"B": @{@"author": @"B", @"url": @"B"},
                                 @"C": @{@"author": @"C", @"url": @"C"},
                                 @"E": @{@"author": @"E", @"url": @"E"},
                                 @"F": @{@"author": @"F", @"url": @"F"},
                                 @"G": @{@"author": @"G", @"url": @"G"}
                                 };
    
    XCTAssertTrue([_shadow isEqualToDictionary: comparison]);
    if (error) {
      XCTFail(@"expectation failed with error: %@", error);
    }
  }];
}

-(void)s1p3 {
  
  self.expection = [self expectationWithDescription: @"S1P3"];
  // commitId passes, remoteHash passed.
  NSDictionary *clientS1P3 = @{
                               @"_commitId": @"12312321321ddd312321",
                               @"_remoteHash": _remoteHash,
                               @"_dicts": @{
                                   @"A": @{@"author": @"A", @"url": @"A"},
                                   @"B": @{@"author": @"B", @"url": @"B1"},
                                   @"E": @{@"author": @"E", @"url": @"E"},
                                   @"F": @{@"author": @"F", @"url": @"F1"}
                                   }
                               };
  NSDictionary *shadowS1P3 = @{
                           @"B": @{@"author": @"B", @"url": @"B"},
                           @"C": @{@"author": @"C", @"url": @"C"},
                           @"E": @{@"author": @"E", @"url": @"E"},
                           @"F": @{@"author": @"F", @"url": @"F"}
                           };
  /*
  NSDictionary *remote = @{
                           @"B": @{@"author": @"B", @"url": @"B"},
                           @"C": @{@"author": @"C", @"url": @"C"},
                           @"E": @{@"author": @"E", @"url": @"E"},
                           @"F": @{@"author": @"F", @"url": @"F"},
                           @"G": @{@"author": @"G", @"url": @"G"}
                           };
   */
  _client = clientS1P3;
  _shadow = shadowS1P3;
  NSDictionary *expect2Diff = [DSWrapper diffWins: _client[@"_dicts"] loses: _shadow];
  
  [_dsync syncWithUserId: _userId tableName: _tableName dictionary: _client shadow: _shadow shouldReplace:^BOOL(id oldValue, id newValue) {
    
    return YES;
  } completion:^(NSDictionary *diff, NSError *error) {
    [self.expection fulfill];
  }];

  [self waitForExpectationsWithTimeout: 15.0 handler:^(NSError * _Nullable error) {
    NSDictionary *comparison = @{
                                 @"A": @{@"author": @"A", @"url": @"A"},
                                 @"B": @{@"author": @"B", @"url": @"B1"},
                                 @"E": @{@"author": @"E", @"url": @"E"},
                                 @"F": @{@"author": @"F", @"url": @"F1"},
                                 @"G": @{@"author": @"G", @"url": @"G"}
                                 };
    XCTAssertTrue([_shadow isEqualToDictionary: comparison]);
    if (error) {
      XCTFail(@"expectation failed with error: %@", error);
    }
  }];
}

-(void)finalLoadCheck {
  
  self.expection = [self expectationWithDescription: @"finalLoadCheck"];
  
  [_bookmarkManager pullType: RecordTypeBookmark user: _userId completion:^(NSDictionary *item, NSError *error) {
    
    NSDictionary *comparison = @{
                                 @"A": @{@"author": @"A", @"url": @"A"},
                                 @"B": @{@"author": @"B", @"url": @"B1"},
                                 @"E": @{@"author": @"E", @"url": @"E"},
                                 @"F": @{@"author": @"F", @"url": @"F1"},
                                 @"G": @{@"author": @"G", @"url": @"G"}
                                 };
    XCTAssertTrue([item[@"_dicts"] isEqualToDictionary: comparison]);
    
    [self.expection fulfill];
  }];

  [self waitForExpectationsWithTimeout: 5.0 handler:^(NSError * _Nullable error) {
    if (error) {
      XCTFail(@"expectation failed with error: %@", error);
    }
  }];
}

@end
