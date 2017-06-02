//
//  BookmarkManager.m
//
//  Created by Stan Liu on 16/03/2017.
//  Copyright © 2017 Stan Liu. All rights reserved.
//

#import "BookmarkManager.h"
#import "Bookmark.h"
#import "RecentVisit.h"
#import "DSWrapper.h"
#import "Random.h"

NSString * const __BOOKMARKS_LIST				= @"__BOOKMARKS_LIST";
NSString * const __RECENTLY_VISIT_LIST	= @"__RECENTLY_VISIT_LIST";

@implementation Bookmark (JSON)

+(Bookmark *)bookmarkWithDictionary:(NSDictionary *)dict {
	
	Bookmark *bookmark = [Bookmark new];
	bookmark._id = dict[@"_id"];
	bookmark._userId = dict[@"_userId"];
	bookmark._dicts = dict[@"_dicts"];
	bookmark._commitId = dict[@"_commitId"];
	bookmark._remoteHash = dict[@"_remoteHash"];
	return bookmark;
}
@end

@implementation RecentVisit (JSON)

+(RecentVisit *)bookmarkWithDictionary:(NSDictionary *)dict {
	
	RecentVisit *recentlyVisit = [RecentVisit new];
	recentlyVisit._id = dict[@"_id"];
	recentlyVisit._userId = dict[@"_userId"];
	recentlyVisit._dicts = dict[@"_dicts"];
	recentlyVisit._commitId = dict[@"_commitId"];
	recentlyVisit._remoteHash = dict[@"_remoteHash"];
	return recentlyVisit;
}
@end

// bookmark = Dictionary
// bookmarkList = Array(Dicionary)
// bookmarkRecord = Dicionary(list: bookmarkList)
// bookmarkRecords = Array(bookmarkRecords)

#pragma mark BookmarkManager (Bookmark&RecentlyVisit Format)

@implementation BookmarkManager

-(NSDictionary *)recordFormatOFIdentity:(NSString *)identity commitId:(NSString *)commitId andList:(NSArray *)list remoteHash:(NSString *)remoteHash {
	
	return @{@"_commitId": commitId != nil ? commitId : @"", @"_dicts": list, @"_identity": identity, @"_remoteHash": remoteHash};
}

#pragma mark - Conditional Write Format

+(AWSDynamoDBAttributeValue *)AWSFormatFromDict:(NSDictionary *)dict {
	
	AWSDynamoDBAttributeValue *authorValue = [AWSDynamoDBAttributeValue new];
	authorValue.S = dict[@"author"];
	AWSDynamoDBAttributeValue *urlValue = [AWSDynamoDBAttributeValue new];
	urlValue.S = dict[@"url"];
	
	NSDictionary<NSString *, AWSDynamoDBAttributeValue *> *awsMapValue = @{@"author": authorValue, @"url": urlValue};
	
	AWSDynamoDBAttributeValue *mapValue = [AWSDynamoDBAttributeValue new];
	mapValue.M = awsMapValue;
	
	return mapValue;
}

@end

@implementation BookmarkManager (Offline)

#pragma mark Common (Private)

// obtain the whole bookmark records of different users.
-(NSMutableArray *)obtainOfflineMutableRecordsOfType:(RecordType)type {
	
	NSArray *offlineRecords = [[NSUserDefaults standardUserDefaults] arrayForKey: type == RecordTypeBookmark ? __BOOKMARKS_LIST : __RECENTLY_VISIT_LIST];
	if (!offlineRecords) {
		offlineRecords = [NSArray array];
	}
	NSMutableArray *offlineMutableRecords = [offlineRecords mutableCopy];
	return offlineMutableRecords;
}

-(BOOL)setUserDefaultWithRecords:(NSArray *)records isBookmark:(BOOL)isBookmark {
	
	[[NSUserDefaults standardUserDefaults] setObject: records forKey: isBookmark ? __BOOKMARKS_LIST : __RECENTLY_VISIT_LIST];
	return [[NSUserDefaults standardUserDefaults] synchronize];
}

