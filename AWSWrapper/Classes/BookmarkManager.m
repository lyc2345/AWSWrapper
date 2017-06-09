
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

// bookmark = Dictionary
// bookmarkList = Array(Dicionary)
// bookmarkRecord = Dicionary(list: bookmarkList)
// bookmarkRecords = Array(bookmarkRecords)

#pragma mark BookmarkManager (Bookmark&RecentlyVisit Format)

@implementation BookmarkManager

+(NSDictionary *)convert:(NSDictionary *)attributeDictionary {
  
  AWSDynamoDBAttributeValue *dictsValue = attributeDictionary[@"dicts"];
  AWSDynamoDBAttributeValue *remoteHash = attributeDictionary[@"remoteHash"];
  AWSDynamoDBAttributeValue *commitId = attributeDictionary[@"commitId"];
  AWSDynamoDBAttributeValue *userId = attributeDictionary[@"userId"];
  
  if (dictsValue == nil || remoteHash == nil || commitId == nil) {
    return nil;
  }
  
  NSDictionary *dicts = dictsValue.M;
  NSMutableDictionary *pureDicts = [NSMutableDictionary dictionary];
  
  for (NSString *key in dicts.allKeys) {
    
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    AWSDynamoDBAttributeValue *infoValue = dicts[key];
    NSDictionary *comic = infoValue.M;
    AWSDynamoDBAttributeValue *authorValue = comic[@"author"];
    AWSDynamoDBAttributeValue *urlValue = comic[@"url"];
    
    [info setObject: authorValue.S forKey: @"author"];
    [info setObject: urlValue.S forKey: @"url"];
    [pureDicts setObject: info forKey: key];
  }
  
  NSMutableDictionary *record = [NSMutableDictionary dictionary];
  [record setObject: pureDicts forKey: @"_dicts"];
  [record setObject: remoteHash.S forKey: @"_remoteHash"];
  [record setObject: commitId.S forKey: @"_commitId"];
  [record setObject: userId.S forKey: @"_userId"];
  [record setObject: userId.S forKey: @"_id"];
  
  return record;
}

-(NSDictionary *)recordFormatOFIdentity:(NSString *)identity commitId:(NSString *)commitId andList:(NSArray *)list remoteHash:(NSString *)remoteHash {
	
	return @{@"_commitId": commitId != nil ? commitId : @"", @"_dicts": list, @"_userId": identity, @"_remoteHash": remoteHash};
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
	
  // get the multiple users record first
	NSArray *offlineRecords = [[NSUserDefaults standardUserDefaults] arrayForKey: type == RecordTypeBookmark ? __BOOKMARKS_LIST : __RECENTLY_VISIT_LIST];
  
  // create it if dosen't exist any
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

// get the record of the current login user.
// ["_identity": xxxxx, "_commitId": XXXXXX , "_list": [String: Dictionary]]
-(NSDictionary *)obtainOfflineExistRecordFromRecords:(NSArray *)records ofIdentity:(NSString *)identity {
	
	__block NSDictionary *dict;
	[records enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		
		NSString *localIdentity = obj[@"_userId"];
		if ([localIdentity isEqualToString: identity]) {
			
			//NSLog(@"identity: %@, has exist record: %@", identity, obj);
			dict = obj;
		}
	}];
	return (dict != nil) ? dict : [NSDictionary dictionary];
}

