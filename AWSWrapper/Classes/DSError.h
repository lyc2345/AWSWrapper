//
//  DSError.h
//  Pods
//
//  Created by Stan Liu on 14/06/2017.
//
//

#import <Foundation/Foundation.h>

@interface DSError : NSError

+(DSError *)mergePushFailed;
+(DSError *)forcePushFailed;
+(DSError *)pullFailed;
+(DSError *)remoteDataNil;
+(DSError *)noInternet;


@end
