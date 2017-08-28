
//  LoginTestBase.m
//  AWSWrapper
//
//  Created by Stan Liu on 29/07/2017.
//  Copyright © 2017 lyc2345. All rights reserved.
//

#import "LoginTestBase.h"
@import AWSWrapper;

@interface LoginTestBase ()

@property LoginManager *loginManager;

@property XCTestExpectation *expection;

@end

@implementation LoginTestBase

- (instancetype)init
{
  self = [super init];
  if (self) {
  
    self.loginManager = [LoginManager shared];

    
    /*
    self.loginManager.authenticationUsernameHandler = self.authenticationUsernameHandler;
    self.loginManager.didCompletePasswordAuthenticationStepWithErrorHandler = self.didCompletePasswordAuthenticationStepWithErrorHandler;
    self.loginManager.userPoolSignInFlowStartUserName = self.userPoolSignInFlowStartUserName;
    self.loginManager.userPoolSignInFlowStartPassword = self.userPoolSignInFlowStartPassword;
    self.loginManager.startMultiFactorAuthenticationHandler = self.startMultiFactorAuthenticationHandler;
    self.loginManager.getMultiFactorAuthenticationCode = self.getMultiFactorAuthenticationCode;
    self.loginManager.multifactorAuthenticationStepWithError = self.multifactorAuthenticationStepWithError;
     */
    
    __weak typeof(self) weakSelf = self;
    
    // Use LoginManager should set up all the handler
    self.loginManager.authenticationUsernameHandler = ^(NSString *lastKnownUsername) {
      weakSelf.username = lastKnownUsername;
    };
    
    self.loginManager.didCompletePasswordAuthenticationStepWithErrorHandler = ^(NSError *error) {
      
      if (error) {
        NSLog(@"password authentication error: %@", error);
      }
      
      if (error.code == 26) {
        // not confirmed
      } else if (error.code == 16) {
        // incorrect username or password.
      }
    };
    
    self.loginManager.userPoolSignInFlowStartUserName = ^{
      return weakSelf.username;
    };
    
    self.loginManager.userPoolSignInFlowStartPassword = ^{
      return weakSelf.password;
    };

    
    self.loginManager.startMultiFactorAuthenticationHandler = ^id<AWSCognitoIdentityMultiFactorAuthentication>{
      
//      dispatch_async(dispatch_get_main_queue(), ^{
//        [weakSelf.navigationController pushViewController: mfaViewController
//                                                 animated: YES];
//      });
      
      return weakSelf.loginManager;
    };
    
    self.loginManager.getMultiFactorAuthenticationCode = ^(AWSCognitoIdentityMultifactorAuthenticationInput *authenticationInput, AWSTaskCompletionSource<NSString *> *mfaCodeCompletionSource) {
      
      //mfaViewController.mfaCodeCompletionSource = mfaCodeCompletionSource;
      //mfaViewController.destination = authenticationInput.destination;
    };
    
    self.loginManager.multifactorAuthenticationStepWithError = ^(NSError *error) {
      
      dispatch_async(dispatch_get_main_queue(), ^{
        if(error){
          NSLog(@"multifactor authentication error: %@", error);
        }
      });
    };
    
  }
  return self;
}

-(NSString *)user {
  return self.loginManager.user;
}

-(BOOL)isLogin {
  return self.loginManager.isLogin;
}

-(NSString *)offlineIdentity {
  return self.loginManager.offlineIdentity;
}

// MARK: Offline

-(void)loginOfflineWithUser:(NSString *)user password:(NSString *)password completion:(void(^)(NSError *error))completion {
  
  self.expection = [self expectationWithDescription: @"_login_offline"];
  
  [self.loginManager loginOfflineWithUsername: user password: password completion: ^(NSError *error) {
    
    [self.expection fulfill];
  }];
  
  [self waitForExpectationsWithTimeout: 5.0 handler:^(NSError * _Nullable error) {
    
    if (error) {
      
    }
    completion(error);
  }];
}

-(void)logoutOfflineCompletion:(void(^)(NSError *error))completion {
  
  self.expection = [self expectationWithDescription: @"_logout_offline"];
  
  __block NSError *_error;
  [self.loginManager logoutOfflineCompletion: ^(NSError *error) {
    
    _error = error;
    [self.expection fulfill];
  }];
  
  [self waitForExpectationsWithTimeout: 5.0 handler:^(NSError * _Nullable error) {
    
    if (error) {
      
    }
    completion(_error);
  }];
}

