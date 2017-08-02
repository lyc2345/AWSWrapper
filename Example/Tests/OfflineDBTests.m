//
//  OfflineDBTests.m
//  AWSWrapper
//
//  Created by Stan Liu on 02/08/2017.
//  Copyright © 2017 lyc2345. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OfflineDBTestBase.h"
@import Specta;


@interface OfflineDBTests : XCTestCase

@property OfflineDBTestBase *testcase;

@end

@implementation OfflineDBTests

-(void)setUp {
  [super setUp];
  
  self.testcase = [OfflineDBTestBase new];
}

-(void)tearDown {
  [super tearDown];
}

-(void)testOfflineShadowBookmark {
  
  NSString *userIdentityId = @"user1";
  NSDictionary *record = @{
                           @"A": @{@"author": @"A", @"url": @"A"},
                           @"B": @{@"author": @"B", @"url": @"B"},
                           @"C": @{@"author": @"C", @"url": @"C"},
                           @"D": @{@"author": @"D", @"url": @"D"}
                           };
  
  [OfflineDBTestBase setShadow: record isBookmark: YES ofIdentity: userIdentityId];
  
  NSDictionary *shadow = [OfflineDBTestBase shadowIsBookmark: YES ofIdentity: userIdentityId];

  XCTAssertTrue([shadow isEqualToDictionary: record]);
}

-(void)testOfflineHistory {
  
  NSString *userIdentityId = @"user2";
  NSDictionary *record = @{
                           @"A": @{@"author": @"A", @"url": @"A"},
                           @"B": @{@"author": @"B", @"url": @"B"}
                           };
  
  [OfflineDBTestBase setShadow: record isBookmark: NO ofIdentity: userIdentityId];
  
  NSDictionary *shadow = [OfflineDBTestBase shadowIsBookmark: NO ofIdentity: userIdentityId];
  
  XCTAssertTrue([shadow isEqualToDictionary: record]);
}

-(void)testOfflineBookmarkADD {
  
  NSString *userIdentityId = @"user1";
  NSDictionary *record = @{@"comicName": @"A", @"author": @"A", @"url": @"A"};
  
  [_testcase addOffline: record
                   type: RecordTypeBookmark
             ofIdentity: userIdentityId];
  
  [_testcase addOffline: @{@"comicName": @"B", @"author": @"B", @"url": @"B"}
                   type: RecordTypeBookmark
             ofIdentity: userIdentityId];
  
  [_testcase addOffline: @{@"comicName": @"C", @"author": @"C", @"url": @"C"}
                   type: RecordTypeBookmark
             ofIdentity: userIdentityId];
  
  
  
  
  NSDictionary *bookmark = [_testcase getOfflineRecordOfIdentity: userIdentityId
                                                            type: RecordTypeBookmark];
  
  NSDictionary *expectBookmark = @{
                                   @"A": @{@"author": @"A", @"url": @"A"},
                                   @"B": @{@"author": @"B", @"url": @"B"},
                                   @"C": @{@"author": @"C", @"url": @"C"},
                                   };
  
  XCTAssertTrue([bookmark[@"_dicts"] isEqualToDictionary: expectBookmark]);
}

-(void)testOfflineHistoryADD {
  
  NSString *userIdentityId = @"user1";
  NSDictionary *record = @{@"comicName": @"Y", @"author": @"Y", @"url": @"Y"};
  
  [_testcase addOffline: record
                   type: RecordTypeHistory
             ofIdentity: userIdentityId];
  
  NSDictionary *history = [_testcase getOfflineRecordOfIdentity: userIdentityId
                                                            type: RecordTypeHistory];
  
  NSDictionary *expectHistory = @{
                                   @"Y": @{@"author": @"Y", @"url": @"Y"}
                                   };
  
  XCTAssertTrue([history[@"_dicts"] isEqualToDictionary: expectHistory]);
}

-(void)testOfflineBookmarkDelete {
  
  NSString *userIdentityId = @"user1";
  NSDictionary *record = @{@"comicName": @"A", @"author": @"A", @"url": @"A"};
  
  [_testcase addOffline: record
                   type: RecordTypeBookmark
             ofIdentity: userIdentityId];
  
  [_testcase addOffline: @{@"comicName": @"B", @"author": @"B", @"url": @"B"}
                   type: RecordTypeBookmark
             ofIdentity: userIdentityId];
  
  [_testcase addOffline: @{@"comicName": @"C", @"author": @"C", @"url": @"C"}
                   type: RecordTypeBookmark
             ofIdentity: userIdentityId];
  
  NSDictionary *bookmark = [_testcase getOfflineRecordOfIdentity: userIdentityId
                                                            type: RecordTypeBookmark];
  
  NSDictionary *expectBookmark = @{
                                   @"A": @{@"author": @"A", @"url": @"A"},
                                   @"B": @{@"author": @"B", @"url": @"B"},
                                   @"C": @{@"author": @"C", @"url": @"C"},
                                   };
  
  XCTAssertTrue([bookmark[@"_dicts"] isEqualToDictionary: expectBookmark]);
  
  
  [_testcase deleteOffline: @{@"comicName": @"B", @"author": @"B", @"url": @"B"}
                   type: RecordTypeBookmark
             ofIdentity: userIdentityId];
  
  
  bookmark = [_testcase getOfflineRecordOfIdentity: userIdentityId
                                                            type: RecordTypeBookmark];
  
  expectBookmark = @{
                                   @"A": @{@"author": @"A", @"url": @"A"},
                                   @"C": @{@"author": @"C", @"url": @"C"},
                                   };
  
  XCTAssertTrue([bookmark[@"_dicts"] isEqualToDictionary: expectBookmark]);
}



@end
