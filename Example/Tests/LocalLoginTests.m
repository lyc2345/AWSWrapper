//
//  LocalLoginTests.m
//  AWSWrapper
//
//  Created by Stan Liu on 29/07/2017.
//  Copyright © 2017 lyc2345. All rights reserved.
//

#import "LoginTestBase.h"
#import "DispatchQueue.h"
#import "OfflineCognito.h"
@import Specta;
@import AWSWrapper;

static LoginTestBase *testcase;
static OfflineCognito *cognito;
static DispatchQueue *dispatchQueue;

static NSString *sampleUsername = @"jjj";
static NSString *samplePassword = @"88888888";

static NSString *editedPaassword = @"gggggggg";

SpecBegin(LocalLoginTests)

describe(@"Tests1", ^{
  
  beforeAll(^{
    
    waitUntil(^(DoneCallback done) {
      
      testcase = [LoginTestBase new];
      dispatchQueue = [DispatchQueue new];
      cognito = [OfflineCognito shared];
        
      [cognito storeUsername: sampleUsername
                      password: samplePassword];
      
      [cognito storeUsername: @"jonsnow"
                    password: @"kingofgameofthrone"];
      
      [cognito storeUsername: @"hannibal"
                    password: @"hannibalthecannibal"];
      
      done();
    });
  });
  
  it(@"login, logout, modify, login modified, verify", ^{
    
    waitUntil(^(DoneCallback done) {
      
      [dispatchQueue performGroupedDelay: 1 block: ^{
        
        [testcase loginOfflineWithUser: sampleUsername
                              password: samplePassword
                            completion: ^(NSError *error) {
                              
                              expect(error).to.beNil;
                              
                            }];
      }];
      
      [dispatchQueue performGroupedDelay: 1 block: ^{
        
        [testcase logoutOfflineCompletion: ^{
          
        }];
      }];
      
      [dispatchQueue performGroupedDelay: 1 block: ^{
        
        [cognito modifyUsername: sampleUsername
                       password: editedPaassword];
      }];
      
      
      [dispatchQueue performGroupedDelay: 1 block: ^{
        
        [testcase loginOfflineWithUser: sampleUsername
                              password: editedPaassword
                            completion: ^(NSError *error) {
                              
                              expect(error).to.beNil;
                              
                            }];
      }];

      [dispatchQueue performGroupedDelay: 1 block: ^{
        
        BOOL isQualified = [cognito verifyUsername: sampleUsername
                                          password: editedPaassword];
        
        XCTAssertTrue(isQualified);
        done();
      }];
      
      
      [dispatchQueue performGroupedDelay: 1 block: ^{
        
        [testcase loginOfflineWithUser: @"jonsnow"
                              password: @"kingofgameofthrone"
                            completion: ^(NSError *error) {
                              
                              expect(error).to.beNil;
                              
                            }];
      }];
      
      [dispatchQueue performGroupedDelay: 1 block: ^{
        
        [testcase logoutOfflineCompletion: ^{
          
        }];
      }];
      
      [dispatchQueue performGroupedDelay: 1 block: ^{
        
        [cognito modifyUsername: @"jonsnow"
                       password: @"iamjonsnow"];
      }];
      
      
      [dispatchQueue performGroupedDelay: 1 block: ^{
        
        [testcase loginOfflineWithUser: @"jonsnow"
                              password: @"iamjonsnow"
                            completion: ^(NSError *error) {
                              
                              expect(error).to.beNil;
                              
                            }];
      }];
      
      [dispatchQueue performGroupedDelay: 1 block: ^{
        
        BOOL isQualified = [cognito verifyUsername: @"jonsnow"
                                          password: @"iamjonsnow"];
        
        XCTAssertTrue(isQualified);
      }];
      
      
      [dispatchQueue performGroupedDelay: 1 block: ^{
        
        [testcase loginOfflineWithUser: @"hannibal"
                              password: @"hannibalthecannibal"
                            completion: ^(NSError *error) {
                              
                              expect(error).to.beNil;
                              
                            }];
      }];
      
      [dispatchQueue performGroupedDelay: 1 block: ^{
        
        [testcase logoutOfflineCompletion: ^{
          
        }];
      }];
      
      [dispatchQueue performGroupedDelay: 1 block: ^{
        
        [cognito modifyUsername: @"hannibal"
                       password: @"hannibaliscannibal"];
      }];
      
      
      [dispatchQueue performGroupedDelay: 1 block: ^{
        
        [testcase loginOfflineWithUser: @"hannibal"
                              password: @"hannibaliscannibal"
                            completion: ^(NSError *error) {
                              
                              expect(error).to.beNil;
                              
                            }];
      }];
      
      [dispatchQueue performGroupedDelay: 1 block: ^{
        
        BOOL isQualified = [cognito verifyUsername: @"hannibal"
                                          password: @"hannibaliscannibal"];
        
        XCTAssertTrue(isQualified);
      }];
      
      [dispatchQueue performGroupedDelay: 1 block: ^{
        
        NSError *error = nil;
        NSArray *accounts = [cognito allAccount: &error];
        
        NSLog(@"accounts: %@", accounts);
        done();
      }];
      
      
    });
  });
  
//  it(@"login, logout, modify, login modified, verify - jon snow", ^{
//    
//    waitUntil(^(DoneCallback done) {
//      
//      
//    });
//  });
//  
//  it(@"login, logout, modify, login modified, verify - hannibal", ^{
//    
//    waitUntil(^(DoneCallback done) {
//      
//    });
//  });
  
});

SpecEnd

