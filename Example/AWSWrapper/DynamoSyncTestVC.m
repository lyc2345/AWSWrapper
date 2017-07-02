//
//  DynamoSyncTest.m
//  AWSWrapper
//
//  Created by Stan Liu on 01/07/2017.
//  Copyright © 2017 lyc2345. All rights reserved.
//

#import "DynamoSyncTestVC.h"
@import AWSWrapper;

@interface BookmarkManager (Testing)

-(void)forcePushWithType:(RecordType)type record:(NSDictionary *)record userId:(NSString *)userId completion:(void(^)(NSDictionary *item, NSError *error, NSString *commitId))completion;

@end

@interface DynamoSyncTestVC () <DynamoSyncDelegate>

@property BookmarkManager *bookmarkManager;
@property LoginManager *loginManager;
@property DynamoSync *dsync;
@property NSString *userId;
@property NSString *tableName;
@property NSDictionary *shadow;
@property NSDictionary *initailRemoteData;

@property NSDictionary *client;

@property NSString *commitId;
@property NSString *remoteHash;

@end

@implementation DynamoSyncTestVC

-(void)viewDidLoad {
  
  [super viewDidLoad];
  
  // 创建并设置信量
  dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
  
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    NSLog(@"setUp");
    [self setUp:^{
      dispatch_semaphore_signal(semaphore);
    }];
  });
  
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    NSLog(@"setUpRemote");
    [self setUpRemote:^{
      dispatch_semaphore_signal(semaphore);
    }];
  });
  
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    NSLog(@"testFirstInitialData");
    [self testFirstInitialData:^{
      dispatch_semaphore_signal(semaphore);
    }];
  });
  
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    NSLog(@"testS1P1");
    [self testS1P1:^{
      dispatch_semaphore_signal(semaphore);
    }];
  });
  
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    NSLog(@"testS1P2");
    [self testS1P2:^{
      dispatch_semaphore_signal(semaphore);
    }];
  });
}

-(void)dynamoPushSuccessWithType:(RecordType)type data:(NSDictionary *)data newCommitId:(NSString *)commitId {
  
  _shadow = data[@"_dicts"];
  _commitId = data[@"_commitId"];
}

-(void)dynamoPullFailureWithType:(RecordType)type error:(NSError *)error {
  
}


-(void)setUp:(void(^)())completion {
  
  _tableName = @"Bookmark";
  _remoteHash = @"8298FB9D-161B-4C0F-9315-9ED63AB5EE0F-41692-00006ABDEFBF27EF";
  
  _loginManager = [LoginManager shared];
  
  completion();
}

-(void)setUpRemote:(void(^)())completion {
  
  _userId = _loginManager.awsIdentityId;
  
  _bookmarkManager = [[BookmarkManager alloc] init];
  _dsync = [[DynamoSync alloc] init];
  _dsync.delegate = self;
  
  
  _initailRemoteData = @{@"_commitId": [Random string],
                         @"_remoteHash": @"123",
                         @"_dicts": @{
                             @"A": @{@"author": @"A", @"url": @"A"},
                             @"B": @{@"author": @"B", @"url": @"B"}
                             }
                         };
  
  _client = _initailRemoteData;
  
  [_bookmarkManager forcePushWithType: RecordTypeBookmark record: _initailRemoteData userId: _userId completion:^(NSDictionary *item, NSError *error, NSString *commitId) {
    
    _shadow = item[@"_dicts"];
    _commitId = commitId;
    completion();
  }];
}


-(void)testFirstInitialData:(void(^)())completion {
  
  [_bookmarkManager pullType: RecordTypeBookmark user: _userId completion:^(NSDictionary *item, NSError *error) {
    
    assert([item[@"_dicts"] isEqualToDictionary: _initailRemoteData[@"_dicts"]] == YES);
    NSLog(@"testFirstInitialData Success");
    _shadow = item[@"_dicts"];
    _commitId = item[@"_commitId"];
    completion();
  }];
}

