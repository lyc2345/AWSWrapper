//
//  OfflineDB.m
//  Pods
//
//  Created by Stan Liu on 27/06/2017.
//
//

#import "OfflineDB.h"
#import "DSWrapper.h"
#import "Random.h"

// bookmark = Dictionary
// bookmarkList = Array(Dicionary)
// bookmarkRecord = Dicionary(list: bookmarkList)
// bookmarkRecords = Array(bookmarkRecords)

@interface OfflineDB ()

@end

@implementation OfflineDB

NSString * const __BOOKMARK_SHADOW_LIST = @"__BOOKMARK_SHADOW_LIST";
NSString * const __HISTORY_SHADOW_LIST  = @"__HISTORY_SHADOW_LIST";

NSString * const __BOOKMARKS_LIST	= @"__BOOKMARKS_LIST";
NSString * const __HISTORY_LIST	  = @"__HISTORY_LIST";


+(NSDictionary *)recordFormatOFIdentity:(NSString *)identity
                               commitId:(NSString *)commitId
                                andList:(NSArray *)list
                             remoteHash:(NSString *)remoteHash {
  
  if (identity && commitId && remoteHash) {
    return @{@"_commitId": commitId,
             @"_dicts": list != nil ? list : [NSArray array],
             @"_userId": identity,
             @"_remoteHash": remoteHash};
  }
  return nil;
}

+(NSDictionary *)shadowFormat:(NSDictionary *)shadow
                   ofIdentity:(NSString *)identity {
  
  if (shadow && identity) {
    return @{
             @"_shadow": shadow,
             @"_userId": identity
             };
  }
  return nil;
}

#pragma mark Common (Private)

// This could be overwrited if you wanna make the test db using differnet key
//MARK: OfflineDB base

-(NSArray *)bookmarkDB {
  return [[NSUserDefaults standardUserDefaults] arrayForKey: __BOOKMARKS_LIST];
}

-(NSArray *)historyDB {
  return [[NSUserDefaults standardUserDefaults] arrayForKey: __HISTORY_LIST];
}

-(BOOL)setBookmarkDB:(NSArray *)records {
  [[NSUserDefaults standardUserDefaults] setObject: records forKey: __BOOKMARKS_LIST];
  return [[NSUserDefaults standardUserDefaults] synchronize];
}

-(BOOL)setHistoryDB:(NSArray *)records {
  [[NSUserDefaults standardUserDefaults] setObject: records forKey:  __HISTORY_LIST];
  return [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSArray *)bookmarkShadowDB {
  return [[NSUserDefaults standardUserDefaults] arrayForKey: __BOOKMARK_SHADOW_LIST];
}

+(NSArray *)historyShadowDB {
  return [[NSUserDefaults standardUserDefaults] arrayForKey: __HISTORY_SHADOW_LIST];
}

+(BOOL)setBookmarkShadow:(NSArray *)records {
  [[NSUserDefaults standardUserDefaults] setObject: records forKey: __BOOKMARK_SHADOW_LIST];
  return [[NSUserDefaults standardUserDefaults] synchronize];
}

+(BOOL)setHistoryShadow:(NSArray *)records {
  [[NSUserDefaults standardUserDefaults] setObject: records forKey:  __HISTORY_SHADOW_LIST];
  return [[NSUserDefaults standardUserDefaults] synchronize];
}


// obtain the whole bookmark records of different users.
-(NSMutableArray *)obtainOfflineMutableRecordsOfType:(RecordType)type {
  
  // get the multiple users record first
  NSArray *offlineRecords = type == RecordTypeBookmark ? self.bookmarkDB : self.historyDB;
  
  // create it if dosen't exist any
  if (!offlineRecords) {
    offlineRecords = [NSArray array];
  }
  NSMutableArray *offlineMutableRecords = [offlineRecords mutableCopy];
  return offlineMutableRecords;
}

-(BOOL)setUserDefaultWithRecords:(NSArray *)records isBookmark:(BOOL)isBookmark {
  
  if (isBookmark) {
    return [self setBookmarkDB: records];
  } else {
    return [self setHistoryDB: records];
  }
}

// get the record of the current login user.
// ["_identity": xxxxx, "_commitId": XXXXXX , "_list": [String: Dictionary]]
-(NSDictionary *)obtainOfflineExistRecordFromRecords:(NSArray *)records ofIdentity:(NSString *)identity {
  
  __block NSDictionary *dict;
  [records enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
    
    NSString *localIdentity = obj[@"_userId"];
    if ([localIdentity isEqualToString: identity]) {
      
      //NSLog(@"identity: %@, has exist record: %@", identity, obj);
      dict = obj;
    }
  }];
  return (dict != nil) ? dict : [NSDictionary dictionary];
}

