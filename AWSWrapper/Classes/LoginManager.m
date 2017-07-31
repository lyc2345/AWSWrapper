//
//  LoginManager.m
//  LoginManager
//
//  Created by Stan Liu on 16/03/2017.
//  Copyright © 2017 Stan Liu. All rights reserved.
//

#import "LoginManager.h"
#import "OfflineCognito.h"
@import AWSMobileHubHelper.AWSIdentityManager;
@import AWSMobileHubHelper.AWSCognitoUserPoolsSignInProvider;
@import AWSMobileHubHelper.AWSContentManager;

NSString * const __CURRENT_USER = @"__CURRENT_USER";

@interface LoginManager () <AWSCognitoUserPoolsSignInHandler>

@property (nonatomic, strong) NSString *tmpPassword;
@property (nonatomic, strong) NSString *tmpIdentity;

@property (strong, nonatomic) AWSCognitoIdentityUserPool *userPool;
@property (strong, nonatomic) AWSCognitoIdentityUser * identityUser;

@property (nonatomic, strong) AWSTaskCompletionSource<AWSCognitoIdentityPasswordAuthenticationDetails*>* passwordAuthenticationCompletion;

@end

@implementation LoginManager

- (instancetype)init
{
	self = [super init];
	if (self) {
		
		self.userPool = [AWSCognitoIdentityUserPool CognitoIdentityUserPoolForKey: AWSCognitoUserPoolsSignInProviderKey];
		
		 __weak LoginManager *waekSelf = self;
		[[NSNotificationCenter defaultCenter] addObserverForName: AWSIdentityManagerDidSignInNotification
																											object: [AWSIdentityManager defaultIdentityManager]
																											 queue: [NSOperationQueue mainQueue]
																									usingBlock: ^(NSNotification * _Nonnull note) {
																										
																										waekSelf.AWSLoginStatusChangedHandler != nil ?waekSelf.AWSLoginStatusChangedHandler() : nil;
																										
																									}];
		
		[[NSNotificationCenter defaultCenter] addObserverForName: AWSIdentityManagerDidSignOutNotification
																											object: [AWSIdentityManager defaultIdentityManager]
																											 queue: [NSOperationQueue mainQueue]
																									usingBlock: ^(NSNotification * _Nonnull note) {
																										
																										waekSelf.AWSLoginStatusChangedHandler != nil ?waekSelf.AWSLoginStatusChangedHandler() : nil;
																										
																									}];

	}
	return self;
}

+(LoginManager *)shared {
	
	static LoginManager *manager = nil;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		
		manager = [[LoginManager alloc] init];
	});
	return manager;
}

-(BOOL)isLogin {
	
	NSString *u = [[NSUserDefaults standardUserDefaults] stringForKey: __CURRENT_USER];
	
	if (!u) {
		return NO;
	}
	return YES;
}

-(NSString *)user {
	
	NSString *u = [[NSUserDefaults standardUserDefaults] stringForKey: __CURRENT_USER];
	return u != nil ? u : nil ;
}

-(NSString *)password {
  return self.user != nil ? [[OfflineCognito shared] password] : nil;
}

-(NSString *)offlineIdentity {
	
	return self.tmpIdentity != nil ? self.tmpIdentity : nil;
}


#pragma mark - AWSCognitoUserPoolsSignInHandler

-(void)handleUserPoolSignInFlowStart {
  
  NSString *username;
  NSString *password;
  
  if (!self.userPoolSignInFlowStartUserName && !self.userPoolSignInFlowStartPassword) {
    
    NSLog(@"handleUserPoolSignInFlowStart is error in function: %s, line: %d", __FUNCTION__, __LINE__);
    NSLog(@"userPoolSignInFlowStartUserName || userPoolSignInFlowStartPassword is null");
    username = self.user;
    password = self.password;
    
  } else {
    username = self.userPoolSignInFlowStartUserName();
    password = self.userPoolSignInFlowStartPassword();
  }
  
  self.passwordAuthenticationCompletion.result = [[AWSCognitoIdentityPasswordAuthenticationDetails alloc] initWithUsername: username password: password];
}

