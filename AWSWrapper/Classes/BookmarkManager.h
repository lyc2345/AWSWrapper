//
//  BookmarkManager.h
//  LoginManager
//
//  Created by Stan Liu on 16/03/2017.
//  Copyright © 2017 Stan Liu. All rights reserved.
//

@import Foundation;
#import "RecordSuitable.h"
#import "DSError.h"

typedef NS_ENUM(NSInteger, RecordType) {
	RecordTypeBookmark = 0,
	RecordTypeRecentlyVisit = 1
};

@interface OfflineDB: NSObject


#pragma mark Offline Format

+(NSDictionary *)recordFormatOFIdentity:(NSString *)identity
                               commitId:(NSString *)commitId
                                andList:(NSArray *)list
                             remoteHash:(NSString *)remoteHash;

#pragma mark Common (Private)

// obtain the whole bookmark records of different users.
-(NSMutableArray *)obtainOfflineMutableRecordsOfType:(RecordType)type;
// get the record of the current login user.
// ["_identity": xxxxx, "_commitId": XXXXXX , "_list": [String: Dictionary]]
-(NSDictionary *)obtainOfflineExistRecordFromRecords:(NSArray *)records ofIdentity:(NSString *)identity;

// replace the new bookmark list into the exist record in multiple records.
-(NSArray *)modifyOfflineRecords:(NSArray *)records withRecord:(NSDictionary *)record ofIdentity:(NSString *)identity;

#pragma mark - Bookmark (Private)

-(NSDictionary *)setOfflineNewRecord:(NSDictionary *)record type:(RecordType)type identity:(NSString *)identity;

-(BOOL)pushSuccessThenSaveLocalRecord:(NSDictionary *)newRecord type:(RecordType)type newCommitId:(NSString *)commitId;

#pragma mark - Bookmark (Open)

-(void)addOffline:(NSDictionary *)r type:(RecordType)type ofIdentity:(NSString *)identity;

-(NSDictionary *)deleteOffline:(NSDictionary *)r type:(RecordType)type ofIdentity:(NSString *)identity;

-(NSDictionary *)getOfflineRecordOfIdentity:(NSString *)identity type:(RecordType)type;

@end

@interface BookmarkManager : NSObject

@end

@interface BookmarkManager (Offline)

-(NSDictionary *)getOfflineRecordOfIdentity:(NSString *)identity type:(RecordType)type;
-(void)addOffline:(NSDictionary *)r type:(RecordType)type ofIdentity:(NSString *)identity;
-(NSDictionary *)deleteOffline:(NSDictionary *)r type:(RecordType)type ofIdentity:(NSString *)identity;

@end

@interface BookmarkManager (AWS)

-(void)pushWithObject:(NSDictionary *)record type:(RecordType)type diff:(NSDictionary *)diff userId:(NSString *)userId completion:(void(^)(NSDictionary *responseItem, NSError *error, NSString *commitId))completion;

-(void)forcePushWithType:(RecordType)type record:(NSDictionary *)record userId:(NSString *)userId completion:(void(^)(NSDictionary *item, NSError *error, NSString *commitId))completion;


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
-(void)mergePushType:(RecordType)type userId:(NSString *)userId completion:(void(^)(NSDictionary *responseItem, DSError *error))mergeCompletion;

@end
