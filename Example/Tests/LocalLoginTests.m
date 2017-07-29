//
//  LocalLoginTests.m
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

SpecBegin(LocalLoginTests)

describe(@"Tests1", ^{
  
  beforeAll(^{
    
    waitUntil(^(DoneCallback done) {
      
      testcase = [LoginTestBase new];
      dispatchQueue = [DispatchQueue new];
      [testcase logoutOfflineCompletion: ^(NSError *error) {
        
        expect(error).to.beNil;
        done;
      }];
    });
    
    it(@"Test start", ^{
      
      waitUntil(^(DoneCallback done) {
        
        [testcase loginOfflineWithUser: @"sss" password: @"88888888" completion: ^(NSError *error) {
          
          expect(error).to.beNil;
          done();
        }];
        
//        [testcase login: ^(id result, NSError *error) {
//          
//          expect(result).notTo.beNil;
//          expect(error).to.beNil;
//          done()
//        }];
      });
    });
    
  });
  
  
});

SpecEnd

