//
//  LoginTestBase.h
//  AWSWrapper
//
//  Created by Stan Liu on 29/07/2017.
//  Copyright © 2017 lyc2345. All rights reserved.
//

@import XCTest;

@interface LoginTestBase : NSObject

/*
// MARK: AWS Cognito Delegate Handler

// MARK: AWSCognitoIdentityInteractiveAuthenticationDelegate delegate
@property (copy, nonatomic) id<AWSCognitoIdentityMultiFactorAuthentication>(^startMultiFactorAuthenticationHandler)();

// MARK: AWSCognitoIdentityPasswordAuthentication Delegate
@property (copy, nonatomic) void(^authenticationUsernameHandler)(NSString *lastKnownUsername);
@property (copy, nonatomic) void(^didCompletePasswordAuthenticationStepWithErrorHandler)(NSError *error);

// MARK: AWSCognitoIdentityMultiFactorAuthentication Delegate
@property (nonatomic, copy)	void(^getMultiFactorAuthenticationCode)(AWSCognitoIdentityMultifactorAuthenticationInput *authenticationInput, AWSTaskCompletionSource<NSString *>* mfaCodeCompletionSource);
@property (nonatomic, copy) void(^multifactorAuthenticationStepWithError)(NSError *error);

// To receive user info from Textfield.
@property (copy, nonatomic) NSString *(^userPoolSignInFlowStartUserName)();
@property (copy, nonatomic) NSString *(^userPoolSignInFlowStartPassword)();

// For AWS login status change block. Implement this in where you want to show user is login or not.
//@property (copy, nonatomic) void(^AWSLoginStatusChangedHandler)();
 */

@property NSString *username;
@property NSString *password;


// MARK: Offline

-(NSString *)user;
-(BOOL)isLogin;
-(NSString *)offlineIdentity;

-(void)loginOfflineWithUser:(NSString *)user password:(NSString *)password completion:(void(^)(NSError *error))completion;

-(void)logoutOfflineCompletion:(void(^)(void))completion;


// AWS

-(BOOL)isAWSLogin;
-(NSString *)awsIdentityId;

-(void)signUpWithUser:(NSString *)username
             password:(NSString *)password
                email:(NSString *)email
                  tel:(NSString *)telephone
        waitToConfirm:(void(^)(NSString *destination))waitToConfirm
              success:(void(^)())successHandler
                 fail:(void(^)(NSError *error))failHandler;


-(void)confirmSignUpWithUser:(NSString *)username
                 confirmCode:(NSString *)confirmCode
                     success:(void(^)())successHandler
                        fail:(void(^)(NSError *error))failHandler;

-(void)onResendOfUser:(NSString *)username
              success:(void(^)(NSString *destination))successHandler
                 fail:(void(^)(NSError *error))failHandler;

-(void)confirmForgotNewPassword:(NSString *)newPassword
                    confirmCode:(NSString *)confirmCode
                        success:(void(^)())successHandler
                           fail:(void(^)(NSError *error))failHandler;

-(void)forgotPasswordOfUser:(NSString *)username
                 completion:(void(^)(NSError *error))completion;

-(void)login:(void(^)(id result, NSError * error))completion;

-(void)logout:(void(^)(id result, NSError *error))completion;



@end