// obtain the record of THE login user. ["_identity": xxxxx, "_commitId": XXXXXX , "_list": [String: Dictionary]]
-(NSDictionary *)obtainOfflineExistRecordFromRecords:(NSArray *)records ofIdentity:(NSString *)identity {
	
	__block NSDictionary *dict;
	[records enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		
		NSString *localIdentity = obj[@"_identity"];
		if ([localIdentity isEqualToString: identity]) {
			
			//NSLog(@"identity: %@, has exist record: %@", identity, obj);
			dict = obj;
		}
	}];
	return (dict != nil) ? dict : [NSDictionary dictionary];
}

// replace the new bookmark list into the exist record in whole records.
-(NSArray *)modifyOfflineRecords:(NSArray *)records withRecord:(NSDictionary *)record ofIdentity:(NSString *)identity {
	
	NSMutableArray *mutableRecords = [records mutableCopy];
	__block bool isExist = false;
	[mutableRecords enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		isExist = false;
		if ([obj[@"_identity"] isEqualToString: identity]) {
			isExist = true;
			*stop = true;
			//NSLog(@"identity: %@, has exist record: %@", identity, obj);
		}
		if (stop) {
			NSMutableDictionary *mutableInfo = [obj mutableCopy];
			[mutableInfo setObject: record[@"_dicts"] forKey: @"_dicts"];
			[mutableInfo setObject: record[@"_commitId"] != nil ? record[@"_commitId"] : [Random string] forKey: @"_commitId"];
			[mutableInfo setObject: record[@"_remoteHash"] != nil ? record[@"_remoteHash"] : [Random string] forKey: @"_remoteHash"];
			[mutableRecords replaceObjectAtIndex: idx withObject: mutableInfo];
			return;
		}
	}];
	
	if (!isExist) {
		
		[mutableRecords addObject: [self recordFormatOFIdentity: identity commitId: [Random string] andList: record[@"_dicts"] remoteHash: [Random string]]];
	}
	return [mutableRecords copy];
}

#pragma mark - Bookmark (Private)

-(NSDictionary *)setOfflineNewRecord:(NSDictionary *)record type:(RecordType)type identity:(NSString *)identity {
	
	NSArray *records = [self obtainOfflineMutableRecordsOfType: type];
	NSArray *modifiedOfflineRecords;
	BOOL success;
	
	modifiedOfflineRecords = [self modifyOfflineRecords: records withRecord: record ofIdentity: identity];
	success = [self setUserDefaultWithRecords: modifiedOfflineRecords isBookmark: type == RecordTypeBookmark];
	
	if (success) {
		return record;
	} else {
		return nil;
	}
}

-(void)pushSuccessThenSaveLocalRecord:(id<RecordSuitable>)newRecord type:(RecordType)type newCommitId:(NSString *)commitId {
	
	NSArray *records = [self obtainOfflineMutableRecordsOfType: type];
	
	NSMutableDictionary *oldRecord = [[self obtainOfflineExistRecordFromRecords: records ofIdentity: newRecord._userId] mutableCopy];
	[oldRecord setValue: newRecord._dicts				forKey: @"_dicts"];
	[oldRecord setValue: commitId						forKey: @"_commitId"];
	[oldRecord setValue: newRecord._remoteHash	forKey: @"_remoteHash"];
	NSArray *modifiedOfflineRecords = [self modifyOfflineRecords: records withRecord: oldRecord ofIdentity: newRecord._userId];
	
	[self setUserDefaultWithRecords: modifiedOfflineRecords isBookmark: type == RecordTypeBookmark];
	[DSWrapper setShadow: newRecord._dicts isBookmark: type == RecordTypeBookmark];
}

#pragma mark - Bookmark (Open)