@end


#pragma mark - Offline

@implementation LoginManager (Offline)

-(void)loginOfflineWithUser:(NSString *)user password:(NSString *)password completion:(void(^)(NSError *error))completion {
	
  bool isQualified = [[OfflineCognito shared] verifyUsername: user password: password];
	
	NSError *error;
	
	if (isQualified) {
		
		[[NSUserDefaults standardUserDefaults] setObject: user forKey: __CURRENT_USER];
		NSLog(@"offline login success with user: %@", [[NSUserDefaults standardUserDefaults] stringForKey: __CURRENT_USER]);
	} else {
		
		// To remind user there are not qualified for offline login (because they are not had been register AWS yet)
		[[NSUserDefaults standardUserDefaults] setObject: nil forKey: __CURRENT_USER];
		NSLog(@"offline login failure with user: %@", user);
		error = [NSError errorWithDomain: @"com.stan.loginmanager" code: 1 userInfo: @{@"description": @"offline login failure"}];
		
	}
	completion(error);
}

-(void)logoutOfflineCompletion:(void(^)())completion {
	
	[[NSUserDefaults standardUserDefaults] setObject: nil forKey: __CURRENT_USER];
	NSLog(@"offline logout successfully");
  completion();
}

@end

#pragma mark - AWS

@implementation LoginManager (AWS)

-(NSString *)awsDidSignInNotificationName {
	
	return AWSIdentityManagerDidSignInNotification;
}

-(NSString *)awsDidSignOutNotificationName {
	
	return AWSIdentityManagerDidSignOutNotification;
}

-(BOOL)isAWSLogin {
	
	return [[AWSIdentityManager defaultIdentityManager] isLoggedIn];
}

-(NSString *)awsIdentityId {
	
	return [AWSIdentityManager defaultIdentityManager].identityId;
}

-(void)signUpWithUser:(NSString *)username
             password:(NSString *)password
                email:(NSString *)email
                  tel:(NSString *)telephone
        waitToConfirm:(void(^)(NSString *destination))waitToConfirmAction
              success:(void(^)())successHandler
                 fail:(void(^)(NSError *error))failHandler {
	
	NSMutableArray * attributes = [NSMutableArray new];
	AWSCognitoIdentityUserAttributeType * phoneAttribute = [AWSCognitoIdentityUserAttributeType new];
	phoneAttribute.name = @"phone_number";
	phoneAttribute.value = telephone;
	AWSCognitoIdentityUserAttributeType * emailAttribute = [AWSCognitoIdentityUserAttributeType new];
	emailAttribute.name = @"email";
	emailAttribute.value = email;
	
	if(![@"" isEqualToString:phoneAttribute.value]){
		[attributes addObject: phoneAttribute];
	}
	if(![@"" isEqualToString:emailAttribute.value]){
		[attributes addObject: emailAttribute];
	}
	
	if (!self.userPool) {
		self.userPool = [AWSCognitoIdentityUserPool CognitoIdentityUserPoolForKey: AWSCognitoUserPoolsSignInProviderKey];
	}

	[[self.userPool signUp: username password: password userAttributes: attributes validationData:nil] continueWithBlock:^id _Nullable(AWSTask<AWSCognitoIdentityUserPoolSignUpResponse *> * _Nonnull task) {
		NSLog(@"Successful signUp user: %@",task.result.user.username);
		dispatch_async(dispatch_get_main_queue(), ^{
			if(task.error){
				
				failHandler(task.error);
				
			} else if (task.result.user.confirmedStatus != AWSCognitoIdentityUserStatusConfirmed){

				// success signup but still needs to confirm.
				// Show the Confirm action way destination, e.g. phone, email... etc
				NSLog(@"code delivery detail attributeName: %@", task.result.codeDeliveryDetails.attributeName);
				NSLog(@"code delivery detail destination: %@", task.result.codeDeliveryDetails.destination);
				
				waitToConfirmAction(task.result.codeDeliveryDetails.destination);
				self.tmpPassword = password;
			} else {
        [[OfflineCognito shared] storeUsername: username password: password];
				successHandler();
			}});
		return nil;
	}];
}

