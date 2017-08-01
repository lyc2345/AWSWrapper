//
//  OfflineCognito.h
//  Pods
//
//  Created by Stan Liu on 29/07/2017.
//
//


@interface OfflineCognito : NSObject

+(OfflineCognito *)shared;

-(NSString *)password;

-(void)storeUsername:(NSString *)username
            password:(NSString *)password
          identityId:(NSString *)identityId;

-(BOOL)verifyUsername:(NSString *)username
             password:(NSString *)password;

-(void)modifyUsername:(NSString *)username
             password:(NSString *)password
           identityId:(NSString *)identityId;


-(NSArray *)allAccount:(NSError * __autoreleasing *)error;


@end