-(void)addOffline:(NSDictionary *)r type:(RecordType)type ofIdentity:(NSString *)identity {
	
	NSArray *records = [self obtainOfflineMutableRecordsOfType: type];
	
	NSMutableDictionary *record = [[self obtainOfflineExistRecordFromRecords: records ofIdentity: identity] mutableCopy];
	NSMutableArray *list = [[DSWrapper arrayFromDict: record[@"_dicts"]] mutableCopy];
	__block bool isExist = false;
	
	[list enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		
		if ([obj[@"url"] isEqualToString: r[@"url"]] &&
				[obj[@"author"] isEqualToString: r[@"author"]]) {
			isExist = YES;
			*stop = YES;
			return;
		}
		isExist = NO;
	}];
	
	if (!list) {
		list = [NSMutableArray array];
	}
	if (!isExist) {
		[list addObject: r];
	}
	
	[record setValue: [DSWrapper dictFromArray: list] forKey: @"_dicts"];
	[self setOfflineNewRecord: record type: type identity: identity];
}

-(NSDictionary *)deleteOffline:(NSDictionary *)r type:(RecordType)type ofIdentity:(NSString *)identity {
	
	NSArray *records = [self obtainOfflineMutableRecordsOfType: type];
	
	NSMutableDictionary *record = [[self obtainOfflineExistRecordFromRecords: records ofIdentity: identity] mutableCopy];
	NSMutableArray *list = [[DSWrapper arrayFromDict: (NSDictionary *)record[@"_dicts"]] mutableCopy];
	
	if (!list) {
		return record;
	}
	
	NSMutableArray *editedList = [NSMutableArray array];
	
	for (NSDictionary *bk in list) {
		if (![bk isEqualToDictionary: r]) {
			[editedList addObject: bk];
		}
	}
	[record setValue: [DSWrapper dictFromArray: editedList] forKey: @"_dicts"];
	return [self setOfflineNewRecord: record type: type identity: identity];
}

-(NSDictionary *)getOfflineRecordOfIdentity:(NSString *)identity type:(RecordType)type {
	
	NSArray *offlineRecords = [self obtainOfflineMutableRecordsOfType: type];
	return [self obtainOfflineExistRecordFromRecords: offlineRecords ofIdentity: identity];
}

@end

#pragma mark (AWS)

@implementation BookmarkManager (AWS)

-(void)pull:(Class)aClass withUser:(NSString *)userId  completion:(void(^)(NSArray *items, NSError *error))completionHandler {
	
	AWSDynamoDBObjectMapper *objectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
	
	AWSDynamoDBQueryExpression *queryExpression = [AWSDynamoDBQueryExpression new];
	queryExpression.keyConditionExpression = @"#userId = :userId";
	queryExpression.expressionAttributeNames = @{@"#userId": @"userId"};
	queryExpression.expressionAttributeValues = @{
																								@":userId" : userId,
																								};
	[objectMapper query: aClass
					 expression: queryExpression
		completionHandler: ^(AWSDynamoDBPaginatedOutput * _Nullable response, NSError * _Nullable error) {
			
			if (error) {
				NSLog(@"AWS DynamoDB load error: %@", error);
				completionHandler(nil, error);
				return;
			}
			NSLog(@"AWS DynamoDB load successfull");
			NSLog(@"With data: %@", response);
			/*
			 for (Bookmark *bk in response.items) {
			 NSLog(@"bookmark: %@", bk);
			 }
			 */
			completionHandler(response.items, nil);
		}];
}

-(void)forcePushWithObject:(id<RecordSuitable>)bkSuitable completion:(void(^)(NSError *error))completion {
	
	AWSDynamoDBObjectMapper *objectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
	
	bkSuitable._commitId = [Random string];
	
	[objectMapper save: (AWSDynamoDBObjectModel<AWSDynamoDBModeling> *)bkSuitable completionHandler:^(NSError * _Nullable error) {
		
		if (error) {
			NSLog(@"AWS DynamoDB save error: %@", error);
			completion(error);
			return;
		}
		NSLog(@"AWS DynamoDB save successful");
		RecordType type = [bkSuitable isKindOfClass: [Bookmark class]] ? RecordTypeBookmark : RecordTypeRecentlyVisit;
		[self pushSuccessThenSaveLocalRecord: bkSuitable type: type newCommitId: bkSuitable._commitId];
		completion(nil);
	}];
}

