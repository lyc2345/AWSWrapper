//
//  Tests.h
//  AWSWrapper
//
//  Created by Stan Liu on 14/07/2017.
//  Copyright © 2017 lyc2345. All rights reserved.
//

@import XCTest;

@interface DynamoTestBase: XCTestCase

-(void)initial:(NSDictionary *)dict
    exeHandler:(void(^)(NSString *commitId, NSString *remoteHash, NSDictionary *shadow, NSError *error))exeHandler
    completion:(void(^)(NSDictionary *newShadow, NSError *error))completion;

-(void)examineSpec:(NSString *)spec
          commitId:(NSString *)commitId
        remoteHash:(NSString *)remoteHash
        clientDict:(NSDictionary *)dict
      expectShadow:(NSDictionary *)expectShadow
    examineHandler:(void(^)(NSDictionary *shadow))examineHandler
     shouldReplace:(BOOL(^)(id oldValue, id newValue))shouldReplace
        exeHandler:(void(^)(NSDictionary *diff, NSError *error))exeHandler
        completion:(void(^)(NSDictionary *newShadow, NSError *error))completion;


-(void)pullToCheck:(NSDictionary *)expectRemote
       exeHandler:(void(^)(BOOL isSame))exeHandler
       completion:(void(^)(NSError *error))completion;

@end
