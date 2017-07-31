//
//  AppDelegate.m
//  AWSWrapper
//
//  Created by lyc2345 on 06/02/2017.
//  Copyright (c) 2017 lyc2345. All rights reserved.
//

#import "AppDelegate.h"
@import AFNetworking;
@import AWSWrapper;
@import AWSCore;

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  
  [[AFNetworkReachabilityManager sharedManager] startMonitoring];
  [AWSLogger defaultLogger].logLevel = AWSLogLevelVerbose;
  
  AWSMobileClient *mobileClient = [AWSMobileClient sharedInstance];
  mobileClient.AWSCognitoUserPoolId = @"us-east-1_iDnrGBLBd";
  mobileClient.AWSCognitoUserPoolClientId = @"37u895hpiimdugm26u4tmkpv55";
  mobileClient.AWSCognitoUserPoolClientSecret = @"1jv7dd4gn0omcu1dmk8ntl4t2f7pc7srufuerd843pqggfm8a5q9";
  mobileClient.AWSCognitoUserPoolRegion = AWSRegionUSEast1;
  mobileClient.CognitoPoolID = @"us-east-1:2ab8ba13-d220-4a5d-abee-7f5f06583694";
  
  
  return [mobileClient didFinishLaunching: application withOptions: launchOptions];
}
  
-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
  
  return [[AWSMobileClient sharedInstance] withApplication: application withURL: url withSourceApplication:sourceApplication withAnnotation: annotation];
}

-(void)applicationDidEnterBackground:(UIApplication *)application {
  
  [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
}


@end
