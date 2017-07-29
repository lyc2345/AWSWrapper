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

static NSString *sampleUsername = @"sss";
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
      done();
    });
  });
  
  it(@"Test start", ^{
    
    waitUntil(^(DoneCallback done) {
      
      [dispatchQueue performGroupedDelay: 2 block: ^{
        
        [testcase loginOfflineWithUser: sampleUsername
                              password: samplePassword
                            completion: ^(NSError *error) {
                              
                              expect(error).to.beNil;
                              
                            }];
      }];
      
      [dispatchQueue performGroupedDelay: 2 block: ^{
        
        [testcase logoutOfflineCompletion: ^{
          
        }];
      }];
      
      [dispatchQueue performGroupedDelay: 2 block: ^{
        
        [cognito modifyUsername: sampleUsername
                       password: editedPaassword];
      }];
      
      
      [dispatchQueue performGroupedDelay: 2 block: ^{
        
        [testcase loginOfflineWithUser: sampleUsername
                              password: editedPaassword
                            completion: ^(NSError *error) {
                              
                              expect(error).to.beNil;
                              done();
                            }];
        
      }];
      
    });
    
  });
  
  
});

SpecEnd

