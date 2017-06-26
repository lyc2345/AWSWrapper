//
//  DynamoSync.m
//  Pods
//
//  Created by Stan Liu on 23/06/2017.
//
//

#import "DynamoSync.h"
#import "BookmarkManager.h"
#import "DSWrapper.h"
/*
  shouldReplace=true 是same key but different value嗎
  false的時候是different key and value嗎」
  不是
  是說相同的key，但是不同的value
  這時候要選那一個呢？
  shouldReplace return true選第二個parameter
  return false選第一個
  「2. 下面diff那個replace的用途是？ 」負責把更新的資料apply到現有的data上
 
 這個user story是可以改的 只是要討論出一個解決方法
 😢
 1
 只是說目前是這樣 我這邊是寫比對author跟url 所以就像你說的那樣 目前是永遠沒辦法更新的
 Hai Feng Kao
 所以就用傳入的block來判斷
*/

@interface DynamoSync ()

@property (strong, nonatomic) OfflineDB *offlineDB;

@end

@implementation DynamoSync

- (instancetype)init
{
  self = [super init];
  if (self) {
    
    self.offlineDB = [OfflineDB new];
    
  }
  return self;
}

- (void)syncWithUserId:(NSString*)userId
             tableName:(NSString*)tableName
            dictionary:(NSDictionary*)dict
         shouldReplace:(BOOL (^)(id oldValue, id newValue))shouldReplace
            completion:(void (^)(NSDictionary* diff, NSError* error))completion {
  
  RecordType type = [tableName isEqualToString: @"Bookmark"] ? RecordTypeBookmark : RecordTypeRecentlyVisit ;
  BOOL isBookmark = [tableName isEqualToString: @"Bookmark"] ? YES : NO;
  
  NSDictionary *local = [self.offlineDB getOfflineRecordOfIdentity: userId type: type];
  
  __block NSDictionary *diff_client_shadow = [DSWrapper diffShadowAndClient: dict
                                                                 primaryKey: @"comicName"
                                                                 isBookmark: isBookmark
                                                              shouldReplace: shouldReplace];
  
  
  // dictionary is the data that will be synced
  //NSDictionary *diff_dict_shadow = [DSWrapper diffShadowAndClient: dict isBookmark: isBookmark];
  
  // 如果要取代用newValue, otherwise use newValue
  //NSDictionary *oldValue = diff_dict_shadow[@"_delete"];
  //NSDictionary *newValue = diff_dict_shadow[@"_add"];
  //BOOL replace = shouldReplace(oldValue, newValue);
  
  NSDictionary *fakeShadow = @{
                           @"B": @{@"author": @"B", @"url": @"B"},
                           @"C": @{@"author": @"C", @"url": @"C"}
                           };
  
  NSDictionary *diff = [DSWrapper diffWins: dict
                                  andLoses: fakeShadow
                                primaryKey: @"comicName"
                             shouldReplace: shouldReplace];
  
  
  
  
  completion(diff, nil);
  
  //[self.bmm pushWithObject:<#(NSDictionary *)#> type:<#(RecordType)#> diff:<#(NSDictionary *)#> userId:<#(NSString *)#> completion:<#^(NSDictionary *responseItem, NSError *error, NSString *commitId)completion#>]
  
  
  
  // 用completion 把diff傳出來
}

/**
 * @param diff the diff object between two dictionaries. it contains keys ("add", "delete", "replace")
 * @param dict the dictionary that will be patched by diff
 */
- (NSDictionary*)applyDiff:(NSDictionary*)diff toDictionary:(NSDictionary*)dict {
  
  
  
  return nil;
}

@end
