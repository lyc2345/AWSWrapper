//
//  OfflineCognito.m
//  Pods
//
//  Created by Stan Liu on 29/07/2017.
//
//

NSString * const __OFFLINE_USER_SERVICE = @"__OFFLINE_USER_SERVICE";
NSString * const __OFFLINE_USER_LIST    = @"__OFFLINE_USER_LIST";

#import "OfflineCognito.h"
#import "Encrypt.h"
#import "DLog.h"
@import SAMKeychain;

@implementation OfflineCognito

- (instancetype)init
{
  self = [super init];
  if (self) {
    
  }
  return self;
}

-(NSString *)OFFLINE_USER_SERVICE {
  return __OFFLINE_USER_SERVICE;
}

-(NSString *)OFFLINE_USER_LIST {
  return __OFFLINE_USER_LIST;
}

+(OfflineCognito *)shared {
  
  static OfflineCognito *cognito = nil;
  
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    
    cognito = [OfflineCognito new];
  });
  return cognito;
}

-(NSString *)currentUser {
  return [[NSUserDefaults standardUserDefaults] stringForKey: @"__CURRENT_USER"];
}

-(NSString *)password {
  
  NSError *error = nil;
  return [SAMKeychain passwordForService: self.OFFLINE_USER_SERVICE account: self.currentUser error: &error];
}

-(NSString *)identityId {
  
  return [self offlineLoadIdentityIdFromUsername: self.currentUser];
}

-(void)storeUsername:(NSString *)username
            password:(NSString *)password
          identityId:(NSString *)identityId {
  
  if (!username || !identityId || !password) {
    DLOG(@"save username or identityId or password is nil");
    return;
  }
  
  NSError *error = nil;
  SAMKeychainQuery *query = [[SAMKeychainQuery alloc] init];
  query.service = self.OFFLINE_USER_SERVICE;
  [query setAccount: username];
  [query setPassword: password];
  [query save: &error];
  
  if (error) {
    DLOG(@"lock store user info error: %@", error.localizedDescription);
  }
  [self saveProfileFromUsername: username identityId: identityId];
}

-(BOOL)verifyUsername:(NSString *)username
             password:(NSString *)password {
  
  if (!username || !password) {
    DLOG(@"varify username or password is nil");
    return NO;
  }
  
  NSError *error = nil;
  NSString *pw = [SAMKeychain passwordForService: self.OFFLINE_USER_SERVICE account: username error: &error];
  if (!error) {
    return [pw isEqualToString: password] ? YES : NO;
  }
  DLOG(@"verify error: %@", error.localizedDescription);
  return NO;
}

-(void)modifyUsername:(NSString *)username
             password:(NSString *)password
           identityId:(NSString *)identityId {
  [self storeUsername: username password: password identityId: identityId];
}

-(NSArray *)allAccount:(NSError * __autoreleasing *)error {
  return [SAMKeychain accountsForService: self.OFFLINE_USER_SERVICE error: error];
}

-(void)saveProfileFromUsername:(NSString *)username identityId:(NSString *)identityId {
  
  if (!username || !identityId) {
    DLOG(@"save username or identityId is nil");
    return;
  }
  
  NSString *userAKA = [Encrypt SHA512From: username];
  NSMutableArray *userList = [[[NSUserDefaults standardUserDefaults] arrayForKey: self.OFFLINE_USER_LIST] mutableCopy];
  if (!userList) {
    userList = [NSMutableArray array];
  }
  
  NSDictionary *userProfile = @{@"_username": userAKA, @"_identityId": identityId};
  __block BOOL isExist = NO;
  [userList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
    
    if ([obj[@"_username"] isEqualToString: userAKA]) {
      
      isExist = YES;
      *stop = YES;
    }
    if (*stop) {
      [userList replaceObjectAtIndex: idx withObject: userProfile];
      return;
    }
  }];
  
  if (!isExist) {
    [userList addObject: userProfile];
  }
  [[NSUserDefaults standardUserDefaults] setObject: userList forKey: self.OFFLINE_USER_LIST];
}

-(NSString *)offlineLoadIdentityIdFromUsername:(NSString *)username {
  
  if (!username) {
    DLOG(@"username is nil");
  }
  
  NSArray *userList = [[NSUserDefaults standardUserDefaults] arrayForKey: self.OFFLINE_USER_LIST];
  NSString *userAKA = [Encrypt SHA512From: username];
  
  __block NSDictionary *readyForReturn =  nil;
  [userList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
    if ([obj[@"_username"] isEqualToString: userAKA]) {
      readyForReturn = obj;
      *stop = YES;
      return;
    }
  }];
  return readyForReturn != nil ? readyForReturn[@"_identityId"] : nil;
}


@end
