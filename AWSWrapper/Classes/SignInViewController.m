//
//  SignInViewController.m
//
//
// Copyright 2017 Stan Liu. All Rights Reserved.
//
//
//
#import <Foundation/Foundation.h>
//#import "MainViewController.h"
#import "SignInViewController.h"
#import "AFNetworking/AFNetworking.h"
#import "UserPoolSignUpViewController.h"
#import "UserPoolForgotPasswordViewController.h"
#import "UserPoolMFAViewController.h"
#import "LoginManager.h"
#import "Alert.h"

static NSString *LOG_TAG;

@interface SignInViewController ()

@end

@implementation SignInViewController

+ (void)initialize {
    [super initialize];
    LOG_TAG = NSStringFromClass(self);
}

#pragma mark - UIViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	NSLog(@"%@: Sign-In Loading.", LOG_TAG);
	
	[self.facebookButton removeFromSuperview];
	[self.googleButton removeFromSuperview];
	// CUSTOM UI SETUP
	[self.leftHorizontalBar removeFromSuperview];
	[self.rightHorizontalBar removeFromSuperview];
	[self.orSignInWithLabel removeFromSuperview];
	
	[self.customProviderButton addTarget:self
																action:@selector(handleCustomSignIn)
											forControlEvents:UIControlEventTouchUpInside];
	[self.customCreateAccountButton addTarget:self
																		 action:@selector(handleUserPoolSignUp)
													 forControlEvents:UIControlEventTouchUpInside];
	[self.customForgotPasswordButton addTarget:self
																			action:@selector(handleUserPoolForgotPassWord)
														forControlEvents:UIControlEventTouchUpInside];
	
	//[self.customProviderButton setImage:[UIImage imageNamed:@"LoginButton"] forState:UIControlStateNormal];
	[self changeLoginBtn];
	
	__weak typeof(self) weakSelf = self;
	
	// Use LoginManager should set up all the handler
	[LoginManager shared].authenticationUsernameHandler = ^(NSString *lastKnownUsername) {
		if (!weakSelf.customUserIdField) {
			weakSelf.customUserIdField.text = lastKnownUsername;
		}
	};
	
	[LoginManager shared].didCompletePasswordAuthenticationStepWithErrorHandler = ^(NSError *error) {
		
		if (error) {
			[[Alert new]  showError: error confirmHandler:^{ }];
		}
		
		if (error.code == 26) {
			// not confirmed
		} else if (error.code == 16) {
			// incorrect username or password.
		}
	};
	
	[LoginManager shared].userPoolSignInFlowStartUserName = ^{
		return weakSelf.customUserIdField.text;
	};
	
	[LoginManager shared].userPoolSignInFlowStartPassword = ^{
		return weakSelf.customPasswordField.text;
	};
	
	NSBundle *bundle = [NSBundle bundleForClass: [UserPoolMFAViewController class]];
	NSURL *url = [bundle URLForResource: @"Resources" withExtension: @"bundle"];
	NSBundle *podBundle = [NSBundle bundleWithURL: url];
	UIStoryboard *storyboard = [UIStoryboard storyboardWithName: @"UserPools" bundle: podBundle];
	UserPoolMFAViewController *mfaViewController = [storyboard instantiateViewControllerWithIdentifier: NSStringFromClass([UserPoolMFAViewController class])];

	
	[LoginManager shared].startMultiFactorAuthenticationHandler = ^id<AWSCognitoIdentityMultiFactorAuthentication>{
		
		dispatch_async(dispatch_get_main_queue(), ^{
			[weakSelf.navigationController pushViewController: mfaViewController
																							 animated: YES];
		});
		
		return [LoginManager shared];
	};
	
	[LoginManager shared].getMultiFactorAuthenticationCode = ^(AWSCognitoIdentityMultifactorAuthenticationInput *authenticationInput, AWSTaskCompletionSource<NSString *> *mfaCodeCompletionSource) {
		
		mfaViewController.mfaCodeCompletionSource = mfaCodeCompletionSource;
		mfaViewController.destination = authenticationInput.destination;
	};
	
	[LoginManager shared].multifactorAuthenticationStepWithError = ^(NSError *error) {
		
		dispatch_async(dispatch_get_main_queue(), ^{
			if(error){
				[[Alert new] showError: error
								confirmHandler:^{ }];
			}
		});
	};

}

-(void)changeLoginBtn {
	
	if ([LoginManager shared].isAWSLogin) {
		[self.customProviderButton setTitle: @"Logout" forState: UIControlStateNormal];
	} else {
		[self.customProviderButton setTitle: @"Login" forState: UIControlStateNormal];
	}
}

#pragma mark - IBActions

- (void)handleCustomSignIn {
	
	__weak typeof(self) weakSelf = self;
	
	if ([AFNetworkReachabilityManager sharedManager].isReachable) {
		
		if (![LoginManager shared].isAWSLogin) {
			[[LoginManager shared] login:^(id  _Nullable result, NSError * _Nullable error) {
				
				if (!error) {
					[weakSelf.navigationController popToRootViewControllerAnimated: YES];
				}
				
			}];
		} else {
			[[LoginManager shared] logout:^(id result, NSError *error) {
				
				NSLog(@"logout error: %@", error);
			}];
		}
		
	} else {
		
		if (![LoginManager shared].isLogin) {
			
			[[LoginManager shared] loginOfflineWithUser: self.customUserIdField.text password: self.customPasswordField.text completion:^(NSError *error) {
				
				if (!error) {
					[weakSelf.navigationController popViewControllerAnimated: YES];
				}
				
			}];
		}	else {
			
			[[LoginManager shared] logoutOfflineCompletion:^(NSError *error) {
				
			}];
		}
	}
}

- (void)handleUserPoolSignUp {
	
	NSBundle *bundle = [NSBundle bundleForClass: [UserPoolSignUpViewController class]];
	NSURL *url = [bundle URLForResource: @"Resources" withExtension: @"bundle"];
	NSBundle *podBundle = [NSBundle bundleWithURL: url];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName: @"UserPools" bundle: podBundle];
    UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier: NSStringFromClass([UserPoolSignUpViewController class])];
    [self.navigationController pushViewController:viewController
                                         animated:YES];
}

- (void)handleUserPoolForgotPassWord {
	
	NSBundle *bundle = [NSBundle bundleForClass: [UserPoolForgotPasswordViewController class]];
	NSURL *url = [bundle URLForResource: @"Resources" withExtension: @"bundle"];
	NSBundle *podBundle = [NSBundle bundleWithURL: url];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName: @"UserPools" bundle: podBundle];
    UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier: NSStringFromClass([UserPoolForgotPasswordViewController class])];
    [self.navigationController pushViewController:viewController
                                         animated:YES];
}




@end