// MARK: AWS

-(BOOL)isAWSLogin {
  return self.loginManager.isAWSLogin;
}

-(NSString *)awsIdentityId {
  return self.loginManager.awsIdentityId;
}

-(void)signUpWithUser:(NSString *)username
             password:(NSString *)password
                email:(NSString *)email
                  tel:(NSString *)telephone
        waitToConfirm:(void(^)(NSString *destination))waitToConfirm
              success:(void(^)())successHandler
                 fail:(void(^)(NSError *error))failHandler {
  
  [self.loginManager signUpWithUser: username
                           password: password
                              email: email
                                tel: telephone
                      waitToConfirm: waitToConfirm
                            success: successHandler
                               fail: failHandler];
}


// Don't know how to test for confirm by confirm code.
-(void)confirmSignUpWithUser:(NSString *)username
                 confirmCode:(NSString *)confirmCode
                     success:(void(^)())successHandler
                        fail:(void(^)(NSError *error))failHandler {
//
//  self.expection = [self expectationWithDescription: @"Logout offline"];
//  
//  [self.loginManager confirmSignUpWithUser: username
//                               confirmCode: confirmCode
//                                   success: successHandler
//                                      fail: failHandler];
//  
//  [self waitForExpectationsWithTimeout: 2.0 handler:^(NSError * _Nullable error) {
//    completion();
//  }];
}

-(void)onResendOfUser:(NSString *)username
              success:(void(^)(NSString *destination))successHandler
                 fail:(void(^)(NSError *error))failHandler {

  [self.loginManager onResendOfUser: username success: successHandler fail: failHandler];
}

// Don't know how to test confime code again.
-(void)confirmForgotNewPassword:(NSString *)newPassword
                    confirmCode:(NSString *)confirmCode
                        success:(void(^)())successHandler
                           fail:(void(^)(NSError *error))failHandler {
//  
//  self.expection = [self expectationWithDescription: @"Logout offline"];
//  
//  [self.loginManager confirmForgotNewPassword: newPassword
//                                  confirmCode: confirmCode
//                                      success: successHandler
//                                         fail: failHandler];
//
//  [self.expection fulfill];
//  [self waitForExpectationsWithTimeout: 2.0 handler:^(NSError * _Nullable error) {
//    completion();
//  }];
//  
//  [self.loginManager confirmForgotNewPassword: newPassword confirmCode: confirmCode success: successHandler fail: failHandler];
}

-(void)forgotPasswordOfUser:(NSString *)username
                 completion:(void(^)(NSError *error))completion {
  
  self.expection = [self expectationWithDescription: @"_forgot_password"];
  __block NSError *_error;
  [self.loginManager forgotPasswordOfUser: username completion: ^(NSError *error) {
    _error = error;
    [self.expection fulfill];
  }];
  
  [self waitForExpectationsWithTimeout: 5.0 handler:^(NSError * _Nullable error) {
    
    if (error) {
      XCTAssertNil(error);
    }
    completion(_error);
  }];
}

-(void)login:(void(^)(id result, NSError * error))completion {
  
  self.expection = [self expectationWithDescription: @"_remote_login"];
  __block id _result;
  __block NSError *_error;
  [self.loginManager login: ^(id result, NSError *error) {
    
    XCTAssertNotNil(result);
    XCTAssertNil(error);
    _result = result;
    _error = error;
    [self.expection fulfill];
  }];
  
  [self waitForExpectationsWithTimeout: 5.0 handler:^(NSError * _Nullable error) {
    
    if (error) {
      XCTAssertNil(error);
    }
    completion(_result, _error);
  }];
}

-(void)logout:(void(^)(id result, NSError *error))completion {
  
  self.expection = [self expectationWithDescription: @"_remote_logout"];
  __block id _result;
  __block NSError *_error;
  
  [self.loginManager logout: ^(id result, NSError *error) {
    
    _result = result;
    _error = error;
    [self.expection fulfill];
  }];
  
  [self waitForExpectationsWithTimeout: 5.0 handler:^(NSError * _Nullable error) {
    
    if (error) {
      XCTAssertNil(error);
    }
    completion(_result, _error);
  }];
}



@end