-(void)mergePushWithClient:(id<RecordSuitable>)client remote:(id<RecordSuitable>)remote new:(id<RecordSuitable>)new completion:(void (^)(NSError *))mergeCompletion {
	
	NSDictionary *diff_client_shadow = [DSWrapper diffShadowAndClient: client._dicts isBookmark: [client isKindOfClass: [Bookmark class]]];
	
	[self pushWithObject: client diff: diff_client_shadow completion:^(AWSDynamoDBUpdateItemOutput *response, NSError *error, NSString *commitId) {
		NSLog(@"1: Done");
		if (!error) {
			// expected commit id meet localBookmarkRecord commit id
			// successed!
			NSLog(@"please success here la");
			//NSLog(@"first push success with object: %@", response);
			[self pushSuccessThenSaveLocalRecord: client type: [client isKindOfClass: [Bookmark class]] ? RecordTypeBookmark : RecordTypeRecentlyVisit newCommitId: commitId];
			
			mergeCompletion(error);
			return;
			
		} else {
			NSLog(@"conditional error: %@", error);
			
			NSLog(@"starting pull...");
			NSLog(@"2");
			
			[self pull: [client class] withUser: client._userId completion:^(NSArray *items, NSError *error) {
				NSLog(@"2: Done");
				NSLog(@"pull finished");
				if (error) {
					NSLog(@"BookmarkManager pull error: %@", error);
					return;
					
				} else {
					id<RecordSuitable> cloud = items.firstObject;
					
					NSLog(@"3");
					if (!cloud) {
						
						remote._id = client._userId;
						remote._userId = client._userId;
						remote._dicts = client._dicts;
						remote._commitId = [Random string];
						remote._remoteHash = [Random string];
						NSLog(@"remote is empty, push...");
						
						[self forcePushWithObject: remote completion:^(NSError *error) {
							if (!error) { NSLog(@"FORCE push success with reocrd: %@", remote); }
							NSLog(@"3: Done");
							RecordType type = [client isKindOfClass: [Bookmark class]] ? RecordTypeBookmark : RecordTypeRecentlyVisit;
							[self pushSuccessThenSaveLocalRecord: remote type: type newCommitId: commitId];
							
							mergeCompletion(error);
						}];
						
					} else {
						
						NSLog(@"3: Done");
						NSLog(@"remote version: %@, local version: %@", cloud._remoteHash, client._remoteHash);
						NSLog(@"remote timestamp: %@, local timestamp: %@", cloud._commitId, client._commitId);
						NSLog(@"starting diffmerge...");
						// diff
						NSLog(@"4");
						NSDictionary *need_to_apply_to_client = [DSWrapper diffWins: cloud._dicts andLoses: client._dicts];
						NSDictionary *newClient = [DSWrapper applyInto: client._dicts From: need_to_apply_to_client];
						
						new._id = cloud._userId;
						new._userId = cloud._userId;
						new._dicts = newClient;
						new._commitId = cloud._commitId;
						new._remoteHash = cloud._remoteHash;
						
						NSLog(@"5");
						if (!cloud._remoteHash) {
							
							new._commitId = [Random string];
							new._remoteHash = [Random string];
							NSLog(@"Remote hash is nil, force push whole local record");
							[self forcePushWithObject: new completion:^(NSError *error) {
								NSLog(@"5: Done by force");
								
								RecordType type = [client isKindOfClass: [Bookmark class]] ? RecordTypeBookmark : RecordTypeRecentlyVisit;
								[self pushSuccessThenSaveLocalRecord: new type: type newCommitId: commitId];
								mergeCompletion(error);
							}];
						} else {
							
							NSLog(@"conditional push whole local record");
							newClient = [DSWrapper applyInto: newClient From: diff_client_shadow];
							NSDictionary *need_to_apply_to_remote = [DSWrapper diffWins: newClient andLoses: cloud._dicts];
							
							[self pushWithObject: new diff: need_to_apply_to_remote completion:^(AWSDynamoDBUpdateItemOutput *response, NSError *error, NSString *commitId) {
								
								if (error) {
									NSLog(@"conditional push error: %@", error);
									NSLog(@"fuckkkkkkkkkkkkkkkk");
									return;
								}
								NSLog(@"push success after diffmerge");
								NSLog(@"5: Done by conditonal update");
								new._dicts = newClient;
								RecordType type = [client isKindOfClass: [Bookmark class]] ? RecordTypeBookmark : RecordTypeRecentlyVisit;
								[self pushSuccessThenSaveLocalRecord: new type: type newCommitId: commitId];
								mergeCompletion(error);
							}];
						}
					}
				}
			}];
		}
	}];
}

