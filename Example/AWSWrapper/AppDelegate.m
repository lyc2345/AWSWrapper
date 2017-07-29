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
  mobileClient.AWSCognitoUserPoolId = @"us-east-1_2WqVQYNVu";
  mobileClient.AWSCognitoUserPoolClientId = @"ibag2n69s0iikmbjvgr61cpg0";
  mobileClient.AWSCognitoUserPoolClientSecret = @"1h8pn5qc6f5ac7q80fnr1gaglke0mm2tc5upqo14a2h27p0fskbj";
  mobileClient.AWSCognitoUserPoolRegion = AWSRegionUSEast1;
  mobileClient.CognitoPoolID = @"us-east-1:7d5a9cc2-ed5d-4ed1-ac26-14852b3324cb";
  
  
  return [mobileClient didFinishLaunching: application withOptions: launchOptions];
}
  
-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
  
  return [[AWSMobileClient sharedInstance] withApplication: application withURL: url withSourceApplication:sourceApplication withAnnotation: annotation];
}

-(void)applicationDidEnterBackground:(UIApplication *)application {
  
  [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
}


@end