-(void)confirmSignUpWithUser:(NSString *)username confirmCode:(NSString *)confirmCode success:(void(^)())successHandler fail:(void(^)(NSError *error))failHandler {
	
	self.identityUser = [self.userPool getUser: username];
	
	[[self.identityUser confirmSignUp: confirmCode forceAliasCreation: YES] continueWithBlock:^id _Nullable(AWSTask<AWSCognitoIdentityUserConfirmSignUpResponse *> * _Nonnull task) {
		
		dispatch_async(dispatch_get_main_queue(), ^{
			if(task.error){
				if(task.error){
					failHandler(task.error);
				}
			} else {
				//return to initial screen
        [[OfflineCognito shared] storeUsername: username password: self.tmpPassword];
				successHandler();
			}
		});
		return nil;
	}];
}

-(void)onResendOfUser:(NSString *)username success:(void(^)(NSString *destination))successHandler fail:(void(^)(NSError *error))failHandler {
	
	//resend the confirmation code
	self.identityUser = [self.userPool getUser: username];
	
	[[self.identityUser resendConfirmationCode] continueWithBlock:^id _Nullable(AWSTask<AWSCognitoIdentityUserResendConfirmationCodeResponse *> * _Nonnull task) {
		dispatch_async(dispatch_get_main_queue(), ^{
			if(task.error){

				failHandler(task.error);
			}else {
				
				successHandler(task.result.codeDeliveryDetails.destination);
			}
		});
		return nil;
	}];
}

-(void)forgotPasswordOfUser:(NSString *)username completion:(void(^)(NSError *error))completion {
	
	self.identityUser = [self.userPool getUser: username];
	
	[[self.identityUser forgotPassword] continueWithBlock:^id _Nullable(AWSTask<AWSCognitoIdentityUserForgotPasswordResponse *> * _Nonnull task) {
		
		dispatch_async(dispatch_get_main_queue(), ^{
			
			completion(task.error);
		});
		return nil;
	}];
}

-(void)confirmForgotNewPassword:(NSString *)newPassword
										confirmCode:(NSString *)confirmCode
												success:(void(^)())successHandler
													 fail:(void(^)(NSError *error))failHandler{
	
	[[self.identityUser confirmForgotPassword: confirmCode password: newPassword] continueWithBlock:^id _Nullable(AWSTask<AWSCognitoIdentityUserConfirmForgotPasswordResponse *> * _Nonnull task) {
		dispatch_async(dispatch_get_main_queue(), ^{
			if(task.error){
				failHandler(task.error);
			} else {
				successHandler();
			}
		});
		return nil;
	}];
}

-(void)login:(void(^)(id _Nullable result, NSError * _Nullable error))completion {
	
	__weak typeof(self) weakSelf = self;
	
	[[AWSCognitoUserPoolsSignInProvider sharedInstance] setInteractiveAuthDelegate: self];
	
	[[AWSIdentityManager defaultIdentityManager] loginWithSignInProvider: [AWSCognitoUserPoolsSignInProvider sharedInstance] completionHandler:^(id  _Nullable result, NSError * _Nullable error) {
		
		if (!error) {
			NSLog(@"user login successfully with result: %@", result);
			
			NSString *username = weakSelf.userPoolSignInFlowStartUserName();
			NSString *password = weakSelf.userPoolSignInFlowStartPassword();
			
      [[OfflineCognito shared] modifyUsername: username password: password];
			[weakSelf loginOfflineWithUser: username password: password completion:^(NSError *error) {
				if (!error) {
					weakSelf.AWSLoginStatusChangedHandler();
				}
			}];
		}
		
		completion(result, error);
	}];
}


