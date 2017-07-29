//
//  OfflineCognito.h
//  Pods
//
//  Created by Stan Liu on 29/07/2017.
//
//

#import <Foundation/Foundation.h>

@interface OfflineCognito : NSObject

-(void)storeUsername:(NSString *)username
            password:(NSString *)password;

-(BOOL)verifyUsername:(NSString *)username
             password:(NSString *)password;

-(void)modifyUsername:(NSString *)username
             password:(NSString *)password
             identity:(NSString *)identity;


-(NSArray *)allAccount:(NSError * __autoreleasing *)error;


@end
