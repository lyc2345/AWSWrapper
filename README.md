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
``` objective-c
if ([LoginManager shared].isLogin) {
  [[LoginManager shared] loginOfflineWithUser: username password: password completion:^(NSError *error) {
    if (!error) {
      [weakSelf.navigationController popViewControllerAnimated: YES];
    }
  }];
}
```

**Bookmark**

* User offline add, get, delete all the time.
* Use pullType in the application DidFinishLaunch to get the latest data on the server.
* Use mergePushType when terminate applicatioin.


```objective-c
// Online
/**
 @param type AWS Model Type (e.g. RecordTypebookmark)
 @param userId AWS identityID
 @param completionHandler The handler will be ran once the task is completion.
 
 item is pure dictionary object for bookmark record.
 */
-(void)pullType:(RecordType)type user:(NSString *)userId completion:(void(^)(NSDictionary *item, NSError *error))completionHandler;

/**
 @param type Bookmark or RecentlyVisit
 @param userId AWS identity id
 @param mergeCompletion return error
 */
-(void)mergePushType:(RecordType)type userId:(NSString *)userId completion:(void(^)(NSDictionary *responseItem, NSError *error))mergeCompletion;
```

```objective-c
// Offline
-(NSDictionary *)getOfflineRecordOfIdentity:(NSString *)identity type:(RecordType)type;
-(void)addOffline:(NSDictionary *)r type:(RecordType)type ofIdentity:(NSString *)identity;
-(NSDictionary *)deleteOffline:(NSDictionary *)r type:(RecordType)type ofIdentity:(NSString *)identity;
```




## Author

lyc2345, lyc2345@gmail.com

## License

AWSWrapper is available under the MIT license. See the LICENSE file for more info.