// replace the new bookmark list into the exist record in multiple records.
-(NSArray *)modifyOfflineRecords:(NSArray *)records withRecord:(NSDictionary *)record ofIdentity:(NSString *)identity {
  
  NSMutableArray *mutableRecords = [records mutableCopy];
  __block bool isExist = false;
  [mutableRecords enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
    isExist = false;
    if ([obj[@"_userId"] isEqualToString: identity]) {
      isExist = true;
      *stop = true;
      //NSLog(@"identity: %@, has exist record: %@", identity, obj);
    }
    if (stop) {
      NSMutableDictionary *mutableInfo = [obj mutableCopy];
      [mutableInfo setObject: record[@"_dicts"] forKey: @"_dicts"];
      
      // if commit and remoteHash is nil, set a new one
      [mutableInfo setObject:
       record[@"_commitId"] != nil ? record[@"_commitId"] : [Random string]
                      forKey: @"_commitId"];
      [mutableInfo setObject:
       record[@"_remoteHash"] != nil ? record[@"_remoteHash"] : [Random string]
                      forKey: @"_remoteHash"];
      [mutableRecords replaceObjectAtIndex: idx withObject: mutableInfo];
      return;
    }
  }];
  
  if (!isExist) {
    
    [mutableRecords addObject: [OfflineDB recordFormatOFIdentity: identity commitId: [Random string] andList: record[@"_dicts"] remoteHash: [Random string]]];
  }
  return [mutableRecords copy];
}

#pragma mark - Bookmark (Private)

-(NSDictionary *)setOfflineNewRecord:(NSDictionary *)record type:(RecordType)type identity:(NSString *)identity {
  
  NSArray *records = [self obtainOfflineMutableRecordsOfType: type];
  NSArray *modifiedOfflineRecords;
  BOOL success;
  
  modifiedOfflineRecords = [self modifyOfflineRecords: records withRecord: record ofIdentity: identity];
  success = [self setUserDefaultWithRecords: modifiedOfflineRecords isBookmark: type == RecordTypeBookmark];
  
  if (success) {
    return record;
  } else {
    return nil;
  }
}

-(BOOL)pushSuccessThenSaveLocalRecord:(NSDictionary *)newRecord type:(RecordType)type newCommitId:(NSString *)commitId {
  
  NSArray *records = [self obtainOfflineMutableRecordsOfType: type];
  
  NSMutableDictionary *oldRecord = [[self obtainOfflineExistRecordFromRecords: records ofIdentity: newRecord[@"_userId"]] mutableCopy];
  [oldRecord setValue: newRecord[@"_dicts"]	forKey: @"_dicts"];
  [oldRecord setValue: commitId	forKey: @"_commitId"];
  [oldRecord setValue: newRecord[@"_remoteHash"] forKey: @"_remoteHash"];
  [oldRecord setValue: newRecord[@"_userId"] forKey: @"_userId"];
  NSArray *modifiedOfflineRecords = [self modifyOfflineRecords: records withRecord: oldRecord ofIdentity: newRecord[@"_userId"]];
  
  BOOL success = [self setUserDefaultWithRecords: modifiedOfflineRecords isBookmark: type == RecordTypeBookmark];
  if (success) {
    BOOL saveShadowSuccess = [OfflineDB setShadow: newRecord[@"_dicts"]
                                       isBookmark: type == RecordTypeBookmark
                                       ofIdentity: newRecord[@"_userId"]];
    return saveShadowSuccess;
  } else {
    return NO;
  }
}

#pragma mark - Bookmark (Open)

