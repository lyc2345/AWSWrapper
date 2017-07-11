//
//  DS.h
//  Differential
//
//  Created by Stan Liu on 22/04/2017.
//  Copyright © 2017 Stan Liu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DS : NSObject


/**
 (Depreated!) Use diffWins: andLoses:
 Get a diff between local and shadow

 @param client local data
 @param shadow shadow is the remote data since last time remote data apply local data diff
 @return a diff which is a dictionary that contains format: @{"add", "delete", "replace"} BUT replace is always nil, if you want to use replace argument. use [DS diffWins: andLoses: primaryKey:]
 */
+(NSDictionary *)diffShadowAndClient:(NSArray *)client
                              shadow:(NSArray *)shadow;


/**
 Get a diff between win and lose. Both win and lose are depend what data are you define.

 @param wins wins is the data that you think is most important
 @param loses loses is the data that you think is less important compares to wins
 
 @return a diff which is a dictionary that contains format: @{"add", "delete", "replace"}
 */
+(NSDictionary *)diffWins:(NSArray *)wins
                    loses:(NSArray *)loses;


/**
 Get a diff between win and lose.

 @param wins wins is the data that you think is most important
 @param loses loses is the data that you think is less important compares to wins
 @param key primary key of dictionary of datas
 
 @return a diff which is a dictionary and the format is @{"add", "delete", "replace"}
 */
+(NSDictionary *)diffWins:(NSArray *)wins
                    loses:(NSArray *)loses
               primaryKey:(NSString *)key;

/**
 Get a array that from old to new.

 @param into into the array that will be patched by diff.
 @param diff diff the diff object between two dictionaries. it contains keys ("add", "delete", "replace")
 @return return array that old data merge new diff.
 */
+(NSArray *)mergeInto:(NSArray *)into
            applyDiff:(NSDictionary *)diff;



/**
 Get a array that from diff and find duplicate.
 
 @param array into the array that will be patched by diff.
 @param diff diff the diff object between two dictionaries. it contains keys ("add", "delete", "replace")
 @param key primaryKey
 @param shouldReplace shouldReplace block sent a oldValue and newValue data and return a Boolean that you can choose that whether you want to replace it or not.

  @return return array that old data merge new diff.
 */
+(NSArray *)mergeInto:(NSArray *)array
            applyDiff:(NSDictionary *)diff
           primaryKey:(NSString *)key
        shouldReplace:(BOOL(^)(id oldValue, id newValue))shouldReplace;

@end


@interface Performance : NSObject

@end
