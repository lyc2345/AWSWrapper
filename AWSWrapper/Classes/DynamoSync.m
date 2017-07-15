//
//  DynamoSync.m
//  Pods
//
//  Created by Stan Liu on 23/06/2017.
//
//

#import "DynamoSync.h"
#import "DSWrapper.h"
#import "Random.h"
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

@end

@implementation DynamoSync

- (instancetype)init
{
  self = [super init];
  if (self) {
    
  }
  return self;
}

- (void)syncWithUserId:(NSString *)userId
             tableName:(NSString *)tableName
            dictionary:(NSDictionary *)dict
                shadow:(NSDictionary *)shadow
         shouldReplace:(BOOL (^)(id oldValue, id newValue))shouldReplace
            completion:(void (^)(NSDictionary* diff, NSError* error))completion {
  
  RecordType type = [tableName isEqualToString: @"Bookmark"] ? RecordTypeBookmark : RecordTypeRecentlyVisit ;
  BOOL isBookmark = [tableName isEqualToString: @"Bookmark"] ? YES : NO;
  
  __block NSDictionary *diff_client_shadow = [DSWrapper diffWins: dict[@"_dicts"] loses: shadow];

  BookmarkManager *bookmarkManager = [[BookmarkManager alloc] init];
  
  NSLog(@"start: 1");
  // push local AWS model and the diff we get before.
  [bookmarkManager pushWithObject: dict
                             type: type
                             diff: diff_client_shadow
                           userId: userId
                       completion:^(NSDictionary *responseItem, NSError *error, NSString *commitId) {
    
    NSLog(@"done 1");
    if (!error && commitId) {
      // expected commit id meet localBookmarkRecord commit id
      // successed!
      NSLog(@"push success by merge push at the first place");
      //NSLog(@"first push success with object: %@", response);
        // To pass new data and new commit id
      [_delegate dynamoPushSuccessWithType: type data: dict newCommitId: commitId];
      completion(diff_client_shadow, nil);
      return;
      
    } else {
      NSLog(@"first conditional write error: %@", error);
      
      NSLog(@"starting pull...");
      NSLog(@"start 2");
      [bookmarkManager pullType: type user: userId completion:^(NSDictionary *item, DSError *error) {
        
        NSLog(@"done 2");
        if (error && (error && error.code != 4)) {
          
          NSLog(@"BookmarkManager pulling error: %@", error);
          // com.BookmarkManager.pullError
          completion(nil, error);
          return;
          
        } else {
          
          NSLog(@"pulling Success");
          NSMutableDictionary *cloud = [item mutableCopy];
          
          NSLog(@"start 3");
          if (!cloud) {
            NSLog(@"remote is empty, push...");
            [bookmarkManager forcePushWithType: type record: dict userId: userId completion:^(NSError *error, NSString *commitId, NSString *rmoteHash) {
              
              NSLog(@"done 3");
              if (!error) {
                NSLog(@"FORCE push success with reocrd: %@", dict);
                [_delegate dynamoPushSuccessWithType: type data: dict newCommitId: commitId];
                completion(diff_client_shadow, nil);
                return;
              }
              completion(diff_client_shadow, [DSError forcePushFailed]);
            }];
          } else {
            
            // TODO: This part will never excute because if one of dicts, commitId, remoteHash three attribute is nil, pullType method will return nil
            // IF this condition needs to implement. Check AWS attributes convert to regular dictionary method. [BookmarkManager convert:]
            // **************************************************************************************************************
            NSLog(@"done 3");
            NSLog(@"remote version: %@, local version: %@", cloud[@"_remoteHash"], dict[@"_remoteHash"]);
            NSLog(@"remote timestamp: %@, local timestamp: %@", cloud[@"_commitId"], dict[@"_commitId"]);
            
            NSMutableDictionary *new = [NSMutableDictionary dictionary];
            
            [new setObject: cloud[@"_id"] forKey: @"_id"];
            [new setObject: cloud[@"_userId"] forKey: @"_userId"];
            [new setObject: cloud[@"_commitId"] forKey: @"_commitId"];
            [new setObject: cloud[@"_remoteHash"] forKey: @"_remoteHash"];
            [new setObject: cloud[@"_dicts"] forKey: @"_dicts"];
            
            NSLog(@"start 4: check remote Hash");
            // remote Hash is nil
            if (!cloud[@"_remoteHash"]) {
              
              [new setObject: [Random string] forKey: @"_commidId"];
              [new setObject: [Random string] forKey: @"_remoteHash"];
              
              NSLog(@"RemoteHash is nil, force push whole local record");
              [bookmarkManager forcePushWithType: type record: cloud userId: userId completion:^(NSError *error, NSString *commitId, NSString *rmoteHash) {
                
                if (!error) {
                  NSLog(@"5: Done by force push");
                  [_delegate dynamoPushSuccessWithType: type data: dict newCommitId: commitId];
                  completion(diff_client_shadow, nil);
                } else {
                  completion(nil, [DSError forcePushFailed]);
                }
              }];
              return;
            } else if (![cloud[@"_remoteHash"] isEqualToString: dict[@"_remoteHash"]]) {
              
              NSLog(@"RemoteHash is changed, Now empty shadow...");
              id emptyShadow = [_delegate emptyShadowIsBookmark: isBookmark];
              // diff client shadow again. becasue shadow is empty.
              diff_client_shadow = [DSWrapper diffWins: dict[@"_dicts"] loses: emptyShadow];
              NSLog(@"Get a new diff from client and empty shadow");
            }
            // **************************************************************************************************************
            NSLog(@"done 4");
            
            NSLog(@"starting diffmerge...");
            NSLog(@"start 4-1: diffmerge");
            NSDictionary *need_to_apply_to_client = [DSWrapper diffWins: cloud[@"_dicts"] loses: dict[@"_dicts"]];
            
            NSDictionary *newClientDicts = [DSWrapper mergeInto: dict[@"_dicts"] applyDiff: need_to_apply_to_client];
            
            NSLog(@"done 4-1");
            NSLog(@"start 5");
            
            NSLog(@"conditional push whole local record");
            newClientDicts = [DSWrapper mergeInto: newClientDicts
                                        applyDiff: diff_client_shadow
                                       primaryKey: @"comicName"
                                    shouldReplace: shouldReplace];
            NSDictionary *need_to_apply_to_remote = [DSWrapper diffWins: newClientDicts loses: cloud[@"_dicts"]];
            
            if (!need_to_apply_to_remote) {
              
              [_delegate dynamoPushSuccessWithType: type data: new newCommitId: new[@"_commitId"]];
              completion(nil, nil);
              return;
            }
            
            [bookmarkManager pushWithObject: new type: type diff: need_to_apply_to_remote userId: userId completion:^(NSDictionary *responseItem, NSError *error, NSString *commitId) {
              
              if (error) {
                NSLog(@"conditional push error: %@", error);
                NSLog(@"fuckkkkkkkkkkkkkkkk erorrrrrrrrr");
                completion(nil, [DSError mergePushFailed]);
                return;
              }
              NSLog(@"push success after diffmerge");
              NSLog(@"5: Done by conditonal update");
              
              [new setObject: newClientDicts forKey: @"_dicts"];
              
              [_delegate dynamoPushSuccessWithType: type data: new newCommitId: commitId];
              completion(need_to_apply_to_remote, nil);
            }];
          }
        }
      }];
    }
  }];
}

/**
 * @param diff the diff object between two dictionaries. it contains keys ("add", "delete", "replace")
 * @param dict the dictionary that will be patched by diff
 */
- (NSDictionary*)applyDiff:(NSDictionary*)diff toDictionary:(NSDictionary*)dict {
  
  return [DSWrapper mergeInto: dict applyDiff: diff];
}

@end
