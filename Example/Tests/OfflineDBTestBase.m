//
//  OfflineDBTestBase.m
//  AWSWrapper
//
//  Created by Stan Liu on 02/08/2017.
//  Copyright © 2017 lyc2345. All rights reserved.
//

#import "OfflineDBTestBase.h"
@import AWSWrapper;

@interface OfflineDB (Test)

-(NSArray *)bookmarkDB;

-(NSArray *)historyDB;

-(BOOL)setBookmarkDB:(NSArray *)records;

-(BOOL)setHistoryDB:(NSArray *)records;

+(NSDictionary *)bookmarkShadowDB;

+(NSDictionary *)historyShadowDB;

+(BOOL)setBookmarkShadow:(NSDictionary *)records;

+(BOOL)setHistoryShadow:(NSDictionary *)records;

@end

@implementation OfflineDB (Test)

NSString * const __BOOKMARKS_LIST_TEST = @"__BOOKMARKS_LIST_TEST";
NSString * const __HISTORY_LIST_TEST = @"__HISTORY_LIST_TEST";
NSString * const __BOOKMARK_SHADOW_TEST = @"__BOOKMARK_SHADOW_TEST";
NSString * const __HISTORY_SHADOW_TEST = @"__HISTORY_SHADOW_TEST";


-(NSArray *)bookmarkDB {
  return [[NSUserDefaults standardUserDefaults] arrayForKey: __BOOKMARKS_LIST_TEST];
}

-(NSArray *)historyDB {
  return [[NSUserDefaults standardUserDefaults] arrayForKey: __HISTORY_LIST_TEST];
}

-(BOOL)setBookmarkDB:(NSArray *)records {
  [[NSUserDefaults standardUserDefaults] setObject: records forKey: __BOOKMARKS_LIST_TEST];
  return [[NSUserDefaults standardUserDefaults] synchronize];
}

-(BOOL)setHistoryDB:(NSArray *)records {
  [[NSUserDefaults standardUserDefaults] setObject: records forKey:  __HISTORY_LIST_TEST];
  return [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSArray *)bookmarkShadowDB {
  return [[NSUserDefaults standardUserDefaults] arrayForKey: __BOOKMARK_SHADOW_TEST];
}

+(NSArray *)historyShadowDB {
  return [[NSUserDefaults standardUserDefaults] arrayForKey: __HISTORY_SHADOW_TEST];
}

+(BOOL)setBookmarkShadow:(NSArray *)records {
  [[NSUserDefaults standardUserDefaults] setObject: records forKey: __BOOKMARK_SHADOW_TEST];
  return [[NSUserDefaults standardUserDefaults] synchronize];
}

+(BOOL)setHistoryShadow:(NSArray *)records {
  [[NSUserDefaults standardUserDefaults] setObject: records forKey:  __HISTORY_SHADOW_TEST];
  return [[NSUserDefaults standardUserDefaults] synchronize];
}


@end

@interface OfflineDBTestBase ()

@property DynamoSync *dynamoSync;

@end

@implementation OfflineDBTestBase

- (instancetype)init
{
  self = [super init];
  if (self) {
  
    _dynamoSync = [DynamoSync new];
  }
  return self;
}

+(NSDictionary *)shadowIsBookmark:(BOOL)isBookmark ofIdentity:(NSString *)identity {
  return [OfflineDB shadowIsBookmark: isBookmark ofIdentity: identity];
}

+(BOOL)setShadow:(NSDictionary *)dict isBookmark:(BOOL)isBookmark ofIdentity:(NSString *)identity {
  return [OfflineDB setShadow: dict isBookmark: isBookmark ofIdentity: identity];
}

-(NSDictionary *)addOffline:(NSDictionary *)r type:(RecordType)type ofIdentity:(NSString *)identity {
  //[self.offlineDB addOffline: r type: type ofIdentity: identity];
  return [_dynamoSync addOffline: r type: type ofIdentity: identity];
}

-(NSDictionary *)deleteOffline:(NSDictionary *)r type:(RecordType)type ofIdentity:(NSString *)identity {
  //return [self.offlineDB deleteOffline: r type: type ofIdentity: identity];
  return [_dynamoSync deleteOffline: r type: type ofIdentity: identity];
}

-(NSDictionary *)loadOfflineRecordType:(RecordType)type ofIdentity:(NSString *)identity {
  //return [self.offlineDB getOfflineRecordOfIdentity: identity type: type];
  return [_dynamoSync loadOfflineRecordType: type ofIdentity: identity];
}

@end
