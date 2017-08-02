//
//  DynamoSync.h
//  Pods
//
//  Created by Stan Liu on 23/06/2017.
//
//


#import <Foundation/Foundation.h>
#import "DynamoService.h"

@protocol DynamoSyncDelegate <NSObject>


/**
 DynamoSync push success delegate

 @param type Bookmark or History
 @param data as same as remote data
 @param commitId the new commidId, for the next sync
 */
-(void)dynamoPushSuccessWithType:(RecordType)type
                            data:(NSDictionary *)data
                     newCommitId:(NSString *)commitId;


/**
 Need to empty shadow when remoteHash is changed or nil.
 Otherwise, the data in current device may be deleted.

 @param isBookmark for identify Bookmark or History
 @return the shadow you actually set empty or nil.
 */
-(id)emptyShadowIsBookmark:(BOOL)isBookmark ofIdentity:(NSString *)identity;


@end


@interface DynamoSync : NSObject

@property (weak, nonatomic) id<DynamoSyncDelegate> delegate;

/**
 * @param userId AWS identityID
 * @param tableName Table Name in DynamoDB
 * @param dict the data that will be synced
 * @param shadow the shadow should be stored with datas
 * @param shouldReplace indicates how to merge two dictionaries when they have same key but different values
 * @param completion the handler will be run once when pull, merge, and push operations are finished.
 */
- (void)syncWithUserId:(NSString *)userId
             tableName:(NSString *)tableName
            dictionary:(NSDictionary *)dict
                shadow:(NSDictionary *)shadow
         shouldReplace:(BOOL (^)(id oldValue, id newValue))shouldReplace
            completion:(void (^)(NSDictionary* diff, NSError* error))completion;

/**
 * @param diff the diff object between two dictionaries. it contains keys ("add", "delete", "replace")
 * @param dict the dictionary that will be patched by diff
 */
- (NSDictionary*)applyDiff:(NSDictionary*)diff
              toDictionary:(NSDictionary*)dict;

@end
