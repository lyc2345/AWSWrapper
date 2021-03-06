//
//  Bookmark.h
//  MySampleApp
//
//
// Copyright 2017 Amazon.com, Inc. or its affiliates (Amazon). All Rights Reserved.
//
// Code generated by AWS Mobile Hub. Amazon gives unlimited permission to 
// copy, distribute and modify it.
//
// Source code generated from template: aws-my-sample-app-ios-objc v0.16
//

@import UIKit;
#import <AWSDynamoDB/AWSDynamoDB.h>
#import "RecordSuitable.h"

NS_ASSUME_NONNULL_BEGIN


@interface Bookmark : AWSDynamoDBObjectModel <AWSDynamoDBModeling, RecordSuitable>

+ (NSDictionary *)JSONKeyPathsByPropertyKey;

@property (nonatomic, strong) NSString *_userId;
@property (nonatomic, strong) NSString *_id;
// This is like git commit id, everytime you push, this will change when push success
@property (nonatomic, strong) NSString *_commitId;
// This is for record server status, if remoteHash is different or empty, means server table datas must be set or clean.
@property (nonatomic, strong) NSString *_remoteHash;
@property (nonatomic, strong) NSDictionary *_dicts;

@end

NS_ASSUME_NONNULL_END
