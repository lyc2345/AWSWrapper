//
//  OfflineDB.h
//  Pods
//
//  Created by Stan Liu on 27/06/2017.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, RecordType) {
  RecordTypeBookmark = 0,
  RecordTypeHistory = 1
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


+(NSDictionary *)shadowIsBookmark:(BOOL)isBookmark;

+(BOOL)setShadow:(NSDictionary *)dict isBookmark:(BOOL)isBookmark;

-(void)addOffline:(NSDictionary *)r type:(RecordType)type ofIdentity:(NSString *)identity;

-(NSDictionary *)deleteOffline:(NSDictionary *)r type:(RecordType)type ofIdentity:(NSString *)identity;

-(NSDictionary *)getOfflineRecordOfIdentity:(NSString *)identity type:(RecordType)type;

@end





