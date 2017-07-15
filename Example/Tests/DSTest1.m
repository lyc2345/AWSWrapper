//
//  DSTest1.m
//  AWSWrapper
//
//  Created by Stan Liu on 14/07/2017.
//  Copyright © 2017 lyc2345. All rights reserved.
//

#import <XCTest/XCTest.h>
@import AWSWrapper;
#import "TestCase.h"

@interface DSTest1 : XCTestCase

@property (nonatomic) TestCase *testcase;
@property (nonatomic) dispatch_group_t requestGroup;
@property (nonatomic) dispatch_group_t dispatchGroup;

@end

@implementation DSTest1

- (void)setUp {
  [super setUp];
  
  _testcase = [TestCase new];
  _dispatchGroup = dispatch_group_create();
  _requestGroup = dispatch_group_create();
}

- (void)tearDown {
  
  _dispatchGroup =  nil;
  _requestGroup = nil;
  
  [self waitForGroup];
  [super tearDown];
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

- (void)waitForGroup {
  
  __block BOOL didComplete = NO;
  
  if (!_requestGroup) {
    _requestGroup = dispatch_group_create();
  }
  if (!_dispatchGroup) {
    _dispatchGroup = dispatch_group_create();
  }
  
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

- (void)testAll {
  
  [NSThread sleepForTimeInterval: 3.0];
  [self performGroupedBlock:^{
    [_testcase initial: @{
                          @"A": @{@"author": @"A", @"url": @"A"},
                          @"B": @{@"author": @"B", @"url": @"B"}
                          }
            exeHandler:^(NSString *commitId, NSString *remoteHash, NSDictionary *shadow, NSError *error) {
              
              XCTAssertNil(error);
              XCTAssertNotNil(commitId);
              XCTAssertNotNil(remoteHash);
              
            } completion:^(NSError *error) {
              
              if (error) {
                XCTFail(@"expectation failed with error: %@", error);
              }
              
            }];
    [NSThread sleepForTimeInterval: 1.0];
  }];
  
  [self performGroupedBlock:^{
    [NSThread sleepForTimeInterval: 1.0];
    NSDictionary *expectShadow = @{
                                   @"A": @{@"author": @"A", @"url": @"A"},
                                   @"B": @{@"author": @"B", @"url": @"B"}
                                   };
    NSDictionary *client = @{
                             @"A": @{@"author": @"A", @"url": @"A"},
                             @"B": @{@"author": @"B", @"url": @"B"},
                             @"C": @{@"author": @"C", @"url": @"C"},
                             @"D": @{@"author": @"D", @"url": @"D"},
                             @"E": @{@"author": @"E", @"url": @"E"}
                             };
    [_testcase examineSpec: @"S1P1"
                  commitId: nil
                remoteHash: nil
                clientDict: client
              expectShadow: nil
            examineHandler:^(NSDictionary *shadow) {
              
              XCTAssertTrue([expectShadow isEqualToDictionary: shadow]);
              
            } shouldReplace:^BOOL(id oldValue, id newValue) {
              
              return YES;
              
            } exeHandler:^(NSDictionary *diff, NSError *error) {
              
              if (error) {
                XCTFail(@"expectation failed with error: %@", error);
              }
              
            } completion:^(NSDictionary *newShadow, NSError *error) {
              
              NSDictionary *expectRemote = @{
                                             @"A": @{@"author": @"A", @"url": @"A"},
                                             @"B": @{@"author": @"B", @"url": @"B"},
                                             @"C": @{@"author": @"C", @"url": @"C"},
                                             @"D": @{@"author": @"D", @"url": @"D"},
                                             @"E": @{@"author": @"E", @"url": @"E"}
                                             };
              XCTAssertTrue([newShadow isEqualToDictionary: expectRemote]);
              
              if (error) {
                XCTFail(@"expectation failed with error: %@", error);
              }
            }];
  }];
  
  [self performGroupedBlock:^{
    [NSThread sleepForTimeInterval: 1.0];
    NSDictionary *expectShadow = @{
                                   @"A": @{@"author": @"A", @"url": @"A"},
                                   @"B": @{@"author": @"B", @"url": @"B"},
                                   @"C": @{@"author": @"C", @"url": @"C"},
                                   @"D": @{@"author": @"D", @"url": @"D"},
                                   @"E": @{@"author": @"E", @"url": @"E"}
                                   };
    NSDictionary *client = @{
                             @"B": @{@"author": @"B", @"url": @"B"},
                             @"C": @{@"author": @"C", @"url": @"C"},
                             @"E": @{@"author": @"E", @"url": @"E"},
                             @"F": @{@"author": @"F", @"url": @"F"}
                             };
    [_testcase examineSpec: @"S1P2"
                  commitId: nil
                remoteHash: nil
                clientDict: client
              expectShadow: nil
            examineHandler:^(NSDictionary *shadow) {
              
              XCTAssertTrue([expectShadow isEqualToDictionary: shadow]);
              
            } shouldReplace:^BOOL(id oldValue, id newValue) {
              
              return YES;
              
            } exeHandler:^(NSDictionary *diff, NSError *error) {
              
              if (error) {
                XCTFail(@"expectation failed with error: %@", error);
              }
              
            } completion:^(NSDictionary *newShadow, NSError *error) {
              
              NSDictionary *expectRemote = @{
                                             @"B": @{@"author": @"B", @"url": @"B"},
                                             @"C": @{@"author": @"C", @"url": @"C"},
                                             @"E": @{@"author": @"E", @"url": @"E"},
                                             @"F": @{@"author": @"F", @"url": @"F"}
                                             };
              XCTAssertTrue([newShadow isEqualToDictionary: expectRemote]);
              
              if (error) {
                XCTFail(@"expectation failed with error: %@", error);
              }
            }];
  }];
  
  [self performGroupedBlock:^{
    [NSThread sleepForTimeInterval: 1.0];
    NSDictionary *expectShadow = @{
                                   @"A": @{@"author": @"A", @"url": @"A"},
                                   @"B": @{@"author": @"B", @"url": @"B"},
                                   @"C": @{@"author": @"C", @"url": @"C"},
                                   @"D": @{@"author": @"D", @"url": @"D"},
                                   @"E": @{@"author": @"E", @"url": @"E"}
                                   };
    NSDictionary *client = @{
                             @"B": @{@"author": @"B", @"url": @"B"},
                             @"C": @{@"author": @"C", @"url": @"C"},
                             @"D": @{@"author": @"D", @"url": @"D"},
                             @"E": @{@"author": @"E", @"url": @"E"},
                             @"G": @{@"author": @"G", @"url": @"G"}
                             };
    NSDictionary *expectRemote = @{
                                   @"B": @{@"author": @"B", @"url": @"B"},
                                   @"C": @{@"author": @"C", @"url": @"C"},
                                   @"E": @{@"author": @"E", @"url": @"E"},
                                   @"F": @{@"author": @"F", @"url": @"F"}
                                   };
    NSDictionary *diff_cilent_shadow = [DSWrapper diffWins: client loses: expectShadow];
    NSDictionary *need_to_apply_to_client = [DSWrapper diffWins: expectRemote loses: client];
    NSDictionary *newClient = [DSWrapper mergeInto: client applyDiff: need_to_apply_to_client];
    newClient = [DSWrapper mergeInto: newClient
                           applyDiff: diff_cilent_shadow
                          primaryKey: @"comicName"
                       shouldReplace:^BOOL(id oldValue, id newValue) {
      return YES;
    }];
    NSDictionary *need_to_apply_to_remote = [DSWrapper diffWins: newClient loses: expectRemote];
    
    [_testcase examineSpec: @"S2P1"
                  commitId: @"123123gfdg213123gdgd2112312312312"
                remoteHash: nil
                clientDict: client
              expectShadow: expectShadow
            examineHandler:^(NSDictionary *shadow) {
              
              XCTAssertFalse([expectShadow isEqualToDictionary: shadow]);
              
            } shouldReplace:^BOOL(id oldValue, id newValue) {
              
              return YES;
              
            } exeHandler:^(NSDictionary *diff, NSError *error) {
              
              XCTAssertTrue([diff isEqualToDictionary: need_to_apply_to_remote]);
              
              if (error) {
                XCTFail(@"expectation failed with error: %@", error);
              }
              
            } completion:^(NSDictionary *newShadow, NSError *error) {
              
              NSDictionary *expectRemote = @{
                                             @"B": @{@"author": @"B", @"url": @"B"},
                                             @"C": @{@"author": @"C", @"url": @"C"},
                                             @"E": @{@"author": @"E", @"url": @"E"},
                                             @"F": @{@"author": @"F", @"url": @"F"},
                                             @"G": @{@"author": @"G", @"url": @"G"}
                                             };
              XCTAssertTrue([newShadow isEqualToDictionary: expectRemote]);
              
              if (error) {
                XCTFail(@"expectation failed with error: %@", error);
              }
            }];
  }];
  
  [self performGroupedBlock:^{
    [NSThread sleepForTimeInterval: 1.0];
    NSDictionary *expectShadow = @{
                                   @"B": @{@"author": @"B", @"url": @"B"},
                                   @"C": @{@"author": @"C", @"url": @"C"},
                                   @"E": @{@"author": @"E", @"url": @"E"},
                                   @"F": @{@"author": @"F", @"url": @"F"}
                                   };
    NSDictionary *client = @{
                             @"A": @{@"author": @"A", @"url": @"A"},
                             @"B": @{@"author": @"B", @"url": @"B1"},
                             @"E": @{@"author": @"E", @"url": @"E"},
                             @"F": @{@"author": @"F", @"url": @"F1"}
                             };
    [_testcase examineSpec: @"S1P3"
                  commitId: @"1231435323213123gdfgdf2112312312312"
                remoteHash: nil
                clientDict: client
              expectShadow: expectShadow
            examineHandler:^(NSDictionary *shadow) {
              
              XCTAssertFalse([expectShadow isEqualToDictionary: shadow]);
              
            } shouldReplace:^BOOL(id oldValue, id newValue) {
              
              return YES;
              
            } exeHandler:^(NSDictionary *diff, NSError *error) {
              
              if (error) {
                XCTFail(@"expectation failed with error: %@", error);
              }
              
            } completion:^(NSDictionary *newShadow, NSError *error) {
              
              NSDictionary *expectRemote = @{
                                             @"A": @{@"author": @"A", @"url": @"A"},
                                             @"B": @{@"author": @"B", @"url": @"B1"},
                                             @"E": @{@"author": @"E", @"url": @"E"},
                                             @"F": @{@"author": @"F", @"url": @"F1"},
                                             @"G": @{@"author": @"G", @"url": @"G"}
                                             };
              XCTAssertTrue([newShadow isEqualToDictionary: expectRemote]);
              
              if (error) {
                XCTFail(@"expectation failed with error: %@", error);
              }
            }];
  }];
  
  [self performGroupedBlock:^{
    [NSThread sleepForTimeInterval: 1.0];
    [_testcase finalCheck: @{
                             @"A": @{@"author": @"A", @"url": @"A"},
                             @"B": @{@"author": @"B", @"url": @"B1"},
                             @"E": @{@"author": @"E", @"url": @"E"},
                             @"F": @{@"author": @"F", @"url": @"F1"},
                             @"G": @{@"author": @"G", @"url": @"G"}
                             }
               exeHandler:^(BOOL isSame) {
                 
                 XCTAssertTrue(isSame);
               } completion:^(NSError *error) {
                 
                 if (error) {
                   XCTFail(@"expectation failed with error: %@", error);
                 }
               }];
  }];
}

@end
