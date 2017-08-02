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
  mobileClient.AWSCognitoUserPoolId = @"us-east-1_aL46DVl7H";
  mobileClient.AWSCognitoUserPoolClientId = @"3dv4sqcsa20rulqke1rq5b4jeh";
  mobileClient.AWSCognitoUserPoolClientSecret = @"1id2og4gu5nsdaai62bqfo0qk8ntdlcre78bk8kdahrhpgpgffnp";
  mobileClient.AWSCognitoUserPoolRegion = AWSRegionUSEast1;
  mobileClient.CognitoPoolID = @"us-east-1:2209451d-de3e-48b0-8285-a5db9563194a";
  
  
  return [mobileClient didFinishLaunching: application withOptions: launchOptions];
}
  
-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
  
  return [[AWSMobileClient sharedInstance] withApplication: application withURL: url withSourceApplication:sourceApplication withAnnotation: annotation];
}

-(void)applicationDidEnterBackground:(UIApplication *)application {
  
  [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
}


@end
