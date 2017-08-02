//
//  OfflineCognitoDBTestBase.h
//  AWSWrapper
//
//  Created by Stan Liu on 29/07/2017.
//  Copyright © 2017 lyc2345. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface OfflineCognitoTestBase : XCTestCase

+(OfflineCognitoTestBase *)shared;

-(NSString *)password;

-(void)storeUsername:(NSString *)username
            password:(NSString *)password;

-(BOOL)verifyUsername:(NSString *)username
             password:(NSString *)password;

-(void)modifyUsername:(NSString *)username
             password:(NSString *)password;


-(NSArray *)allAccount:(NSError * __autoreleasing *)error;

@end
