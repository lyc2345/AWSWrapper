//
//  UserPoolForgotPasswordViewController.m
//  MySampleApp
//
//
// Copyright 2017 Amazon.com, Inc. or its affiliates (Amazon). All Rights Reserved.
//
// Code generated by AWS Mobile Hub. Amazon gives unlimited permission to 
// copy, distribute and modify it.
//
// Source code generated from template: aws-my-sample-app-ios-objc v0.16
//
//

#import "UserPoolForgotPasswordViewController.h"
#import "LoginManager.h"
#import "Alert.h"

@interface UserPoolForgotPasswordViewController ()

@property (strong, nonatomic) NSString *usernameString;

@end

@interface UserPoolNewPasswordViewController ()

@property (weak, nonatomic) IBOutlet UITextField *confirmationCode;
@property (weak, nonatomic) IBOutlet UITextField *updatedPassword;

@property (strong, nonatomic) NSString *usernameString;

@end

@implementation UserPoolForgotPasswordViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if([@"NewPasswordSegue" isEqualToString:segue.identifier]){
        UserPoolNewPasswordViewController * confirmForgot = segue.destinationViewController;
        confirmForgot.usernameString = self.usernameString;
    }
}

- (IBAction)onForgotPassword:(id)sender {
	
	[[LoginManager shared] forgotPasswordOfUser: self.userName.text completion:^(NSError *error) {
		
		dispatch_async(dispatch_get_main_queue(), ^{
			if(error){
				[[Alert new] showError: error confirmHandler:^{ }];
			} else {
				[self performSegueWithIdentifier:@"NewPasswordSegue" sender:sender];
			}
		});
	}];
}

- (IBAction)onCancel:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end

@implementation UserPoolNewPasswordViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	
}
- (IBAction)onUpdatePassword:(id)sender {
    //confirm forgot password with input from ui.
	__weak typeof(self) weakSelf = self;
	[[LoginManager shared] confirmForgotNewPassword: self.updatedPassword.text confirmCode: self.confirmationCode. text success:^{
		
		[[Alert new] showAlertWithTitle: @"Password Reset Complete"
														message: @"Password Reset was completed successfully."
										 confirmHandler:^{
										 
											 [weakSelf.navigationController popToRootViewControllerAnimated:YES];
										 }];

	} fail:^(NSError *error) {
		
		[[Alert new] showError: error confirmHandler:^{ }];

	}];
}

- (IBAction)onCancel:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end