//
//  RemoteLoginTest.m
//  AWSWrapper
//
//  Created by Stan Liu on 29/07/2017.
//  Copyright © 2017 lyc2345. All rights reserved.
//

#import "LoginTestBase.h"
#import "DispatchQueue.h"
@import Specta;
@import AWSWrapper;

static LoginTestBase *testcase;
static DispatchQueue *dispatchQueue;

static NSString *sampleUsername = @"sss";
static NSString *samplePassword = @"88888888";

SpecBegin(RemoteTest1)

describe(@"Tests1", ^{
  
  beforeAll(^{
    
    waitUntil(^(DoneCallback done) {
      
      testcase = [LoginTestBase new];
      dispatchQueue = [DispatchQueue new];
      done();
    });
    
    it(@"Test start", ^{
      
      waitUntil(^(DoneCallback done) {
        
        [dispatchQueue performGroupedDelay: 2 block: ^{
          
          [testcase login: ^(id result, NSError *error) {
            
            expect(result).notTo.beNil;
            expect(error).to.beNil;
          }];
        }];
        
        [dispatchQueue performGroupedDelay: 2 block: ^{
          
          [testcase logout: ^(id result, NSError *error) {
            
            expect(result).notTo.beNil;
            expect(error).to.beNil;
            done();
          }];
        }];
        
      });
      
    });
    
  });
  
  
});

SpecEnd
