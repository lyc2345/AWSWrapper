# AWSWrapper

[![CI Status](http://img.shields.io/travis/lyc2345/AWSWrapper.svg?style=flat)](https://travis-ci.org/lyc2345/AWSWrapper)
[![Version](https://img.shields.io/cocoapods/v/AWSWrapper.svg?style=flat)](http://cocoapods.org/pods/AWSWrapper)
[![License](https://img.shields.io/cocoapods/l/AWSWrapper.svg?style=flat)](http://cocoapods.org/pods/AWSWrapper)
[![Platform](https://img.shields.io/cocoapods/p/AWSWrapper.svg?style=flat)](http://cocoapods.org/pods/AWSWrapper)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

AWSWrapper is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "AWSWrapper", :git => 'https://github.com/lyc2345/AWSWrapper.git'
```

### import
```
@import AWSWrapper;
```

1. Sign up for AWSMobileHub Service
2. create Bookmark and RecentVisit "Amazon DynamoDb Tables" 
3. create "Amazon Cognito Idnentity Pools", User sign-in only use Email and Password. 
4. set up .plist according to Integrate > iOS Obj-C > Getting Started > OPTION 2
   OR You can see the plist in DEMO project.

### Documetation
**Login**

```objective-c
// For AWS online login
-(void)signUpWithUser:(NSString *)username
             password:(NSString *)password
                email:(NSString *)email
                  tel:(NSString *)telephone
        waitToConfirm:(void(^)(NSString *destination))confirmAction
              success:(void(^)())successHandler
                 fail:(void(^)(NSError *error))failHandler;


-(void)confirmSignUpWithUser:(NSString *)username
                 confirmCode:(NSString *)confirmCode
                     success:(void(^)())successHandler
                        fail:(void(^)(NSError *error))failHandler;

-(void)onResendOfUser:(NSString *)username
              Success:(void(^)(NSString *destination))successHandler
                 fail:(void(^)(NSError *error))failHandler;

-(void)confirmForgotNewPassword:(NSString *)newPassword
                    confirmCode:(NSString *)confirmCode
                        success:(void(^)())successHandler
                           fail:(void(^)(NSError *error))failHandler;

-(void)forgotPasswordOfUser:(NSString *)username
                 completion:(void(^)(NSError *error))completion;

-(void)login:(void(^)(id result, NSError * error))completion;

-(void)logout:(void(^)(id result, NSError *error))completion;
```

**Example**

```objective-c
if (![LoginManager shared].isAWSLogin) {
  [[LoginManager shared] login:^(id  _Nullable result, NSError * _Nullable error) {			
    if (!error) {
      [weakSelf.navigationController popToRootViewControllerAnimated: YES];
    }			
  }];
}
```

```objective-c
// For Offline
-(void)loginOfflineWithUser:(NSString *)user password:(NSString *)password completion:(void(^)(NSError *error))completion;
-(void)logoutOfflineCompletion:(void(^)(NSError *error))completion;
```


**Example**

```objective-c
if ([LoginManager shared].isLogin) {
  [[LoginManager shared] loginOfflineWithUser: username password: password completion:^(NSError *error) {
    if (!error) {
      [weakSelf.navigationController popViewControllerAnimated: YES];
    }
  }];
}

```

**DynamoSync sync Bookmark**

* User offline add, get, delete all the time.
* Use pullType in the application DidFinishLaunch to get the latest data on the server.
* Use mergePushType when terminate applicatioin.


```objective-c

@protocol DynamoSyncDelegate <NSObject>
/**
 DynamoSync push success delegate

 @param type Bookmark or RecentlyVisit
 @param data as same as remote data
 @param commitId the new commidId, for the next sync
 */
-(void)dynamoPushSuccessWithType:(RecordType)type
                            data:(NSDictionary *)data
                     newCommitId:(NSString *)commitId;


/**
 Need to empty shadow when remoteHash is changed or nil.
 Otherwise, the data in current device may be deleted.

 @param isBookmark for identify Bookmark or RecentlyVisit
 @return the shadow you actually set empty or nil.
 */
-(id)emptyShadowIsBookmark:(BOOL)isBookmark;

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
```

**Example**


```objective-c
NSDictionary *record = {
                        "_commitId" = "7E155DB3-ACF8-4B32-9C61-974A8EED985D-38221-0000271ECA47394B";
                        "_dicts" =     {
                            One Piece =         {
                                author = 尾田榮一郎;
                                url = https://zh.wikipedia.org/wiki/ONE_PIECE;
                            }
                        };
                        "_remoteHash" = "CDDF146E-47D7-4D7F-92B1-904F0BEF3D19-38221-0000271ECA473DE5";
                        "_userId" = "us-east-1:2bf27e82-e169-429c-9a32-deebf6570eb8";
                    }
NSDictionary *shadow = {
                            One Piece =         {
                                author = 尾田榮一郎;
                                url = https://zh.wikipedia.org/wiki/ONE_PIECE;
                            },
                            Naruto =         {
                                author = 岸本齊史;
                                url = https://zh.wikipedia.org/wiki/火影忍者;
                            }
                        }
                    
  
  [_dsync syncWithUserId: _userId
               tableName: _tableName
              dictionary: record
                  shadow: shadow
           shouldReplace: ^BOOL(id oldValue, id newValue) {
                          return YES;
            } completion: ^(NSDictionary *diff, NSError *error) {
    
   }];

```

```objective-c
NSDictionary *diff = {
                      @"_add": { },
                      @"_delete": {
                                  Naruto =         {
                                author = 岸本齊史;
                                url = https://zh.wikipedia.org/wiki/火影忍者;
                            };
                      },
                      @"_replace": {
                      
                      }
                   };
```


```objective-c
NSArray *bookmarks = [DSWrapper arrayFromDict: self.localBookmark[@"_dicts"]];
NSDictionary *bookmark = bookmarks[indexPath.row];
/*
Bookmark:   {
               comicName = One Piece;
               author = 尾田榮一郎;
               url = https://zh.wikipedia.org/wiki/ONE_PIECE;
           };
*/

```

** Error Handling**


```objective-c
+(DSError *)mergePushFailed {
  return [[DSError alloc] initWithDomain: @"com.BookmarkManager.mergrPushError" code: 1 userInfo: nil];
}

+(DSError *)forcePushFailed {
  return [[DSError alloc] initWithDomain: @"com.BookmarkManager.forcePushConflict" code: 2 userInfo: nil];
}

+(DSError *)pullFailed {
  return [[DSError alloc] initWithDomain: @"com.BookmarkManager.pullError" code: 3 userInfo: nil];
}

+(DSError *)remoteDataNil {
  return [[DSError alloc] initWithDomain: @"com.BookmarkManager.remoteDataNil" code: 4 userInfo: nil];
}

+(DSError *)noInternet {
  return [[DSError alloc] initWithDomain: @"com.BookmarkManager.noInternet" code: 5 userInfo: nil];
}

```


## Author

lyc2345, lyc2345@gmail.com

## License

AWSWrapper is available under the MIT license. See the LICENSE file for more info.