-(void)mergePushWithRecord:(id<RecordSuitable>)record type:(RecordType)type completion:(void(^)(NSError *error))mergeCompletion {
	
	if (type == RecordTypeBookmark) {
		
		Bookmark *remote = [Bookmark new];
		Bookmark *new = [Bookmark new];
		[self mergePushWithClient: record remote: remote new: new completion: mergeCompletion];
		return;
		
	} else if (type == RecordTypeRecentlyVisit) {

		
		RecentVisit *remote = [RecentVisit new];
		RecentVisit *new = [RecentVisit new];
		[self mergePushWithClient: record remote: remote new: new completion: mergeCompletion];
		return;
		
	} else {
		assert(@"you need to specfic a type use RecordType enum");
	}
}

-(void)mergePushWithObjct:(NSArray *)object commitId:(NSString *)commitId remoteHash:(NSString *)remoteHash type:(RecordType)type ofUserId:(NSString *)userId completion:(void(^)(NSError *error))mergeCompletion {
	
	if (type == RecordTypeBookmark) {
		Bookmark *book = [Bookmark new];
		book._id = userId;
		book._userId = userId;
		book._dicts = [DSWrapper dictFromArray: object];
		book._commitId = commitId;
		book._remoteHash = remoteHash;
		
		Bookmark *remote = [Bookmark new];
		Bookmark *new = [Bookmark new];
		[self mergePushWithClient: book remote: remote new: new completion: mergeCompletion];
		return;
		
	} else if (type == RecordTypeRecentlyVisit) {
		RecentVisit *visit = [RecentVisit new];
		visit._id = userId;
		visit._userId = userId;
		visit._dicts = [DSWrapper dictFromArray: object];
		visit._commitId = commitId;
		visit._remoteHash = remoteHash;
		
		RecentVisit *remote = [RecentVisit new];
		RecentVisit *new = [RecentVisit new];
		[self mergePushWithClient: visit remote: remote new: new completion: mergeCompletion];
		return;
		
	} else {
		assert(@"you need to specfic a type use RecordType enum");
	}
}
/*
-(void)mergePushWithBook:(id<RecordSuitable>)book completion:(void(^)(NSError *error))mergeCompletion {
	
	Bookmark *remote = [Bookmark new];
	Bookmark *new = [Bookmark new];
	
	[self mergePushWithClient: book remote: remote new: new completion: mergeCompletion];
}

-(void)mergePushWithRecentlyVisit:(id<RecordSuitable>)visit completion:(void(^)(NSError *error))mergeCompletion {
	
	RecentVisit *remote = [RecentVisit new];
	RecentVisit *new = [RecentVisit new];
	
	[self mergePushWithClient: visit remote: remote new: new completion: mergeCompletion];
}*/

