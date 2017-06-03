//
//  SyncManager.h
//  LoginManager
//
//  Created by Stan Liu on 06/04/2017.
//  Copyright © 2017 Stan Liu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SyncManager : NSObject

+(SyncManager *)shared;

-(void)startLoginFlow;

@end
