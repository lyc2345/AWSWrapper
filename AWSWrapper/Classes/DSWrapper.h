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

+(NSDictionary *)shadowIsBookmark:(BOOL)isBookmark;
+(void)setShadow:(NSDictionary *)dict isBookmark:(BOOL)isBookmark;


+(NSDictionary *)diffShadowAndClient:(NSDictionary *)client isBookmark:(BOOL)isBookmark;
+(NSDictionary *)diffWins:(NSDictionary *)wins andLoses:(NSDictionary *)loses;
+(NSDictionary *)applyInto:(NSDictionary *)into From:(NSDictionary *)diff;



@end

@interface DSWrapper (FakeData)

// This is for test
+(void)setClient:(NSArray *)list;
+(void)setSimulateRemote:(NSArray *)list;

@end
