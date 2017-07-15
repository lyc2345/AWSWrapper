//
//  AWSWrapperTests.m
//  AWSWrapperTests
//
//  Created by lyc2345 on 06/02/2017.
//  Copyright (c) 2017 lyc2345. All rights reserved.
//

// https://github.com/Specta/Specta


#import "TestCase.h"
@import AWSWrapper;

@interface TestCase () <DynamoSyncDelegate>

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

@end

@implementation TestCase

- (instancetype)init
{
  self = [super init];
  if (self) {
    
    _tableName = @"Bookmark";
    
    _loginManager = [LoginManager shared];
    _userId = _loginManager.awsIdentityId;
    _bookmarkManager = [[BookmarkManager alloc] init];
    _dsync = [[DynamoSync alloc] init];
    _dsync.delegate = self;
    
  }
  return self;
}

// MARK: SyncDelegate
-(void)dynamoPushSuccessWithType:(RecordType)type
                            data:(NSDictionary *)data
                     newCommitId:(NSString *)commitId {
  
  _shadow = data[@"_dicts"];
  _commitId = commitId;
}

-(id)emptyShadowIsBookmark:(BOOL)isBookmark {
  
  _shadow = nil;
  return _shadow;
}

-(void)initial:(NSDictionary *)dict
    exeHandler:(void(^)(NSString *commitId, NSString *remoteHash, NSDictionary *shadow, NSError *error))exeHandler
    completion:(void(^)(NSError *error))completion {
  
  self.expection = [self expectationWithDescription: @"Remote Initial"];
  _client = dict;
  [_bookmarkManager forcePushWithType: RecordTypeBookmark record: _client userId: _userId completion:^(NSError *error, NSString *commitId, NSString *remoteHash) {
    
    if (!error) {
      _shadow = dict;
      _commitId = commitId;
      _remoteHash = remoteHash;
    }
    exeHandler(commitId, remoteHash, _shadow, error);
    [self.expection fulfill];
  }];
  
  [self waitForExpectationsWithTimeout: 5.0 handler:^(NSError * _Nullable error) {
    
    completion(error);
  }];
}

-(void)examineSpec:(NSString *)spec
          commitId:(NSString *)commitId
        remoteHash:(NSString *)remoteHash
        clientDict:(NSDictionary *)dict
      expectShadow:(NSDictionary *)expectShadow
    examineHandler:(void(^)(NSDictionary *shadow))examineHandler
     shouldReplace:(BOOL(^)(id oldValue, id newValue))shouldReplace
        exeHandler:(void(^)(NSDictionary *diff, NSError *error))exeHandler
        completion:(void(^)(NSDictionary *newShadow, NSError *error))completion {
  
  self.expection = [self expectationWithDescription: spec];
  NSDictionary *client = @{@"_commitId": commitId == nil ? _commitId : commitId,
                           @"_remoteHash": remoteHash == nil ? _remoteHash : remoteHash,
                           @"_dicts": dict
                           };
  
  examineHandler(_shadow);
  
  [_dsync syncWithUserId: _userId
               tableName: _tableName
              dictionary: client
                  shadow: expectShadow == nil ? _shadow : expectShadow
           shouldReplace: shouldReplace
              completion:^(NSDictionary *diff, NSError *error) {
                
                exeHandler(diff, error);
                [self.expection fulfill];
              }];
  
  [self waitForExpectationsWithTimeout: 8.0 handler:^(NSError * _Nullable error) {
    
    completion(_shadow, error);
  }];
}

-(void)finalCheck:(NSDictionary *)expectRemote
       exeHandler:(void(^)(BOOL isSame))exeHandler
       completion:(void(^)(NSError *error))completion {
  
  self.expection = [self expectationWithDescription: @"finalLoadCheck"];
  
  [_bookmarkManager pullType: RecordTypeBookmark user: _userId completion:^(NSDictionary *item, NSError *error) {
    
    exeHandler([item[@"_dicts"] isEqualToDictionary: expectRemote]);
    
    [self.expection fulfill];
  }];
  
  [self waitForExpectationsWithTimeout: 5.0 handler:^(NSError * _Nullable error) {
    
    completion(error);
  }];
}

@end
