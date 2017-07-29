//
//  LoginTestBase.h
//  AWSWrapper
//
//  Created by Stan Liu on 29/07/2017.
//  Copyright © 2017 lyc2345. All rights reserved.
//

@import XCTest;

@interface LoginTestBase : XCTestCase

// MARK: Offline

-(NSString *)user;
-(BOOL)isLogin;
-(NSString *)offlineIdentity;

-(void)loginOfflineWithUser:(NSString *)user password:(NSString *)password completion:(void(^)(NSError *error))completion;

-(void)logoutOfflineCompletion:(void(^)(NSError *error))completion;


// AWS

-(BOOL)isAWSLogin;
-(NSString *)awsIdentityId;
-(NSString *)awsDidSignInNotificationName;
-(NSString *)awsDidSignOutNotificationName;

-(void)signUpWithUser:(NSString *)username
             password:(NSString *)password
                email:(NSString *)email
                  tel:(NSString *)telephone
        waitToConfirm:(void(^)(NSString *destination))confirmAction
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
