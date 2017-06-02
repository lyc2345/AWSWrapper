//
//  Alert.m
//  Others
//
//  Created by Stan Liu on 20/02/2017.
//  Copyright © 2017 Stan Liu. All rights reserved.
//

#import "Alert.h"

@interface Alert ()

@property (strong, nonatomic) UIViewController *topVC;
@property (strong, nonatomic) UIAlertAction *confirmAction;

@end

@implementation Alert

-(instancetype)init {
  
  self = [super init];
  if (self) {
    
    self.topVC = [self topVC];
  }
  return self;
}

-(UIViewController *)topVC {
  
  id baseVC = [[[UIApplication sharedApplication] keyWindow] rootViewController];
  
  if ([baseVC isKindOfClass: [UINavigationController class]]) {
    UINavigationController *navigationController = (UINavigationController *)baseVC;
    return [navigationController visibleViewController];
  }
  
  if ([baseVC isKindOfClass: [UITabBarController class]]) {
    
    UITabBarController *tabC = (UITabBarController *)baseVC;
    UINavigationController *navigationController = [tabC moreNavigationController];
    
    UIViewController *top = [navigationController topViewController];
    if (top && top.view) {
      return top;
    } else {
      
      UIViewController *selected = [tabC selectedViewController];
      if (selected)
        return selected;
    }
  }
  
  UIViewController *presentedVC = [baseVC presentedViewController];
  if (presentedVC) {
    return presentedVC;
  }
  
  return baseVC;
}

-(void)showError:(NSError *)error confirmHandler:(void(^)(void))confirmHandler {
	
	UIAlertController *alert = [UIAlertController alertControllerWithTitle: error.userInfo[@"__type"]
																																 message: error.userInfo[@"message"]
																													preferredStyle: UIAlertControllerStyleAlert];
	
	UIAlertAction *retry = [UIAlertAction actionWithTitle: @"OK" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
		
		confirmHandler();
	}];
	
	[alert addAction: retry];
	
	[self.topVC presentViewController: alert animated: YES completion: nil];
}

-(void)showAlertWithTitle:(NSString *)title message:(NSString *)message confirmHandler:(void(^)(void))confirmHandler {
	
	UIAlertController *alert = [UIAlertController alertControllerWithTitle: title
																																 message: message
																													preferredStyle: UIAlertControllerStyleAlert];
	
	UIAlertAction *retry = [UIAlertAction actionWithTitle: @"OK" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
		
		confirmHandler();
	}];
	
	[alert addAction: retry];
	
	[self.topVC presentViewController: alert animated: YES completion: nil];
}

@end