-(void)pushWithObject:(id<RecordSuitable>)record diff:(NSDictionary *)diff completion:(void(^)(AWSDynamoDBUpdateItemOutput *response, NSError *error, NSString *commitId))completion {
	
	NSString *commitId = [Random string];
	NSString *remoteHash = record._remoteHash != nil ? record._remoteHash : [Random string];
	
	AWSDynamoDB *dynamoDB = [AWSDynamoDB defaultDynamoDB];
	AWSDynamoDBUpdateItemInput *updateInput = [AWSDynamoDBUpdateItemInput new];
	
	AWSDynamoDBAttributeValue *identityValue = [AWSDynamoDBAttributeValue new];
	identityValue.S = record._userId;
	
	if ([record isKindOfClass: [Bookmark class]]) {
		
		updateInput.tableName = [Bookmark dynamoDBTableName];
	} else {
		updateInput.tableName = [RecentVisit dynamoDBTableName];
	}
	
	
	updateInput.key = @{ @"userId": identityValue, @"id": identityValue };
	
	// commit id
	AWSDynamoDBAttributeValue *oldCommitIdValue = [AWSDynamoDBAttributeValue new];
	oldCommitIdValue.S = record._commitId;
	
	AWSDynamoDBAttributeValue *newCommitIdValue = [AWSDynamoDBAttributeValue new];
	newCommitIdValue.S = commitId;
	
	AWSDynamoDBAttributeValue *remoteHashValue = [AWSDynamoDBAttributeValue new];
	remoteHashValue.S = remoteHash;
	
	NSArray *addList = diff[@"_add"];
	NSArray *delList = diff[@"_delete"];
	
	// attributeValues
	NSMutableDictionary *attributeValues = [NSMutableDictionary dictionary];
	// attributeNames
	NSMutableDictionary *attributeNames = [NSMutableDictionary dictionary];
	
	NSMutableString *addString = [NSMutableString string];
	[addList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		
		NSString *additionAttributeValueKey = [NSString stringWithFormat: @":%@", obj[@"comicName"]];
		NSString *additionAttributeNameKey = [NSString stringWithFormat: @"#%@", obj[@"comicName"]];
		
		[attributeValues setObject: [BookmarkManager AWSFormatFromDict: obj] forKey: additionAttributeValueKey];
		[attributeNames setObject: obj[@"comicName"] forKey: additionAttributeNameKey];
		
		NSString *key = [NSString stringWithFormat: @", #dicts.%@ = %@", additionAttributeNameKey, additionAttributeValueKey];
		[addString appendString: key];
	}];
	
	NSMutableString *delString = [NSMutableString string];
	[delList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		
		NSString *key;
		if (delList.count - 1 == idx) {
			key = [NSString stringWithFormat: @"dicts.%@", obj[@"comicName"]];
		} else {
			key = [NSString stringWithFormat: @"dicts.%@, ", obj[@"comicName"]];
		}
		[delString appendString: key];
	}];
	
	[attributeValues setObject: newCommitIdValue forKey: @":nci"];
	if (oldCommitIdValue.S) {
		[attributeValues setObject: oldCommitIdValue forKey: @":oci"];
	}
	[attributeValues setObject: remoteHashValue forKey: @":exprh"];
	updateInput.expressionAttributeValues = attributeValues;
	
	NSMutableString *updateExpressionString = [NSMutableString string];
	// first append commit id everytime.
	[updateExpressionString appendString: @"SET #commitId = :nci"];
	[attributeNames setObject: @"commitId" forKey: @"#commitId"];
	
	// second append the expression if needed
	if (!addString || ![addString isEqualToString: @""]) {
		
		[attributeNames setObject: @"dicts" forKey: @"#dicts"];
		[updateExpressionString appendString: addString];
		
	} else if (!delString || ![delString isEqualToString: @""]) {

		[updateExpressionString appendString: [NSString stringWithFormat: @" REMOVE %@", delString]];
	}
	
	updateInput.expressionAttributeNames = attributeNames;
	updateInput.updateExpression		= updateExpressionString;
	
	NSMutableString *conditionString = [NSMutableString string];
	// condition append commit id for define which device commit
	if (oldCommitIdValue.S) {
		[conditionString appendString: @"commitId = :oci and "];
	}
	// condition append commit id for define server is reset or not
	[conditionString appendString: @"remoteHash = :exprh "];
	
	[addList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		
		[conditionString appendString: [NSString stringWithFormat: @"and attribute_not_exists(dict.#%@) ", obj[@"comicName"]]];
	}];
	
	updateInput.conditionExpression = conditionString;
	
	updateInput.returnValues = AWSDynamoDBReturnValueAllNew;
	
	[[dynamoDB updateItem: updateInput] continueWithBlock:^id(AWSTask *task) {
		
		completion(task.result, task.error, commitId);
		return nil;
	}];
}

@end