// replace the new bookmark list into the exist record in multiple records.
-(NSArray *)modifyOfflineRecords:(NSArray *)records withRecord:(NSDictionary *)record ofIdentity:(NSString *)identity {
	
	NSMutableArray *mutableRecords = [records mutableCopy];
	__block bool isExist = false;
	[mutableRecords enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		isExist = false;
		if ([obj[@"_userId"] isEqualToString: identity]) {
			isExist = true;
			*stop = true;
			//NSLog(@"identity: %@, has exist record: %@", identity, obj);
		}
		if (stop) {
			NSMutableDictionary *mutableInfo = [obj mutableCopy];
			[mutableInfo setObject: record[@"_dicts"] forKey: @"_dicts"];
      
      // if commit and remoteHash is nil, set a new one
			[mutableInfo setObject:
       record[@"_commitId"] != nil ? record[@"_commitId"] : [Random string]
                      forKey: @"_commitId"];
			[mutableInfo setObject:
       record[@"_remoteHash"] != nil ? record[@"_remoteHash"] : [Random string]
                      forKey: @"_remoteHash"];
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

-(BOOL)pushSuccessThenSaveLocalRecord:(NSDictionary *)newRecord type:(RecordType)type newCommitId:(NSString *)commitId {
	
	NSArray *records = [self obtainOfflineMutableRecordsOfType: type];
	
	NSMutableDictionary *oldRecord = [[self obtainOfflineExistRecordFromRecords: records ofIdentity: newRecord[@"_userId"]] mutableCopy];
	[oldRecord setValue: newRecord[@"_dicts"]	forKey: @"_dicts"];
	[oldRecord setValue: commitId	forKey: @"_commitId"];
	[oldRecord setValue: newRecord[@"_remoteHash"] forKey: @"_remoteHash"];
  [oldRecord setValue: newRecord[@"_userId"] forKey: @"_userId"];
	NSArray *modifiedOfflineRecords = [self modifyOfflineRecords: records withRecord: oldRecord ofIdentity: newRecord[@"_userId"]];
	
	BOOL success = [self setUserDefaultWithRecords: modifiedOfflineRecords isBookmark: type == RecordTypeBookmark];
  if (success) {
    BOOL saveShadowSuccess = [DSWrapper setShadow: newRecord[@"_dicts"] isBookmark: type == RecordTypeBookmark];
    return saveShadowSuccess;
  } else {
    return NO;
  }
}

#pragma mark - Bookmark (Open)

-(void)addOffline:(NSDictionary *)r type:(RecordType)type ofIdentity:(NSString *)identity {
  
  if ([r[@"author"] isEqualToString: @""] || [r[@"comicName"] isEqualToString: @""] || [r[@"url"] isEqualToString: @""]) {
    NSLog(@"author, comicName, url is nil in Dictionary");
    return;
  }
	
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

-(void)pullType:(RecordType)type user:(NSString *)userId completion:(void(^)(NSDictionary *item, NSError *error))completionHandler {
  
  AWSDynamoDB *dynamoDB = [AWSDynamoDB defaultDynamoDB];
  AWSDynamoDBQueryInput *queryInput = [AWSDynamoDBQueryInput new];
  
  AWSDynamoDBAttributeValue *identityValue = [AWSDynamoDBAttributeValue new];
  identityValue.S = userId;
  
  queryInput.tableName =  type == RecordTypeBookmark ? [Bookmark dynamoDBTableName] : [RecentVisit dynamoDBTableName];
  queryInput.projectionExpression = @"userId, dicts, commitId, remoteHash";
  queryInput.keyConditionExpression = [NSString stringWithFormat: @"userId = :val"];
  queryInput.expressionAttributeValues = @{@":val": identityValue};
  
  [dynamoDB query: queryInput completionHandler:^(AWSDynamoDBQueryOutput * _Nullable response, NSError * _Nullable error) {
    
    if (error) {
      NSLog(@"AWS DynamoDB load error: %@", error);
      completionHandler(nil, error);
      return;
    }
    NSLog(@"AWS DynamoDB load successfull");
    
    if (response.items != nil && response.items.count > 0) {
      
      NSDictionary *attributeDictionary = response.items.firstObject;
      NSDictionary *record = [BookmarkManager convert: attributeDictionary];
      completionHandler(record, nil);
      
    } else {
      completionHandler(nil, nil);
    }
  }];
}

-(void)pullClass:(Class)aClass withUser:(NSString *)userId  completion:(void(^)(NSArray *items, NSError *error))completionHandler {
	
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
			completionHandler(response.items, nil);
		}];
}

-(void)forcePushWithObject:(id<RecordSuitable>)bkSuitable completion:(void(^)(NSError *error, NSDictionary *item))completion {
  
  AWSDynamoDBObjectMapper *objectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
  
  bkSuitable._commitId = [Random string];
  [objectMapper save: (AWSDynamoDBObjectModel<AWSDynamoDBModeling> *)bkSuitable completionHandler:^(NSError * _Nullable error) {
    
    if (error) {
      NSLog(@"AWS DynamoDB save error: %@", error);
      completion(error, nil);
      return;
    }
    NSLog(@"AWS DynamoDB save successful");
    RecordType type = [bkSuitable isKindOfClass: [Bookmark class]] ? RecordTypeBookmark : RecordTypeRecentlyVisit;
    NSMutableDictionary *record = [NSMutableDictionary dictionary];
    [record setObject: bkSuitable._commitId forKey: @"_commitId"];
    [record setObject: bkSuitable._remoteHash forKey: @"_remoteHash"];
    [record setObject: bkSuitable._id forKey: @"_id"];
    [record setObject: bkSuitable._userId forKey: @"_userId"];
    [record setObject: bkSuitable._dicts forKey: @"_dicts"];
    BOOL success = [self pushSuccessThenSaveLocalRecord: record type: type newCommitId: bkSuitable._commitId];
    success == YES ? completion(nil, record) : completion;
  }];
}


-(void)forcePushWithType:(RecordType)type record:(NSDictionary *)record userId:(NSString *)userId completion:(void(^)(NSDictionary *item, NSError *error, NSString *commitId))completion {
	
  NSString *commitId = [Random string];
  NSString *remoteHash = [Random string];
  
  AWSDynamoDB *dynamoDB = [AWSDynamoDB defaultDynamoDB];
  AWSDynamoDBPutItemInput *putItemInput = [AWSDynamoDBPutItemInput new];
  
  AWSDynamoDBAttributeValue *identityValue = [AWSDynamoDBAttributeValue new];
  // Identity is the key for offline record
  identityValue.S = userId;
  
  if (type == RecordTypeBookmark) {
    
    putItemInput.tableName = [Bookmark dynamoDBTableName];
  } else {
    putItemInput.tableName = [RecentVisit dynamoDBTableName];
  }
  
  //putItemInput.key = @{ @"userId": identityValue, @"id": identityValue };
  
  // commit id
  AWSDynamoDBAttributeValue *newCommitIdValue = [AWSDynamoDBAttributeValue new];
  newCommitIdValue.S = commitId;
  
  AWSDynamoDBAttributeValue *remoteHashValue = [AWSDynamoDBAttributeValue new];
  remoteHashValue.S = remoteHash;
  
  NSArray *addList = [DSWrapper arrayFromDict: record[@"_dicts"]];
  
  // attributeValues
  NSMutableDictionary *attributeValues = [NSMutableDictionary dictionary];
  // attributeNames
//  NSMutableDictionary *attributeNames = [NSMutableDictionary dictionary];
  
//  NSMutableString *addString = [NSMutableString string];
  AWSDynamoDBAttributeValue *eachValue = [AWSDynamoDBAttributeValue new];
  [addList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
    
    NSString *additionAttributeValueKey = [NSString stringWithFormat: @"%@", obj[@"comicName"]];
    //NSString *additionAttributeNameKey = [NSString stringWithFormat: @"#%@", obj[@"comicName"]];
    
    [attributeValues setObject: [BookmarkManager AWSFormatFromDict: obj] forKey: additionAttributeValueKey];
//    [attributeValues setObject: [BookmarkManager AWSFormatFromDict: obj] forKey: additionAttributeValueKey];
    //[attributeNames setObject: obj[@"comicName"] forKey: additionAttributeNameKey];
    
    //NSString *key = [NSString stringWithFormat: @", #dicts.%@ = %@", additionAttributeNameKey, additionAttributeValueKey];
    //[addString appendString: key];
  }];
  
//  [attributeValues setObject: newCommitIdValue forKey: @":nci"];
//  [attributeValues setObject: remoteHashValue forKey: @":exprh"];
//  [attributeValues setObject: identityValue forKey: @":uid"];
  //putItemInput.expressionAttributeValues = attributeValues;
  
//  NSMutableString *updateExpressionString = [NSMutableString string];
  // first append commit id everytime.
////  [updateExpressionString appendString: @"SET #commitId = :nci, #remoteHash = :exprh"];
//  [attributeNames setObject: @"commitId" forKey: @"#commitId"];
//  [attributeNames setObject: @"remoteHash" forKey: @"#remoteHash"];
//  
//  // second append the expression if needed
//  if (!addString || ![addString isEqualToString: @""]) {
//    
//    [attributeNames setObject: @"dicts" forKey: @"#dicts"];
//    [updateExpressionString appendString: addString];
//  }
  
  
  //putItemInput.expressionAttributeNames = @{@":uid": identityValue};
  //putItemInput.expressionAttributeNames = attributeNames;
  AWSDynamoDBAttributeValue *dictsValue = [AWSDynamoDBAttributeValue new];
  dictsValue.M = attributeValues;
  
  putItemInput.item = @{@"userId": identityValue,
                        @"id": identityValue,
                        @"commitId": newCommitIdValue,
                        @"remoteHash": remoteHashValue,
                        @"dicts": dictsValue
                        };
  //putItemInput.conditionExpression = @"userId = :uid and attribute_not_exists(dicts)";
  //putItemInput.conditionExpression = @"userId = :uid";
  
  
  /*
  NSMutableString *conditionString = [NSMutableString string];
  // condition append commit id for define server is reset or not
  [conditionString appendString: @"remoteHash = :exprh "];
  
  [addList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
    
    [conditionString appendString: [NSString stringWithFormat: @"and attribute_not_exists(dict.#%@) ", obj[@"comicName"]]];
  }];
  updateInput.conditionExpression = conditionString;
   */
  
  putItemInput.returnValues = AWSDynamoDBReturnValueNone;
  
  [[dynamoDB putItem: putItemInput] continueWithBlock:^id(AWSTask *task) {
    
    if (task.error) {
      NSLog(@"force push error: %@", task.error);
      completion(nil, task.error, nil);
      return nil;
    } else {
      AWSDynamoDBUpdateItemOutput *result = task.result;
      NSDictionary *resultValue = result.dictionaryValue;
      NSDictionary *pureResult = [BookmarkManager convert: resultValue[@"attributes"]];
      completion(pureResult, task.error, commitId);
    }
    return nil;
  }];
}

-(void)mergePushType:(RecordType)type userId:(NSString *)userId completion:(void(^)(NSDictionary *responseItem, NSError *error))mergeCompletion {
	
  // Diff local and shadow first, should know the modifies.
  NSDictionary *local = [self getOfflineRecordOfIdentity: userId type: type];
	NSDictionary *diff_client_shadow = [DSWrapper diffShadowAndClient: local[@"_dicts"] isBookmark: type == RecordTypeBookmark];
  
  NSLog(@"start: 1");
  // push local AWS model and the diff we get before.
  [self pushWithObject: local type: type diff: diff_client_shadow userId: userId completion:^(NSDictionary *responseItem, NSError *error, NSString *commitId) {
    
    NSLog(@"done 1");
		if (!error) {
			// expected commit id meet localBookmarkRecord commit id
			// successed!
			NSLog(@"push success by merge push at the first place");
			//NSLog(@"first push success with object: %@", response);
			[self pushSuccessThenSaveLocalRecord: local type: type newCommitId: commitId];
			
			mergeCompletion(responseItem, error);
			return;
			
		} else {
			NSLog(@"first conditional write error: %@", error);
			
			NSLog(@"starting pulling...");
			NSLog(@"start 2");
      [self pullType: type user: userId completion:^(NSDictionary *item, NSError *error) {

				NSLog(@"done 2");
				NSLog(@"pull finished");
				if (error) {
					NSLog(@"BookmarkManager pull error: %@", error);
					return;
					
				} else {
          NSMutableDictionary *cloud = [item mutableCopy];
					
					NSLog(@"start 3");
					if (!cloud) {
            
						NSLog(@"remote is empty, push...");
#if 0
            Bookmark *bk = [Bookmark new];
            bk._userId = userId;
            bk._id = userId;
            bk._commitId = [Random string];
            bk._remoteHash = [Random string];
            bk._dicts = local[@"_dicts"];
            [self forcePushWithObject:bk completion:^(NSError *error, NSDictionary *item) {
              
            }];*/
#else
            [self forcePushWithType: type record: local userId: userId completion:^(NSDictionary *item, NSError *error, NSString *commitId) {
              
              NSLog(@"done 3");
							if (!error) {
                NSLog(@"FORCE push success with reocrd: %@", local);
                [self pushSuccessThenSaveLocalRecord: local type: type newCommitId: commitId];
              }
							mergeCompletion(item, error);
						}];
#endif
					} else {
						
						NSLog(@"done 3");
						NSLog(@"remote version: %@, local version: %@", cloud[@"_remoteHash"], local[@"_remoteHash"]);
						NSLog(@"remote timestamp: %@, local timestamp: %@", cloud[@"_commitId"], local[@"_commitId"]);
						NSLog(@"starting diffmerge...");
						// diff
						NSLog(@"start 4: diffmerge");
						NSDictionary *need_to_apply_to_client = [DSWrapper diffWins: cloud[@"_dicts"] andLoses: local[@"_dicts"]];
						NSDictionary *newClientDicts = [DSWrapper applyInto: local[@"_dicts"] From: need_to_apply_to_client];
						
            NSMutableDictionary *new = [NSMutableDictionary dictionary];
            
            [new setObject: cloud[@"_id"] forKey: @"_id"];
            [new setObject: cloud[@"_userId"] forKey: @"_userId"];
            [new setObject: cloud[@"_commitId"] forKey: @"_commitId"];
            [new setObject: cloud[@"_remoteHash"] forKey: @"_remoteHash"];
            [new setObject: cloud[@"_dicts"] forKey: @"_dicts"];

            NSLog(@"done 4");
						NSLog(@"start 5");
						if (!cloud[@"_remoteHash"]) {
							
              [new setObject: [Random string] forKey: @"_commidId"];
              [new setObject: [Random string] forKey: @"_remoteHash"];

							NSLog(@"Remote hash is nil, force push whole local record");
							[self forcePushWithType: type record: cloud userId: userId completion:^(NSDictionary *item, NSError *error, NSString *commitId) {
								NSLog(@"5: Done by force push");

								[self pushSuccessThenSaveLocalRecord: [new copy] type: type newCommitId: commitId];
								mergeCompletion(item, error);
							}];
						} else {
							
							NSLog(@"conditional push whole local record");
							newClientDicts = [DSWrapper applyInto: newClientDicts From: diff_client_shadow];
							NSDictionary *need_to_apply_to_remote = [DSWrapper diffWins: newClientDicts andLoses: cloud[@"_dicts"]];
							
              [self pushWithObject: new type: type diff: need_to_apply_to_remote userId: userId completion:^(NSDictionary *responseItem, NSError *error, NSString *commitId) {
								
								if (error) {
									NSLog(@"conditional push error: %@", error);
									NSLog(@"fuckkkkkkkkkkkkkkkk erorrrrrrrrr");
									return;
								}
								NSLog(@"push success after diffmerge");
								NSLog(@"5: Done by conditonal update");
								
                [new setObject: newClientDicts forKey: @"_dicts"];
								
								[self pushSuccessThenSaveLocalRecord: new type: type newCommitId: commitId];
								mergeCompletion(responseItem, error);
							}];
						}
					}
				}
			}];
		}
	}];
}

-(void)pushWithObject:(NSDictionary *)record type:(RecordType)type diff:(NSDictionary *)diff userId:(NSString *)userId completion:(void(^)(NSDictionary *responseItem, NSError *error, NSString *commitId))completion {
	
	NSString *commitId = [Random string];
	NSString *remoteHash = record[@"_remoteHash"] != nil ? record[@"_remoteHash"] : [Random string];
	
	AWSDynamoDB *dynamoDB = [AWSDynamoDB defaultDynamoDB];
	AWSDynamoDBUpdateItemInput *updateInput = [AWSDynamoDBUpdateItemInput new];
	
	AWSDynamoDBAttributeValue *identityValue = [AWSDynamoDBAttributeValue new];
  // Identity is the key for offline record
  identityValue.S = userId;
	
	if (type == RecordTypeBookmark) {
		
		updateInput.tableName = [Bookmark dynamoDBTableName];
	} else {
		updateInput.tableName = [RecentVisit dynamoDBTableName];
	}
	
	updateInput.key = @{ @"userId": identityValue, @"id": identityValue };
	
	// commit id
	AWSDynamoDBAttributeValue *oldCommitIdValue = [AWSDynamoDBAttributeValue new];
	oldCommitIdValue.S = record[@"_commitId"];
	
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
    
    if([obj[@"comicName"] isEqualToString: @""]) {
      return;
    }
		
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
		
    if([obj[@"comicName"] isEqualToString: @""]) {
      return;
    }
		[conditionString appendString: [NSString stringWithFormat: @"and attribute_not_exists(dict.#%@) ", obj[@"comicName"]]];
	}];
	
	updateInput.conditionExpression = conditionString;
	
	updateInput.returnValues = AWSDynamoDBReturnValueAllNew;
	
	[[dynamoDB updateItem: updateInput] continueWithBlock:^id(AWSTask *task) {
    
    if (task.error) {
      completion(nil, task.error, commitId);
      return nil;
    } else {
      AWSDynamoDBUpdateItemOutput *result = task.result;
      NSDictionary *resultValue = result.dictionaryValue;
      NSDictionary *pureResult = [BookmarkManager convert: resultValue[@"attributes"]];
      completion(pureResult, task.error, commitId);
    }
    return nil;
	}];
}

@end
