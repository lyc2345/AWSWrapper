//
//  AWSWrapperTests.m
//  AWSWrapperTests
//
//  Created by lyc2345 on 06/02/2017.
//  Copyright (c) 2017 lyc2345. All rights reserved.
//

// https://github.com/Specta/Specta


#import "DynamoTestBase.h"
@import AWSWrapper;

@interface DynamoTestBase () <DynamoSyncDelegate>

@property DynamoService *dynamoService;
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

@implementation DynamoTestBase

static RecordType recordType = RecordTypeBookmark;

- (instancetype)init
{
  self = [super init];
  if (self) {
    
    _tableName = @"Bookmark";
    
    _loginManager = [LoginManager shared];
    _userId = _loginManager.awsIdentityId;
    _dynamoService = [[DynamoService alloc] init];
    _dsync = [[DynamoSync alloc] init];
    _dsync.delegate = self;
  }
  return self;
}

// MARK: SyncDelegate
-(void)dynamoPushSuccessWithType:(RecordType)type
                            data:(NSDictionary *)data
                     newCommitId:(NSString *)commitId {
  
  [self saveShadow: data[@"_dicts"] type: type commitId: commitId identityId: nil];
}

-(id)emptyShadowIsBookmark:(BOOL)isBookmark ofIdentity:(NSString *)identity {
  
  [self saveShadow: nil type: recordType commitId: _commitId identityId: nil];
  NSDictionary *s = [self loadShadowType: recordType identity: nil];
  return s;
}

// MARK: For custom test
-(void)saveShadow:(NSDictionary *)dict
             type:(RecordType)type
         commitId:(NSString *)commitId
       identityId:(NSString *)identityId {
  
  _shadow = dict;
  _commitId = commitId;
}

-(NSDictionary *)loadShadowType:(RecordType)type
                       identity:(NSString *)identity {
  
  return _shadow;
}

-(NSString *)identityId {
  
  return self.loginManager.offlineIdentity;
}

-(void)cleanShadow {
  [self saveShadow: @{} type: recordType commitId: @"" identityId: self.identityId];
}

-(void)initial:(NSDictionary *)dict
    exeHandler:(void(^)(NSString *commitId, NSString *remoteHash, NSDictionary *shadow, NSError *error))exeHandler
    completion:(void(^)(NSDictionary *newShadow, NSString *commitId, NSError *error))completion {
  
  self.expection = [self expectationWithDescription: @"Remote Initial"];
  
  _client = @{@"_dicts": dict};
  
  [_dynamoService forcePushWithType: RecordTypeBookmark record: _client userId: _userId completion:^(NSError *error, NSString *commitId, NSString *remoteHash) {
    
    if (!error) {
      //_shadow = dict;
      //_commitId = commitId;
      [self saveShadow: dict type: recordType commitId: commitId identityId: _userId];
      _remoteHash = remoteHash;
    }
    exeHandler(commitId, remoteHash, _shadow, error);
    [self.expection fulfill];
  }];
  
  [self waitForExpectationsWithTimeout: 5.0 handler:^(NSError * _Nullable error) {
    
    //completion(_shadow, error);
    NSDictionary *s = [self loadShadowType: recordType identity: _userId];
    completion(s, _commitId, error);
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
        completion:(void(^)(NSDictionary *newShadow, NSString *commitId, NSError *error))completion {
  
  self.expection = [self expectationWithDescription: spec];
  
  self.loginManager = [LoginManager shared];
  
  NSAssert(!(!_commitId && !commitId), @"test need to login");
  
  NSDictionary *client = @{@"_commitId": commitId == nil ? _commitId : commitId,
                           @"_remoteHash": remoteHash == nil ? _remoteHash : remoteHash,
                           @"_dicts": dict
                           };
  
  NSDictionary *s = [self loadShadowType: recordType identity: _userId];
  examineHandler(s);
  
  [_dsync syncWithUserId: _userId
               tableName: _tableName
              dictionary: client
                  shadow: expectShadow == nil ? _shadow : expectShadow
           shouldReplace: shouldReplace
              completion: ^(NSDictionary *diff, NSError *error) {
                
                exeHandler(diff, error);
                [self.expection fulfill];
              }];
  
  [self waitForExpectationsWithTimeout: 8.0 handler:^(NSError * _Nullable error) {
    
    NSDictionary *s = [self loadShadowType: recordType identity: _userId];
    completion(s, _commitId, error);
  }];
}

-(void)pullToCheck:(NSDictionary *)expectRemote
        exeHandler:(void(^)(BOOL isSame))exeHandler
        completion:(void(^)(NSError *error))completion {
  
  self.expection = [self expectationWithDescription: @"finalLoadCheck"];
  
  [_dsync pullType: RecordTypeBookmark user: _userId completion: ^(NSDictionary *item, NSError *error) {
    
    exeHandler([item[@"_dicts"] isEqualToDictionary: expectRemote]);
    
    [self.expection fulfill];
  }];
  
  [self waitForExpectationsWithTimeout: 5.0 handler: ^(NSError * _Nullable error) {
    
    completion(error);
  }];
}

@end
