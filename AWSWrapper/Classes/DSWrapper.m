//
//  DSWrapper.m
//  DS
//
//  Created by Stan Liu on 11/05/2017.
//  Copyright © 2017 lyc2345. All rights reserved.
//

#import "DSWrapper.h"
#import "OfflineDB.h"
#import <DS/DS.h>

@implementation NSArray (Sort)

-(NSArray *)sort {

	return [self sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {

		NSString *author1 = obj1[@"author"];
		NSString *author2 = obj2[@"author"];

		return [author1 localizedStandardCompare: author2];
	}];
}

@end

@implementation DSWrapper

+(NSDictionary *)diffFormatFromConditionArray:(NSArray *)conditions {

	NSMutableArray *c = [NSMutableArray array];
	[conditions enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {

		for (NSObject *toAdd in (NSArray *)obj) {
			[c addObject: toAdd];
		}
	}];
	return @{@"_add": c};
}
/*
 +(NSDictionary *)differentialMergeBetweenClient:(NSDictionary *)client andRemote:(NSDictionary *)remote {

	NSDictionary *client_diff = [DS diffShadowAndClient: client];
	NSDictionary *remote_diff = [DS diffWins: remote andLoses: client];
	NSDictionary *mergedClient = [DS mergeInto: client applyDiff: client_diff];
	NSDictionary *mergedRemote = [DS mergeInto: mergedClient applyDiff: remote_diff];

	//[self push: mergedRemote];
	return mergedRemote;
 }

 +(NSDictionary *)differentialMergeWithClient:(NSDictionary *)client {

	NSDictionary *client_diff = [DS diffShadowAndClient: client];

	NSDictionary *mergedClient = [DS mergeInto: client applyDiff: client_diff];

	//[self push: mergedClient];
	return mergedClient;
 }*/

+(NSArray *)arrayFromDict:(NSDictionary *)dict {

	NSMutableArray *array = [NSMutableArray array];
	__block NSMutableDictionary *editDict = [NSMutableDictionary dictionary];
	[dict.allKeys enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {

		editDict = [dict[obj] mutableCopy];
		[editDict setObject: obj forKey: @"comicName"];

		[array addObject: editDict];
	}];
	return array;
}

+(NSDictionary *)dictFromArray:(NSArray *)array {

	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	[array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {

		NSMutableDictionary *mutableObj = [obj mutableCopy];
		[mutableObj removeObjectForKey: @"comicName"];
		[dict setObject: mutableObj forKey: obj[@"comicName"]];
	}];
	return dict;
}

+(NSDictionary *)diffShadowAndClient:(NSDictionary *)client isBookmark:(BOOL)isBookmark {

	return [DS diffShadowAndClient: [DSWrapper arrayFromDict: client]
									 shadow: [DSWrapper arrayFromDict: [OfflineDB shadowIsBookmark: isBookmark]]];
}

+(NSDictionary *)diffShadowAndClient:(NSDictionary *)client primaryKey:(NSString *)key isBookmark:(BOOL)isBookmark shouldReplace:(BOOL(^)(id oldValue, id newValue))shouldReplace {
  
  return [DS diffWins: [DSWrapper arrayFromDict: client]
             andLoses: [DSWrapper arrayFromDict: [OfflineDB shadowIsBookmark: isBookmark]]
           primaryKey: key
        shouldReplace: shouldReplace];
}

+(NSDictionary *)diffWins:(NSDictionary *)wins andLoses:(NSDictionary *)loses {

	return [DS diffWins: [DSWrapper arrayFromDict: wins]
						 andLoses: [DSWrapper arrayFromDict: loses]];
}

+(NSDictionary *)diffWins:(NSDictionary *)wins
                 andLoses:(NSDictionary *)loses
               primaryKey:(NSString *)key
            shouldReplace:(BOOL(^)(id oldValue, id newValue))shouldReplace {
  
  return [DS diffWins: [DSWrapper arrayFromDict: wins]
             andLoses: [DSWrapper arrayFromDict: loses]
           primaryKey: key
        shouldReplace: shouldReplace];
}

+(NSDictionary *)mergeInto:(NSDictionary *)into applyDiff:(NSDictionary *)diff {

	return [DSWrapper dictFromArray: [DS mergeInto: [DSWrapper arrayFromDict: into]
																			 applyDiff: diff]];
}


@end



@implementation DSWrapper (FakeData)

// fake data
+(NSDictionary *)client {
	return [[NSUserDefaults standardUserDefaults] dictionaryForKey: @"_client"];
}

+(void)setClient:(NSArray *)list {
	return [[NSUserDefaults standardUserDefaults] setObject: list forKey: @"_client"];
}

+(NSDictionary *)simulateRemote {
	return [[NSUserDefaults standardUserDefaults] dictionaryForKey: @"_simulate_remote"];
}


+(void)setSimulateRemote:(NSArray *)list {
	return [[NSUserDefaults standardUserDefaults] setObject: list forKey: @"_simulate_remote"];
}


// fake push for test
-(void)push:(NSArray *)list {

	[DSWrapper setClient: list];
	[DSWrapper setSimulateRemote: list];
	[OfflineDB setShadow:  [DSWrapper dictFromArray: list] isBookmark: YES];

	NSLog(@"client: %@", [DSWrapper client]);
	NSLog(@"shadow: %@", [OfflineDB shadowIsBookmark: YES]);
	NSLog(@"remote: %@", [DSWrapper simulateRemote]);
	//NSLog(@"shadow equal remote: %@", [[DS shadow] isEqualToDictionary: [DS simulateRemote]]);
}
@end
