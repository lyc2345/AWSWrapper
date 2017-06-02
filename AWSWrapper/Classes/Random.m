//
//  Random.m
//  LoginManager
//
//  Created by Stan Liu on 06/04/2017.
//  Copyright © 2017 Stan Liu. All rights reserved.
//

#import "Random.h"

@implementation Random

+(NSString *)string {
	return [[NSProcessInfo processInfo] globallyUniqueString];
}

@end
