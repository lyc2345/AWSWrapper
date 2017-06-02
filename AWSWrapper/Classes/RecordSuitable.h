//
//  RecordSuitable.h
//  
//
//  Created by Stan Liu on 19/05/2017.
//
//

#import <AWSDynamoDB/AWSDynamoDB.h>

@protocol RecordSuitable <AWSDynamoDBModeling>

@property (nonatomic, strong) NSString *_userId;
@property (nonatomic, strong) NSString *_id;
@property (nonatomic, strong) NSString *_commitId;
@property (nonatomic, strong) NSDictionary *_dicts;
@property (nonatomic, strong) NSString *_remoteHash;

@end