-(void)logout:(void(^)(id result, NSError *error))completion {
  
  __weak typeof(self) weakSelf = self;
		
		[[AWSIdentityManager defaultIdentityManager] logoutWithCompletionHandler:^(id result, NSError *error) {
      
      if (!error) {
        [[AWSIdentityManager defaultIdentityManager].credentialsProvider clearKeychain];
        [[AWSIdentityManager defaultIdentityManager].credentialsProvider clearCredentials];
        [weakSelf logoutOfflineCompletion:^ {
          NSLog(@"user log out successfully.");
          weakSelf.AWSLoginStatusChangedHandler();
        }];
      }
      //NSLog(@"%@: %@ Logout Successful", LOG_TAG, [signInProvider getDisplayName]);
      completion(result, error);
    }];
}

#pragma mark - AWSCognitoIdentityInteractiveAuthentication Delegate

//set up password authentication ui to retrieve username and password from the user
-(id<AWSCognitoIdentityPasswordAuthentication>) startPasswordAuthentication {
	return self;
}

-(id<AWSCognitoIdentityMultiFactorAuthentication>) startMultiFactorAuthentication {
	
	return self.startMultiFactorAuthenticationHandler();
}

#pragma mark - AWSCognitoIdentityPasswordAuthentication Delegate

-(void) getPasswordAuthenticationDetails: (AWSCognitoIdentityPasswordAuthenticationInput *) authenticationInput  passwordAuthenticationCompletionSource: (AWSTaskCompletionSource<AWSCognitoIdentityPasswordAuthenticationDetails *> *) passwordAuthenticationCompletionSource {
	
	self.passwordAuthenticationCompletion = passwordAuthenticationCompletionSource;
	dispatch_async(dispatch_get_main_queue(), ^{
		self.authenticationUsernameHandler(authenticationInput.lastKnownUsername);
	});
}

-(void) didCompletePasswordAuthenticationStepWithError:(NSError*) error {
	if(error){
		dispatch_async(dispatch_get_main_queue(), ^{
			self.didCompletePasswordAuthenticationStepWithErrorHandler(error);
		});
	}
}

#pragma mark - AWSCognitoIdentityMultiFactorAuthentication Delegate

-(void)getMultiFactorAuthenticationCode:(AWSCognitoIdentityMultifactorAuthenticationInput *)authenticationInput mfaCodeCompletionSource:(AWSTaskCompletionSource<NSString *> *)mfaCodeCompletionSource {
	
	self.getMultiFactorAuthenticationCode( authenticationInput, mfaCodeCompletionSource);
}

-(void)didCompleteMultifactorAuthenticationStepWithError:(NSError *)error {
	
	self.multifactorAuthenticationStepWithError(error);
}

@end


//
//-(void)lockerStoreUsername:(NSString *)username password:(NSString *)password {
//
//	NSError *error = nil;
//	SAMKeychainQuery *query = [[SAMKeychainQuery alloc] init];
//	query.service = @"__USER_LIST";
//	[query setAccount: username];
//	[query setPassword: password];
//	[query save: &error];
//
//	if (error) {
//		NSLog(@"lock store user info error: %@", error);
//	}
//}
//
//-(NSString *)lockerLoadPasswordOfUser:(NSString *)user {
//
//	NSError *error = nil;
//	NSArray <NSDictionary <NSString *, id> *> *accounts = [SAMKeychain accountsForService: @"__USER_LIST" error: &error];
//	__block bool isExist = false;
//
//	[accounts enumerateObjectsUsingBlock:^(NSDictionary<NSString *,id> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//		if ([obj[kSAMKeychainAccountKey] isEqualToString: user]) {
//			isExist = true;
//			return;
//		}
//	}];
//
//	if (isExist) {
//		return [SAMKeychain passwordForService: @"__USER_LIST" account: user];
//	}
//	return nil;
//}


//+(NSDictionary *)userFormatOfUser:(NSString *)user password:(NSString *)password identity:(NSString *)identity {
//
//	NSString *hashPassword = [Encrypt SHA512From: password];
//
//	return @{@"_user": user, @"_password": hashPassword, @"_userId": identity != nil ? identity : @""};
//}

