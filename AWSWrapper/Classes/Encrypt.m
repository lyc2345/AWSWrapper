 //
//  Encrypt.m
//  LoginManager
//
//  Created by Stan Liu on 06/04/2017.
//  Copyright © 2017 Stan Liu. All rights reserved.
//

#import "Encrypt.h"
#import "DDTLog.h"

#include <CommonCrypto/CommonDigest.h>

@implementation Encrypt

+(NSString *)SHA512From:(NSString *)source {
	
  if (!source) {
    return nil;
  }
  
	const char *s = [source cStringUsingEncoding: NSASCIIStringEncoding];
	
  if (!s) {
    return nil;
  }
  
	NSData *keyData = [NSData dataWithBytes:s length: strlen(s)];
  
  if (!keyData) {
    return nil;
  }
	
	uint8_t digest[CC_SHA512_DIGEST_LENGTH] = {0};
	
	CC_SHA512(keyData.bytes, (CC_LONG)keyData.length, digest);
	
	NSData *out = [NSData dataWithBytes: digest length: CC_SHA512_DIGEST_LENGTH];
	
	NSString *output = [out description];
	NSString *finalOutput = [output stringByTrimmingCharactersInSet: [NSCharacterSet symbolCharacterSet]];
	
	//DLog(@"generate sha512: %@", finalOutput);
	
	return finalOutput;
	
}

@end
