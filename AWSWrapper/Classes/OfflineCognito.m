//
//  OfflineCognito.m
//  Pods
//
//  Created by Stan Liu on 29/07/2017.
//
//

NSString * const __OFFLILNE_USER_SERVICE = @"__OFFLILNE_USER_SERVICE";

#import "OfflineCognito.h"
@import SAMKeychain;

@implementation OfflineCognito

- (instancetype)init
{
  self = [super init];
  if (self) {
    
  }
  return self;
}

+(OfflineCognito *)shared {
  
  static OfflineCognito *cognito = nil;
  
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    
    cognito = [OfflineCognito new];
  });
  return cognito;
}

-(NSString *)password {
  
  NSError *error = nil;
  return [SAMKeychain passwordForService: __OFFLILNE_USER_SERVICE account: [[NSUserDefaults standardUserDefaults] stringForKey: @"__CURRENT_USER"] error: &error];
}


-(void)storeUsername:(NSString *)username password:(NSString *)password {
  
  NSError *error = nil;
  SAMKeychainQuery *query = [[SAMKeychainQuery alloc] init];
  query.service = __OFFLILNE_USER_SERVICE;
  [query setAccount: username];
  [query setPassword: password];
  [query save: &error];
  
  if (error) {
    NSLog(@"lock store user info error: %@", error.localizedDescription);
  }
}

-(BOOL)verifyUsername:(NSString *)username password:(NSString *)password {
  
  NSError *error = nil;
  NSString *pw = [SAMKeychain passwordForService: __OFFLILNE_USER_SERVICE account: username error: &error];
  if (!error) {
    return [pw isEqualToString: password] ? YES : NO;
  }
  NSLog(@"verify error: %@", error.localizedDescription);
  return NO;
}

-(void)modifyUsername:(NSString *)username
             password:(NSString *)password {
  [self storeUsername: username password: password];
}

-(NSArray *)allAccount:(NSError * __autoreleasing *)error {
  return [SAMKeychain accountsForService: __OFFLILNE_USER_SERVICE error: error];
}


@end
