//
//  QueueTests.m
//  AWSWrapper
//
//  Created by Stan Liu on 11/08/2017.
//  Copyright © 2017 lyc2345. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "DispatchQueue.h"

@interface QueueTests : XCTestCase

@property DispatchQueue *q;

@end

@implementation QueueTests

- (void)setUp {
  [super setUp];
  
  _q = [DispatchQueue new];
}

- (void)tearDown {
  // Put teardown code here. This method is called after the invocation of each test method in the class.
  [super tearDown];
}

-(void)doBlock:(void(^)())block {
  
  block();
}

- (void)testExample {
  
  [_q performWaitBlock:^(dispatch_semaphore_t sema) {
    
    for (int i = 0; i < 100; i++) {
      NSLog(@"first: %d", i);
    }
  }];
  
  [_q performWaitBlock:^(dispatch_semaphore_t sema) {
    
    for (int i = 0; i < 50; i++) {
      dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSLog(@"second: %d", i);
      });
    }
  }];
  
  [_q performWaitBlock:^(dispatch_semaphore_t sema) {
    
    [self doBlock:^{
      
      for (int i = 0; i < 50; i++) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
          NSLog(@"third: %d", i);
        });
      }
    }];
  }];
  
  [_q performWaitBlock:^(dispatch_semaphore_t sema) {
    
    [self doBlock:^{
      
      for (int i = 0; i < 50; i++) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
          NSLog(@"forth: %d", i);
        });
      }
    }];
  }];
  
  
}

- (void)testPerformanceExample {
  // This is an example of a performance test case.
  [self measureBlock:^{
    // Put the code you want to measure the time of here.
  }];
}

@end