//-(NSMutableArray *)obtainOfflineUserMutableList {
//
//	NSArray *offlineUserList = [[NSUserDefaults standardUserDefaults] arrayForKey: @"__USER_LIST"];
//	if (!offlineUserList) {
//		offlineUserList = [NSArray array];
//	}
//	NSMutableArray *offlineUserMutableList = [offlineUserList mutableCopy];
//	return offlineUserMutableList;
//}

// Only local save user when Log in AWS successfully.
//-(void)saveUser:(NSString *)user password:(NSString *)password identity:(NSString *)identity {
//
//	[self lockerStoreUsername: user password: password];
//
//	NSMutableArray *offlineUserMutableList = [self obtainOfflineUserMutableList];
//	__block bool isUserExist = false;
//
//	[offlineUserMutableList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//
//		NSString *localUsername = obj[@"_user"];
//		NSString *localIdentity = obj[@"_userId"];
//
//		if (![localUsername isEqualToString: user] &&
//				![localIdentity isEqualToString: identity]) {
//
//			isUserExist = false;
//		} else {
//			isUserExist = true;
//			*stop = YES;
//			return;
//		}
//	}];
//
//	if (!isUserExist) {
//		NSLog(@"user: %@ not exist, save a new user and password!", user);
//		NSDictionary *userInfo = [LoginManager userFormatOfUser: user password: password identity: identity];
//		[offlineUserMutableList addObject: userInfo];
//		[[NSUserDefaults standardUserDefaults] setObject: offlineUserMutableList forKey: @"__USER_LIST"];
//		[[NSUserDefaults standardUserDefaults] synchronize];
//		return;
//	}
//	NSLog(@"user %@ is existed, no need to save again", user);
//	// check modify
//
//	bool isQualified = [self compareOfflineUserListWithUser: user password: password];
//	NSLog(@"is qualified: %@", isQualified ? @"YES" : @"NO");
//	if (!isQualified) {
//		[self modifyUser: user password: password identity: identity];
//  }
//}

//TODO: maybe use when AWS identity changed or forget password.
//-(void)modifyUser:(NSString *)user password:(NSString *)password identity:(NSString *)identity {
//
//	[self lockerStoreUsername: user password: password];
//
//	NSMutableArray *offlineUserMutableList = [self obtainOfflineUserMutableList];
//
//	[offlineUserMutableList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//
//		if ([obj[@"_user"] isEqualToString: user]) {
//
//			*stop = YES;
//		}
//
//		if (*stop) {
//			NSLog(@"modify offline user: %@, with password: %@", user, [Encrypt SHA512From: password]);
//			NSDictionary *userInfo = [LoginManager userFormatOfUser: user password: password identity: identity];
//			[offlineUserMutableList replaceObjectAtIndex: idx withObject: userInfo];
//		}
//	}];
//	[[NSUserDefaults standardUserDefaults] setObject: offlineUserMutableList forKey: @"__USER_LIST"];
//	[[NSUserDefaults standardUserDefaults] synchronize];
//}
//
//-(BOOL)compareOfflineUserListWithUser:(NSString *)user password:(NSString *)password {
//
//	NSArray *offlineUserList = [[self obtainOfflineUserMutableList] copy];
//	__block bool isQualified = false;
//
//	NSString *hashPassword = [Encrypt SHA512From: password];
//
//	[offlineUserList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//		NSLog(@"user: %@", obj);
//		NSLog(@"user: %@, password: %@", user, hashPassword);
//
//
//		if ([obj[@"_user"] isEqualToString: user] &&
//				[obj[@"_password"] isEqualToString: hashPassword]) {
//
//			isQualified = true;
//			self.tmpIdentity = obj[@"_userId"];
//			*stop = YES;
//			return;
//		}
//		isQualified = false;
//	}];
//	return isQualified;
//}
