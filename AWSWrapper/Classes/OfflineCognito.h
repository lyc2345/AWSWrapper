//
//  OfflineCognito.h
//  Pods
//
//  Created by Stan Liu on 29/07/2017.
//
//


@interface OfflineCognito : NSObject

+(OfflineCognito *)shared;

-(NSString *)identityId;

-(NSString *)passwordOfUser:(NSString *)username;

-(void)storeUsername:(NSString *)username
            password:(NSString *)password
          identityId:(NSString *)identityId;

-(BOOL)verifyUsername:(NSString *)username
             password:(NSString *)password;

-(void)modifyUsername:(NSString *)username
             password:(NSString *)password
           identityId:(NSString *)identityId;

@end