-(void)addOffline:(NSDictionary *)dict type:(RecordType)type ofIdentity:(NSString *)identity {
  
  if ([dict[@"author"] isEqualToString: @""] || [dict[@"comicName"] isEqualToString: @""] || [dict[@"url"] isEqualToString: @""]) {
    NSLog(@"author, comicName, url is nil in Dictionary");
    return;
  }
  NSArray *records = [self obtainOfflineMutableRecordsOfType: type];
  NSMutableDictionary *record = [[self obtainOfflineExistRecordFromRecords: records
                                                                ofIdentity: identity] mutableCopy];
  NSMutableArray *list = [[DSWrapper arrayFromDict: (NSDictionary *)record[@"_dicts"]] mutableCopy];
  __block bool isExist = false;
  
  [list enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
    
    if ([obj[@"url"] isEqualToString: dict[@"url"]] &&
        [obj[@"author"] isEqualToString: dict[@"author"]]) {
      isExist = YES;
      *stop = YES;
      return;
    }
    isExist = NO;
  }];
  
  if (!list) {
    list = [NSMutableArray array];
  }
  if (!isExist) {
    [list addObject: dict];
  }
  
  [record setValue: [DSWrapper dictFromArray: list] forKey: @"_dicts"];
  [self setOfflineNewRecord: record type: type identity: identity];
}

-(NSDictionary *)deleteOffline:(NSDictionary *)dict type:(RecordType)type ofIdentity:(NSString *)identity {
  
  NSArray *records = [self obtainOfflineMutableRecordsOfType: type];
  NSMutableDictionary *record = [[self obtainOfflineExistRecordFromRecords: records
                                                                ofIdentity: identity] mutableCopy];
  NSMutableArray *list = [[DSWrapper arrayFromDict: (NSDictionary *)record[@"_dicts"]] mutableCopy];
  
  if (!list) {
    return record;
  }
  NSMutableArray *editedList = [NSMutableArray array];
  
  for (NSDictionary *bk in list) {
    if (![bk isEqualToDictionary: dict]) {
      [editedList addObject: bk];
    }
  }
  [record setValue: [DSWrapper dictFromArray: editedList] forKey: @"_dicts"];
  return [self setOfflineNewRecord: record type: type identity: identity];
}

-(NSDictionary *)getOfflineRecordOfIdentity:(NSString *)identity type:(RecordType)type {
  
  NSArray *offlineRecords = [self obtainOfflineMutableRecordsOfType: type];
  return [self obtainOfflineExistRecordFromRecords: offlineRecords ofIdentity: identity];
}


//MARK: Shadow

// To remote remote and client and client_shadow

+(NSDictionary *)loadShadowType:(RecordType)type ofIdentity:(NSString *)identity {
  
  NSArray *shadowList = type == RecordTypeBookmark ? [self bookmarkShadowDB] : [self historyShadowDB] ;
  __block NSDictionary *__shadow = nil;
  [shadowList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
    
    if([obj[@"_userId"] isEqualToString: identity]) {
      __shadow = obj[@"_shadow"];
    }
  }];
  return __shadow;
}

+(BOOL)saveShadow:(NSDictionary *)shadow type:(RecordType)type ofIdentity:(NSString *)identity {
  
  NSMutableArray *shadowList = type == RecordTypeBookmark ? [[self bookmarkShadowDB] mutableCopy] : [[self historyShadowDB] mutableCopy] ;
  
  [shadowList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
    
    if([obj[@"_userId"] isEqualToString: identity]) {
      *stop = YES;
    }
    if (stop) {
      NSDictionary *shadowObject = [OfflineDB shadowFormat: shadow ofIdentity: identity];
      [shadowList replaceObjectAtIndex: idx withObject: shadowObject];
      return;
    }
  }];
  return [self setBookmarkShadow: shadowList];
}

+(NSDictionary *)shadowIsBookmark:(BOOL)isBookmark ofIdentity:(NSString *)identity {
  return [self loadShadowType: isBookmark == YES ? RecordTypeBookmark : RecordTypeHistory
                   ofIdentity: identity];
}

+(BOOL)setShadow:(NSDictionary *)dict isBookmark:(BOOL)isBookmark ofIdentity:(NSString *)identity {
  
  return [self saveShadow: dict
                     type: isBookmark == YES ? RecordTypeBookmark : RecordTypeHistory
               ofIdentity: identity];
}


@end
