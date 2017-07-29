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

SpecBegin(RemoteTest1)

describe(@"Tests1", ^{
  
  beforeAll(^{
    
    waitUntil(^(DoneCallback done) {
      
      testcase = [LoginTestBase new];
      dispatchQueue = [DispatchQueue new];
      done();
    });
    
    it(@"Test start", ^{
      
      
    });
    
  });
  
  
});

SpecEnd
