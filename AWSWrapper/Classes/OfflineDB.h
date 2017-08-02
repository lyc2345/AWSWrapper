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


#pragma mark - Bookmark (Open)

//MARK: Trigger after push success

-(BOOL)pushSuccessThenSaveLocalRecord:(NSDictionary *)newRecord type:(RecordType)type newCommitId:(NSString *)commitId;


//MARK: Offline DB READ, ADD, DELETE

+(NSDictionary *)shadowIsBookmark:(BOOL)isBookmark;

+(BOOL)setShadow:(NSDictionary *)dict isBookmark:(BOOL)isBookmark;

-(void)addOffline:(NSDictionary *)r type:(RecordType)type ofIdentity:(NSString *)identity;

-(NSDictionary *)deleteOffline:(NSDictionary *)r type:(RecordType)type ofIdentity:(NSString *)identity;

-(NSDictionary *)getOfflineRecordOfIdentity:(NSString *)identity type:(RecordType)type;

@end





