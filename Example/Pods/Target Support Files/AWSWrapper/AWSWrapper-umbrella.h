#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "Alert.h"
#import "AWSMobileClient.h"
#import "Bookmark.h"
#import "BookmarkManager.h"
#import "DSError.h"
#import "DSWrapper.h"
#import "DynamoSync.h"
#import "Encrypt.h"
#import "LoginManager.h"
#import "OfflineDB.h"
#import "Random.h"
#import "RecentVisit.h"
#import "RecordSuitable.h"
#import "SignInViewController.h"
#import "UserPoolForgotPasswordViewController.h"
#import "UserPoolMFAViewController.h"
#import "UserPoolSignUpViewController.h"

FOUNDATION_EXPORT double AWSWrapperVersionNumber;
FOUNDATION_EXPORT const unsigned char AWSWrapperVersionString[];

