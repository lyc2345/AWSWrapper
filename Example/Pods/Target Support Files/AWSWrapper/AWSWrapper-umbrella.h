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

#import "AWSConfiguration.h"
#import "AWSMobileClient.h"
#import "AWSWrapper.h"
#import "Bookmark.h"
#import "NoSQLModelHelpers.h"
#import "RecentVisit.h"
#import "RecordSuitable.h"

FOUNDATION_EXPORT double AWSWrapperVersionNumber;
FOUNDATION_EXPORT const unsigned char AWSWrapperVersionString[];