-(void)testS1P1:(void(^)())completion {
  // commitId passes, remoteHash passed.
  NSDictionary *client = @{@"_commitId": _commitId,
                           @"_remoteHash": _remoteHash,
                           @"_dicts": @{
                                 @"A": @{@"author": @"A", @"url": @"A"},
                                 @"B": @{@"author": @"B", @"url": @"B"},
                                 @"C": @{@"author": @"C", @"url": @"C"},
                                 @"D": @{@"author": @"D", @"url": @"D"},
                                 @"E": @{@"author": @"E", @"url": @"E"}
                                 }
                           };
  
 ;
  NSDictionary *shadow = @{
                           @"A": @{@"author": @"A", @"url": @"A"},
                           @"B": @{@"author": @"B", @"url": @"B"}
                           };
  NSDictionary *remote = @{
                           @"A": @{@"author": @"A", @"url": @"A"},
                           @"B": @{@"author": @"B", @"url": @"B"}
                           };
  assert([shadow isEqualToDictionary: _shadow] == YES);
  
  [_dsync syncWithUserId: _userId tableName: _tableName dictionary: client shadow: _shadow shouldReplace:^BOOL(id oldValue, id newValue) {
    
    return YES;
  } completion:^(NSDictionary *diff, NSError *error) {
    
    [_bookmarkManager pullType: RecordTypeBookmark user: _userId completion:^(NSDictionary *item, NSError *error) {
      
      NSDictionary *comparison = @{
                                    @"A": @{@"author": @"A", @"url": @"A"},
                                    @"B": @{@"author": @"B", @"url": @"B"},
                                    @"C": @{@"author": @"C", @"url": @"C"},
                                    @"D": @{@"author": @"D", @"url": @"D"},
                                    @"E": @{@"author": @"E", @"url": @"E"}
                                    };
      assert([item[@"_dicts"] isEqualToDictionary: _shadow] == YES);
      assert([item[@"_dicts"] isEqualToDictionary: comparison] == YES);
      NSLog(@"testS1P1 Success");
      completion();
    }];
  }];
}


-(void)testS1P2:(void(^)())completion {
  // commitId passes, remoteHash passed.
  NSDictionary *client = @{@"_commitId": _commitId,
                           @"_remoteHash": _remoteHash,
                           @"_dicts": @{
                               @"B": @{@"author": @"B", @"url": @"B"},
                               @"C": @{@"author": @"C", @"url": @"C"},
                               @"E": @{@"author": @"E", @"url": @"E"},
                               @"F": @{@"author": @"F", @"url": @"F"}
                               }
                           };
  NSDictionary *shadow = @{
                           @"A": @{@"author": @"A", @"url": @"A"},
                           @"B": @{@"author": @"B", @"url": @"B"},
                           @"C": @{@"author": @"C", @"url": @"C"},
                           @"D": @{@"author": @"D", @"url": @"D"},
                           @"E": @{@"author": @"E", @"url": @"E"}
                           };
  NSDictionary *remote = @{
                           @"A": @{@"author": @"A", @"url": @"A"},
                           @"B": @{@"author": @"B", @"url": @"B"},
                           @"C": @{@"author": @"C", @"url": @"C"},
                           @"D": @{@"author": @"D", @"url": @"D"},
                           @"E": @{@"author": @"E", @"url": @"E"}
                           };
  
  assert([shadow isEqualToDictionary: _shadow] == YES);

  [_dsync syncWithUserId: _userId tableName: _tableName dictionary: client shadow: _shadow shouldReplace:^BOOL(id oldValue, id newValue) {
    
    return YES;
  } completion:^(NSDictionary *diff, NSError *error) {
    
    [_bookmarkManager pullType: RecordTypeBookmark user: _userId completion:^(NSDictionary *item, NSError *error) {
      
      NSDictionary *comparison = @{
                                   @"B": @{@"author": @"B", @"url": @"B"},
                                   @"C": @{@"author": @"C", @"url": @"C"},
                                   @"E": @{@"author": @"E", @"url": @"E"},
                                   @"F": @{@"author": @"F", @"url": @"F"}
                                   };
      assert([item[@"_dicts"] isEqualToDictionary: _shadow] == YES);
      assert([item[@"_dicts"] isEqualToDictionary: comparison] == YES);
      NSLog(@"testS1P1 Success");
      completion();
    }];
  }];

}


