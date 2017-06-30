//
//  DynamoSync.h
//  Pods
//
//  Created by Stan Liu on 23/06/2017.
//
//


#import <Foundation/Foundation.h>
#import "BookmarkManager.h"

@protocol DynamoSyncDelegate <NSObject>

-(void)dynamoPushSuccessWithType:(RecordType)type data:(NSDictionary *)data newCommitId:(NSString *)commitId;
-(void)dynamoPushConflictWithType:(RecordType)type pullingData:(NSDictionary *)data;
-(void)dynamoPullFailureWithType:(RecordType)type error:(NSError *)error;

@end


@interface DynamoSync : NSObject

@property (weak, nonatomic) id<DynamoSyncDelegate> delegate;

/**
 * @param userId AWS identityID
 * @param tableName Table Name in DynamoDB
 * @param dict the data that will be synced
 * @param shouldReplace indicates how to merge two dictionaries when they have same key but different values
 * @param completion the handler will be run once when pull, merge, and push operations are finished
 * @param diff when pull and merge operations are successful, diff shuold not be nil.
 */
- (void)syncWithUserId:(NSString*)userId
             tableName:(NSString*)tableName
            dictionary:(NSDictionary*)dict
         shouldReplace:(BOOL (^)(id oldValue, id newValue))shouldReplace
            completion:(void (^)(NSDictionary* diff, NSError* error))completion;

/**
 * @param diff the diff object between two dictionaries. it contains keys ("add", "delete", "replace")
 * @param dict the dictionary that will be patched by diff
 */
- (NSDictionary*)applyDiff:(NSDictionary*)diff toDictionary:(NSDictionary*)dict;

@end
