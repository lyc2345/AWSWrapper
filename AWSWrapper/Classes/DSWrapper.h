//
//  DSWrapper.h
//  DS
//
//  Created by Stan Liu on 11/05/2017.
//  Copyright © 2017 lyc2345. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DSWrapper : NSObject

//+(NSDictionary *)differentialMergeBetweenClient:(NSDictionary *)client andRemote:(NSDictionary *)remote;
//+(NSDictionary *)differentialMergeWithClient:(NSDictionary *)client;

+(NSArray *)arrayFromDict:(NSDictionary *)dict;
+(NSDictionary *)dictFromArray:(NSArray *)array;

+(NSDictionary *)diffShadowAndClient:(NSDictionary *)client isBookmark:(BOOL)isBookmark;


+(NSDictionary *)diffShadowAndClient:(NSDictionary *)client
                          primaryKey:(NSString *)key
                          isBookmark:(BOOL)isBookmark
                       shouldReplace:(BOOL(^)(id oldValue, id newValue))shouldReplace;


+(NSDictionary *)diffWins:(NSDictionary *)wins andLoses:(NSDictionary *)loses;


+(NSDictionary *)diffWins:(NSDictionary *)wins
                 andLoses:(NSDictionary *)loses
               primaryKey:(NSString *)key
            shouldReplace:(BOOL(^)(id oldValue, id newValue))shouldReplace;


+(NSDictionary *)mergeInto:(NSDictionary *)into applyDiff:(NSDictionary *)diff;



@end

@interface DSWrapper (FakeData)

// This is for test
+(void)setClient:(NSArray *)list;
+(void)setSimulateRemote:(NSArray *)list;

@end
