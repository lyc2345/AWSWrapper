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
2. create Bookmark and History "Amazon DynamoDb Tables" 
![Amazon DynamoDb Tables](https://github.com/lyc2345/AWSWrapper/blob/master/screenshot/Screen%20Shot%202017-07-23%20at%2017.21.30.png)
3. create "Amazon Cognito Idnentity Pools", User sign-in only use Email and Password. 
![Cognito Idnentity Pools](https://github.com/lyc2345/AWSWrapper/blob/master/screenshot/Screen%20Shot%202017-07-23%20at%2017.21.49.png)
4. set up .plist according to 
   1. Integrate > iOS Obj-C > Getting Started > OPTION 2
   2. OR You can see the plist in DEMO project.
![Integrate](https://github.com/lyc2345/AWSWrapper/blob/master/screenshot/Screen%20Shot%202017-07-23%20at%2017.19.52.png)



```objective-c

// Example
AWSMobileClient *mobileClient = [AWSMobileClient sharedInstance];
mobileClient.AWSCognitoUserPoolId = @"";
mobileClient.AWSCognitoUserPoolClientId = @"";
mobileClient.AWSCognitoUserPoolClientSecret = @"";
mobileClient.AWSCognitoUserPoolRegion = AWSRegionUSEast1;
mobileClient.CognitoPoolID = @"";

```

### Turn on Debug Mode
1. Choose pod project in your workspace
2. Choose AWSWrapper in pod project
3. Select `build settings` -> find `Preprocessor Macros` -> add `debugMode=1` in DEBUG shows below
![DebugMode](https://github.com/lyc2345/AWSWrapper/blob/master/screenshot/Screen%20Shot%202017-08-13%20at%2015.54.51.png)

### Documentation
[Documentation](https://github.com/lyc2345/AWSWrapper/wiki/Documentation)



## Author

lyc2345, lyc2345@gmail.com

## License

AWSWrapper is available under the MIT license. See the LICENSE file for more info.
