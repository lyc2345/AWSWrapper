//
//  LocalLoginTests.m
//  AWSWrapper
//
//  Created by Stan Liu on 29/07/2017.
//  Copyright © 2017 lyc2345. All rights reserved.
//

#import "LoginTestBase.h"
#import "DispatchQueue.h"
#import "OfflineCognitoTestBase.h"
@import Specta;
@import AWSWrapper;

static LoginTestBase *testcase;
static OfflineCognitoTestBase *cognito;
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
      cognito = [OfflineCognitoTestBase shared];
      
      [cognito storeUsername: sampleUsername
                    password: samplePassword
                  identityId: @""];
      
      [cognito storeUsername: @"jonsnow"
                    password: @"kingofgameofthrone"
                  identityId: @""];
      
      [cognito storeUsername: @"hannibal"
                    password: @"hannibalthecannibal"
                  identityId: @""];
      
      for (int i = 0; i < 30; i ++) {
        
        [cognito storeUsername: [NSString stringWithFormat: @"%d", i]
                      password: [NSString stringWithFormat: @"%d", i]
                    identityId: @""];
        [NSThread sleepForTimeInterval: 0.3];
      }
      
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
        
        BOOL isQualified = [cognito verifyUsername: sampleUsername
                                          password: samplePassword];
        
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
                       password: @"iamjonsnow"
                     identityId: @""];
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
                       password: @"hannibaliscannibal"
                     identityId: @""];
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
  
  it (@"run 30 times", ^{
    
    waitUntil(^(DoneCallback done) {
      
      for (int i = 0; i < 30; i++) {
        
        [dispatchQueue performGroupedDelay: 0.2 block: ^{
          
          [testcase loginOfflineWithUser: [NSString stringWithFormat: @"%d", i]
                                password: [NSString stringWithFormat: @"%d", i]
                              completion: ^(NSError *error) {
                                
                                expect(error).to.beNil;
                                
                              }];
        }];
        
        [dispatchQueue performGroupedDelay: 0.2 block: ^{
          
          [testcase logoutOfflineCompletion: ^{
            
          }];
        }];
        
        [dispatchQueue performGroupedDelay: 0.2 block: ^{
          
          [cognito modifyUsername: [NSString stringWithFormat: @"%d", i]
                         password: [NSString stringWithFormat: @"%d%d", i, i]
                       identityId: @""];
        }];
        [NSThread sleepForTimeInterval: 0.2];
      }
      NSArray *accounts = [cognito allAccount: nil];
      expect(accounts.count).to.beGreaterThanOrEqualTo(30);
      done();
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

