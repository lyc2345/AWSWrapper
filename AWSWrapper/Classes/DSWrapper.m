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

+(NSDictionary *)diffWins:(NSDictionary *)wins loses:(NSDictionary *)loses primaryKey:(NSString *)key {
  
  return [DS diffWins: [DSWrapper arrayFromDict: wins]
                loses: [DSWrapper arrayFromDict: loses]
           primaryKey: key];
}


+(NSDictionary *)diffWins:(NSDictionary *)wins loses:(NSDictionary *)loses {

	return [DS diffWins: [DSWrapper arrayFromDict: wins]
						 loses: [DSWrapper arrayFromDict: loses]];
}

+(NSDictionary *)mergeInto:(NSDictionary *)into applyDiff:(NSDictionary *)diff {

	return [DSWrapper dictFromArray: [DS mergeInto: [DSWrapper arrayFromDict: into]
																			 applyDiff: diff]];
}

+(NSDictionary *)mergeInto:(NSDictionary *)into
                 applyDiff:(NSDictionary *)diff
                primaryKey:(NSString *)key
             shouldReplace:(BOOL (^)(id, id))shouldReplace {
  
  return [DSWrapper dictFromArray: [DS mergeInto: [DSWrapper arrayFromDict: into]
                                       applyDiff: diff
                                      primaryKey: key
                                   shouldReplace: shouldReplace]];
}

@end
