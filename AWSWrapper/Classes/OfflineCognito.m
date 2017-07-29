//
//  OfflineCognito.m
//  Pods
//
//  Created by Stan Liu on 29/07/2017.
//
//

#import "OfflineCognito.h"
#import <SAMKeychain/SAMKeychain.h>

NSString * const __CURRENT_USER = @"__CURRENT_USER";
NSString * const __USER_LIST		= @"__USER_LIST";

@implementation OfflineCognito

-init

+(void)storeUsername:(NSString *)user password:(NSString *)password {
  
  NSError *error = nil;
  SAMKeychainQuery *query = [[SAMKeychainQuery alloc] init];
  query.service = __USER_LIST;
  [query setAccount: username];
  [query setPassword: password];
  [query save: &error];
  
  if (error) {
    NSLog(@"lock store user info error: %@", error);
  }
}

+(NSString *)loadPasswordOfUser:(NSString *)user {
  
  NSError *error = nil;
  NSArray <NSDictionary <NSString *, id> *> *accounts = [SAMKeychain accountsForService: __USER_LIST error: &error];
  __block bool isExist = false;
  
  [accounts enumerateObjectsUsingBlock:^(NSDictionary<NSString *,id> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
    if ([obj[kSAMKeychainAccountKey] isEqualToString: user]) {
      isExist = true;
      return;
    }
  }];
  
  if (isExist) {
    return [SAMKeychain passwordForService: __USER_LIST account: user];
  }
  return nil;
}

+(NSArray *)allAccount {
  
  [SAMKeychain accountsForService: __USER_LIST];
}


+(NSString *)currentUser {
  
  return [[NSUserDefaults standardUserDefaults] stringForKey: __CURRENT_USER];
}

@end
