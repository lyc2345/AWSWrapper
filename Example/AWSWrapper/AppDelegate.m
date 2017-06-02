//
//  AppDelegate.m
//  AWSWrapper
//
//  Created by lyc2345 on 06/02/2017.
//  Copyright (c) 2017 lyc2345. All rights reserved.
//

#import "AppDelegate.h"
@import AWSWrapper;

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  
  [[AWSMobileClient sharedInstance] didFinishLaunching: application withOptions: launchOptions];
  
  return YES;
}
  
-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
  
  return [[AWSMobileClient sharedInstance] withApplication: application withURL: url withSourceApplication:sourceApplication withAnnotation: annotation];
}

  
@end
