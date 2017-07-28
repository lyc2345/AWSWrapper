//
//  DynamoService.h
//  LoginManager
//
//  Created by Stan Liu on 16/03/2017.
//  Copyright © 2017 Stan Liu. All rights reserved.
//

@import Foundation;
#import "RecordSuitable.h"
#import "DSError.h"
#import "OfflineDB.h"

@interface DynamoService : NSObject
@end

@interface DynamoService (AWS)

-(void)pushWithObject:(NSDictionary *)record
                 type:(RecordType)type
                 diff:(NSDictionary *)diff
               userId:(NSString *)userId
           completion:(void(^)(NSDictionary *responseItem, NSError *error, NSString *commitId))completion;

-(void)forcePushWithType:(RecordType)type
                  record:(NSDictionary *)record
                  userId:(NSString *)userId
              completion:(void(^)(NSError *error, NSString *commitId, NSString *remoteHash))completion;


#pragma mark (Open API)

/**
 pull Bookmark or RecentlyVisit data by userId and Class
 
 @param type AWS Model Type (e.g. RecordTypebookmark)
 @param userId AWS identityID
 @param completionHandler The handler will be ran once the task is completion.
 
 item is pure dictionary object for bookmark record.
 */
-(void)pullType:(RecordType)type user:(NSString *)userId completion:(void(^)(NSDictionary *item, DSError *error))completionHandler;

/**
 1. It will compare record and shadow first and generate a client_shadow_diff
 2. If client's commit Id equal to remote's, it will push the diff to remote on AWS
 3. If commit Id is not the same.
 4. pull remote
 5. diff remote and client, apply remote diff into client,
 6. apply first client_shadow_diff into remote_client = new remote_client
 7. diff new remote_client and remote, also apply client_shadow_diff into remote_client
 8. push the diffs by remote diff new_remote_client

 @param type Bookmark or RecentlyVisit
 @param userId AWS identity id
 @param mergeCompletion return error
 */
//-(void)mergePushType:(RecordType)type userId:(NSString *)userId completion:(void(^)(NSDictionary *responseItem, DSError *error))mergeCompletion;

@end
