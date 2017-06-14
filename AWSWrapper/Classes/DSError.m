//
//  DSError.m
//  Pods
//
//  Created by Stan Liu on 14/06/2017.
//
//

#import "DSError.h"

@implementation DSError

+(DSError *)mergePushConflict {
  return [[DSError alloc] initWithDomain: @"com.BookmarkManager.mergrPushError" code: 0 userInfo: nil];
}

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

+(DSError *)serverWasReset {
  return [[DSError alloc] initWithDomain: @"com.BookmarkManager.serverWasReset" code: 5 userInfo: nil];
}

+(DSError *)noInternet {
  return [[DSError alloc] initWithDomain: @"com.BookmarkManager.noInternet" code: 6 userInfo: nil];
}

@end
