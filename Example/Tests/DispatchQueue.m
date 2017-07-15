//
//  DispatchGroup.m
//  AWSWrapper
//
//  Created by Stan Liu on 15/07/2017.
//  Copyright © 2017 lyc2345. All rights reserved.
//

#import "DispatchQueue.h"

@implementation DispatchQueue

- (instancetype)init
{
  self = [super init];
  if (self) {
    
    _dispatchGroup = dispatch_group_create();
    _requestGroup = dispatch_group_create();
    
  }
  return self;
}

-(void)performBlock:(void(^)())block {
  
  block();
}

- (void)performGroupedDelay:(NSTimeInterval)delay block:(dispatch_block_t)block {
  
  [NSThread sleepForTimeInterval: delay];
  dispatch_group_enter(self.dispatchGroup);
  [self performBlock:^{
    block();
    [NSThread sleepForTimeInterval: delay];
  }];
}

- (void)waitForGroup {
  
  __block BOOL didComplete = NO;
  
  if (!_requestGroup) {
    _requestGroup = dispatch_group_create();
  }
  if (!_dispatchGroup) {
    _dispatchGroup = dispatch_group_create();
  }
  
  dispatch_group_notify(self.requestGroup, dispatch_get_main_queue(), ^{
    didComplete = YES;
  });
  while (! didComplete) {
    NSTimeInterval const interval = 0.002;
    if (! [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:interval]]) {
      [NSThread sleepForTimeInterval:interval];
    }
  }
}


@end
