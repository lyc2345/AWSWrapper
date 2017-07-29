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
NSString * const __OFFLILNE_USER_SERVICE = @"__OFFLILNE_USER_SERVICE";

@interface OfflineCognito ()

@end

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

-(void)modifyUsername:(NSString *)username password:(NSString *)password identity:(NSString *)identity {
  
  [self storeUsername: username password: password];
}

//-(NSString *)loadPasswordOfUser:(NSString *)user error:(NSError *)error {

//  NSError *loadAllAccountError = nil;
//  NSArray <NSDictionary <NSString *, id> *> *accounts = [self allAccount: &loadAllAccountError];
//  
//  if (loadAllAccountError) {
//    NSLog(@"load account error: %@", loadAllAccountError);
//    return nil;
//  }
//  __block bool isExist = false;
//  
//  [accounts enumerateObjectsUsingBlock:^(NSDictionary<NSString *,id> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//    
//    if ([obj[kSAMKeychainAccountKey] isEqualToString: user]) {
//      isExist = true;
//      return;
//    }
//  }];
//  
//  if (isExist) {
//    return [SAMKeychain passwordForService: __USER_LIST account: user];
//  }
//  error = [NSError errorWithDomain: @"com.stan.loginmanager" code: 1 userInfo: @{@"description": @"User doesn't exist"}];
//  return nil;
//}

-(NSArray *)allAccount:(NSError * __autoreleasing *)error {
  
  //NSArray <NSDictionary <NSString *, id> *> *accounts = [SAMKeychain accountsForService: __USER_LIST error: &error];
  return [SAMKeychain accountsForService: __OFFLILNE_USER_SERVICE error: error];
}


@end
