//
//  OfflineCognitoDBTestBase.m
//  AWSWrapper
//
//  Created by Stan Liu on 29/07/2017.
//  Copyright © 2017 lyc2345. All rights reserved.
//

#import "OfflineCognitoTestBase.h"
@import AWSWrapper;

@interface OfflineCognitoTestBase ()

@property OfflineCognito *cognito;

@end

@implementation OfflineCognitoTestBase

- (instancetype)init
{
  self = [super init];
  if (self) {
    
  }
  return self;
}

+(OfflineCognitoTestBase *)shared {
  
  static OfflineCognitoTestBase *cognito = nil;
  
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    
    cognito = [OfflineCognitoTestBase new];
  });
  return cognito;
}


-(NSString *)password {
  return [_cognito password];
}


-(void)storeUsername:(NSString *)username password:(NSString *)password {
  [_cognito storeUsername: username password: password];
}

-(BOOL)verifyUsername:(NSString *)username password:(NSString *)password {
  return [_cognito verifyUsername: username password: password];
}

-(void)modifyUsername:(NSString *)username
             password:(NSString *)password {
  [_cognito modifyUsername: username password: password];
}

-(NSArray *)allAccount:(NSError * __autoreleasing *)error {
  return [_cognito allAccount: error];
}

@end
