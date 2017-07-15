//
//  DispatchGroup.h
//  AWSWrapper
//
//  Created by Stan Liu on 15/07/2017.
//  Copyright © 2017 lyc2345. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DispatchQueue : NSObject

@property (nonatomic) dispatch_group_t requestGroup;
@property (nonatomic) dispatch_group_t dispatchGroup;



-(void)performBlock:(void(^)())block;

- (void)performGroupedDelay:(NSTimeInterval)delay block:(dispatch_block_t)block;

- (void)waitForGroup;

@end
