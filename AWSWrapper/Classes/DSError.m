//
//  DSError.m
//  Pods
//
//  Created by Stan Liu on 14/06/2017.
//
//

#import "DSError.h"

@implementation DSError

+(DSError *)mergePushFailed {
  return [[DSError alloc] initWithDomain: @"com.DynamoService.mergrPushError" code: 1 userInfo: nil];
}

+(DSError *)forcePushFailed {
  return [[DSError alloc] initWithDomain: @"com.DynamoService.forcePushConflict" code: 2 userInfo: nil];
}

+(DSError *)pullFailed {
  return [[DSError alloc] initWithDomain: @"com.DynamoService.pullError" code: 3 userInfo: nil];
}

+(DSError *)remoteDataNil {
  return [[DSError alloc] initWithDomain: @"com.DynamoService.remoteDataNil" code: 4 userInfo: nil];
}

+(DSError *)noInternet {
  return [[DSError alloc] initWithDomain: @"com.DynamoService.noInternet" code: 5 userInfo: nil];
}

@end
