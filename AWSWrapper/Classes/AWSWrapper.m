//
//  AWSWrapper.m
//  Pods
//
//  Created by Stan Liu on 02/06/2017.
//
//

#import "AWSWrapper.h"
#import "AWSMobileHubHelper/AWSMobileHubHelper.h"

@implementation AWSWrapper
  
+(void)doAThing {
  
  NSLog(@"do a thing!, %@", [AWSUserFileManager defaultUserFileManager]);
}

@end
