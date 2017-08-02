//
//  OfflineDBTestBase.h
//  AWSWrapper
//
//  Created by Stan Liu on 02/08/2017.
//  Copyright © 2017 lyc2345. All rights reserved.
//

#import <Foundation/Foundation.h>
@import AWSWrapper;

@interface OfflineDBTestBase : NSObject

+(NSDictionary *)shadowIsBookmark:(BOOL)isBookmark;

+(BOOL)setShadow:(NSDictionary *)dict isBookmark:(BOOL)isBookmark;

-(void)addOffline:(NSDictionary *)r type:(RecordType)type ofIdentity:(NSString *)identity;

-(NSDictionary *)deleteOffline:(NSDictionary *)r type:(RecordType)type ofIdentity:(NSString *)identity;

-(NSDictionary *)getOfflineRecordOfIdentity:(NSString *)identity type:(RecordType)type;

@end