-(void)testS2P1:(void(^)())completion {
  // commitId passes, remoteHash passed.
  NSDictionary *client = @{
                           @"B": @{@"author": @"B", @"url": @"B"},
                           @"C": @{@"author": @"C", @"url": @"C"},
                           @"D": @{@"author": @"D", @"url": @"D"},
                           @"E": @{@"author": @"E", @"url": @"E"},
                           @"G": @{@"author": @"G", @"url": @"G"}
                           };
  NSDictionary *shadow = @{
                           @"A": @{@"author": @"A", @"url": @"A"},
                           @"B": @{@"author": @"B", @"url": @"B"},
                           @"C": @{@"author": @"C", @"url": @"C"},
                           @"D": @{@"author": @"D", @"url": @"D"},
                           @"E": @{@"author": @"E", @"url": @"E"}
                           };
  NSDictionary *remote = @{
                           @"B": @{@"author": @"B", @"url": @"B"},
                           @"C": @{@"author": @"C", @"url": @"C"},
                           @"E": @{@"author": @"E", @"url": @"E"},
                           @"F": @{@"author": @"F", @"url": @"F"}
                           };
  
  assert([shadow isEqualToDictionary: _shadow] == YES);
  
  [_dsync syncWithUserId: _userId tableName: _tableName dictionary: client shadow: _shadow shouldReplace:^BOOL(id oldValue, id newValue) {
    
    return YES;
  } completion:^(NSDictionary *diff, NSError *error) {
    
    [_bookmarkManager pullType: RecordTypeBookmark user: _userId completion:^(NSDictionary *item, NSError *error) {
      
      NSDictionary *comparison = @{
                                   @"B": @{@"author": @"B", @"url": @"B"},
                                   @"C": @{@"author": @"C", @"url": @"C"},
                                   @"E": @{@"author": @"E", @"url": @"E"},
                                   @"F": @{@"author": @"F", @"url": @"F"}
                                   };
      assert([item[@"_dicts"] isEqualToDictionary: _shadow] == YES);
      assert([item[@"_dicts"] isEqualToDictionary: comparison] == YES);
      NSLog(@"testS1P1 Success");
      completion();
    }];
  }];
}



-(void)testS1P3:(void(^)())completion {
  // commitId passes, remoteHash passed.
  NSDictionary *client = @{
                           @"A": @{@"author": @"A", @"url": @"A"},
                           @"B": @{@"author": @"B1", @"url": @"B1"},
                           @"E": @{@"author": @"E", @"url": @"E"},
                           @"F": @{@"author": @"F1", @"url": @"F1"}
                           };
  NSDictionary *shadow = @{
                           @"B": @{@"author": @"B", @"url": @"B"},
                           @"C": @{@"author": @"C", @"url": @"C"},
                           @"E": @{@"author": @"E", @"url": @"E"},
                           @"F": @{@"author": @"F", @"url": @"F"}
                           };
  NSDictionary *remote = @{
                           @"B": @{@"author": @"B", @"url": @"B"},
                           @"C": @{@"author": @"C", @"url": @"C"},
                           @"E": @{@"author": @"E", @"url": @"E"},
                           @"F": @{@"author": @"F", @"url": @"F"},
                           @"G": @{@"author": @"G", @"url": @"G"}
                           };
  
  assert([shadow isEqualToDictionary: _shadow] == YES);
  
  [_dsync syncWithUserId: _userId tableName: _tableName dictionary: client shadow: _shadow shouldReplace:^BOOL(id oldValue, id newValue) {
    
    return YES;
  } completion:^(NSDictionary *diff, NSError *error) {
    
    [_bookmarkManager pullType: RecordTypeBookmark user: _userId completion:^(NSDictionary *item, NSError *error) {
      
      NSDictionary *comparison = @{
                                   @"B": @{@"author": @"B", @"url": @"B"},
                                   @"C": @{@"author": @"C", @"url": @"C"},
                                   @"E": @{@"author": @"E", @"url": @"E"},
                                   @"F": @{@"author": @"F", @"url": @"F"}
                                   };
      assert([item[@"_dicts"] isEqualToDictionary: _shadow] == YES);
      assert([item[@"_dicts"] isEqualToDictionary: comparison] == YES);
      NSLog(@"testS1P1 Success");
      completion();
    }];
  }];
}




/*

 
 */




@end
