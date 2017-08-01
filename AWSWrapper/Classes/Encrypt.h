//
//  Encrypt.h
//  LoginManager
//
//  Created by Stan Liu on 06/04/2017.
//  Copyright © 2017 Stan Liu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Encrypt : NSString

+(NSString *)SHA512From:(NSString *)source;

@end
