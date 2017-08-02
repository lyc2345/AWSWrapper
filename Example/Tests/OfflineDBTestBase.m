//
//  OfflineDBTestBase.m
//  AWSWrapper
//
//  Created by Stan Liu on 02/08/2017.
//  Copyright © 2017 lyc2345. All rights reserved.
//

#import "OfflineDBTestBase.h"

@interface OfflineDBTestBase ()

@property OfflineDB *offlineDB;

@end

@implementation OfflineDBTestBase

- (instancetype)init
{
  self = [super init];
  if (self) {
  
    self.offlineDB = [OfflineDB new];
    
  }
  return self;
}

-(NSDictionary *)shadowIsBookmark:(BOOL)isBookmark {
  return [OfflineDB shadowIsBookmark: isBookmark];
}

-(BOOL)setShadow:(NSDictionary *)dict isBookmark:(BOOL)isBookmark {
  return [OfflineDB setShadow: dict isBookmark: isBookmark];
}

-(void)addOffline:(NSDictionary *)r type:(RecordType)type ofIdentity:(NSString *)identity {
  [self.offlineDB addOffline: r type: type ofIdentity: identity];
}

-(NSDictionary *)deleteOffline:(NSDictionary *)r type:(RecordType)type ofIdentity:(NSString *)identity {
  return [self.offlineDB deleteOffline: r type: type ofIdentity: identity];
}

-(NSDictionary *)getOfflineRecordOfIdentity:(NSString *)identity type:(RecordType)type {
  return [self.offlineDB getOfflineRecordOfIdentity: identity type: type];
}

@end
