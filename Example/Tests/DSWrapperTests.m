//
//  DSUnitTest.m
//  DSUnitTest
//
//  Created by Stan Liu on 26/04/2017.
//  Copyright © 2017 Stan Liu. All rights reserved.
//

#import <XCTest/XCTest.h>
@import AWSWrapper.DSWrapper;
@import AWSWrapper.OfflineDB;

@interface NSArray (Sort)

-(NSArray *)sort;

@end

@interface OfflineDB (Testing)

+(void)setShadow:(NSDictionary *)s;
+(NSDictionary *)shadow;

@end

@implementation OfflineDB (Testing)

+(void)setShadow:(NSDictionary *)s {
  
  [[NSUserDefaults standardUserDefaults] setObject: s forKey: @"__testing_shadow"];
}

+(NSDictionary *)shadow {
  
  return [[NSUserDefaults standardUserDefaults] dictionaryForKey: @"__testing_shadow"];
}

@end

@interface DSUnitTest : XCTestCase

@property NSString *user;

@property NSDictionary *scenario1;
@property NSDictionary *scenario2;
@property NSDictionary *scenario3;
@property NSDictionary *scenario4;

@end

@implementation DSUnitTest

- (void)setUp {
  [super setUp];
  // Put setup code here. This method is called before the invocation of each test method in the class.
  
  _user = @"user1-fsd8f9sd0-f28f-ff23d";
  
  NSDictionary *client = @{
                           @"B": @{@"author": @"B", @"url": @"B"},
                           @"C": @{@"author": @"C", @"url": @"C"},
                           @"D": @{@"author": @"D", @"url": @"D"},
                           @"E": @{@"author": @"E", @"url": @"E"}
                           };
  
  NSDictionary *remote = @{
                           @"A": @{@"author": @"A", @"url": @"A"},
                           @"B": @{@"author": @"B", @"url": @"B"},
                           @"C": @{@"author": @"C", @"url": @"C"}
                           };
  
  
  self.scenario1 = @{@"remote": remote, @"client": client};
  self.scenario2 = @{@"remote": client, @"client": remote};
  
  
}

- (void)tearDown {
  // Put teardown code here. This method is called after the invocation of each test method in the class.
  [super tearDown];
}

- (void)testExample {
  // This is an example of a functional test case.
  // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
  // This is an example of a performance test case.
  [self measureBlock:^{
    // Put the code you want to measure the time of here.
  }];
}


-(void)testScenarioSeeRemoteFirst1 {
  
  NSDictionary *remote = self.scenario1[@"remote"];
  NSDictionary *client = self.scenario1[@"client"];
  
  NSDictionary *need_to_apply_to_client = [DSWrapper diffWins: remote loses: client];
  NSDictionary *newClient = [DSWrapper mergeInto: client applyDiff: need_to_apply_to_client];
  
  XCTAssertTrue([remote isEqualToDictionary: newClient]);
}

-(void)testScenarioSeeClientFirst1 {
  
  NSDictionary *remote = self.scenario1[@"remote"];
  NSDictionary *client = self.scenario1[@"client"];
  
  [OfflineDB setShadow: remote];
  
  NSDictionary *need_to_apply_to_remote = [DSWrapper diffWins: client loses: [OfflineDB shadow]];
  
  NSDictionary *newRemote = [DSWrapper mergeInto: remote applyDiff: need_to_apply_to_remote];
  
  [OfflineDB setShadow: newRemote];
  
  XCTAssertTrue([client isEqualToDictionary: newRemote] &&
                [newRemote isEqualToDictionary: [OfflineDB shadow]]);
}

-(void)testScenarioSeeRemoteFirstMergeClient1 {
  
  NSDictionary *remote = self.scenario1[@"remote"];
  NSDictionary *client = self.scenario1[@"client"];
  
  [OfflineDB setShadow: remote];
  
  NSDictionary *need_to_apply_to_remote = [DSWrapper diffWins: client loses: [OfflineDB shadow]];
  
  NSDictionary *newRemote = [DSWrapper mergeInto: remote applyDiff: need_to_apply_to_remote];
  
  [OfflineDB setShadow: newRemote];
  
  XCTAssertTrue([newRemote isEqualToDictionary: client] &&
                [newRemote isEqualToDictionary: [OfflineDB shadow]]);
}

-(void)testScenarioSeeRemoteFirstMergeClient2 {
  // A, C
  NSDictionary *remote = @{
                           @"A": @{@"author": @"A", @"url": @"A"},
                           @"C": @{@"author": @"C", @"url": @"C"}
                           };;
  // B, C, D, E
  NSDictionary *client = self.scenario1[@"client"];
  
  // A, C
  [OfflineDB setShadow: remote];
  
  // -A, +B, +D, +E
  NSDictionary *need_to_apply_to_remote = [DSWrapper diffWins: client loses: [OfflineDB shadow]];
  
  // +A, -B, -D, -E
  NSDictionary *need_to_apply_to_client = [DSWrapper diffWins: remote loses: client];
  
  // A, C
  NSDictionary *newClient = [DSWrapper mergeInto: client applyDiff: need_to_apply_to_client];
  
  // B, C, D, E
  newClient = [DSWrapper mergeInto: newClient applyDiff: need_to_apply_to_remote];
  
  // B, D, E
  NSDictionary *newRemote = [DSWrapper mergeInto: remote applyDiff: need_to_apply_to_remote];
  
  [OfflineDB setShadow: newRemote];
  
  NSDictionary *expect = @{
                           @"B": @{@"author": @"B", @"url": @"B"},
                           @"C": @{@"author": @"C", @"url": @"C"},
                           @"D": @{@"author": @"D", @"url": @"D"},
                           @"E": @{@"author": @"E", @"url": @"E"}
                           };
  
  XCTAssertTrue([newRemote isEqualToDictionary: newClient]);
  XCTAssertTrue([newRemote isEqualToDictionary: [OfflineDB shadow]]);
  XCTAssertTrue([newRemote isEqualToDictionary: expect]);
}

-(void)testScenarioSeeRemoteFirstMergeClient3 {
  // A, B
  NSDictionary *remote = @{
                           @"A": @{@"author": @"A", @"url": @"A"},
                           @"B": @{@"author": @"B", @"url": @"B"}
                           };
  // B, C, D
  NSDictionary *client = @{
                           @"B": @{@"author": @"B", @"url": @"B"},
                           @"C": @{@"author": @"C", @"url": @"C"},
                           @"D": @{@"author": @"D", @"url": @"D"}
                           };
  
  // A, B
  [OfflineDB setShadow: remote];
  
  // -A, +D
  NSDictionary *need_to_apply_to_remote = [DSWrapper diffWins: client loses: [OfflineDB shadow]];
  
  // +C, +D
  NSDictionary *need_to_apply_to_client = [DSWrapper diffWins: remote loses: client];
  
  // A, B, C, D
  NSDictionary *newClient = [DSWrapper mergeInto: client applyDiff: need_to_apply_to_client];
  
  newClient = [DSWrapper mergeInto: newClient applyDiff: need_to_apply_to_remote];
  
  // B, C, D
  NSDictionary *newRemote = [DSWrapper mergeInto: remote applyDiff: need_to_apply_to_remote];
  
  [OfflineDB setShadow: newRemote];
  
  NSDictionary *expect = @{
                           @"B": @{@"author": @"B", @"url": @"B"},
                           @"C": @{@"author": @"C", @"url": @"C"},
                           @"D": @{@"author": @"D", @"url": @"D"}
                           };
  
  XCTAssertTrue([newRemote isEqualToDictionary: newClient]);
  XCTAssertTrue([newRemote isEqualToDictionary: [OfflineDB shadow]]);
  XCTAssertTrue([newRemote isEqualToDictionary: expect]);
}

-(void)testScenarioSeeRemoteFirstMergeClient4 {
  
  // A, B
  NSDictionary *remote = @{
                           @"A": @{@"author": @"A", @"url": @"A"},
                           @"B": @{@"author": @"B", @"url": @"B"}
                           };
  // B, C, D
  NSDictionary *client = @{
                           @"B": @{@"author": @"B", @"url": @"B"},
                           @"C": @{@"author": @"C", @"url": @"C"},
                           @"D": @{@"author": @"D", @"url": @"D"}
                           };
  NSDictionary *shadow = @{@"B": @{@"author": @"B", @"url": @"B"}};
  
  // B
  [OfflineDB setShadow: shadow];
  
  // +C, +D
  NSDictionary *need_to_apply_to_remote = [DSWrapper diffWins: client loses: [OfflineDB shadow]];
  
  // +A, -C, -D
  NSDictionary *need_to_apply_to_client = [DSWrapper diffWins: remote loses: client];
  
  // A, B
  NSDictionary *newClient = [DSWrapper mergeInto: client applyDiff: need_to_apply_to_client];
  
  // A, B, C, D
  newClient = [DSWrapper mergeInto: newClient applyDiff: need_to_apply_to_remote];
  
  // A, B, C, D
  NSDictionary *newRemote = [DSWrapper mergeInto: remote applyDiff: need_to_apply_to_remote];
  
  [OfflineDB setShadow: newRemote];
  
  NSDictionary *expect = @{
                           @"A": @{@"author": @"A", @"url": @"A"},
                           @"B": @{@"author": @"B", @"url": @"B"},
                           @"C": @{@"author": @"C", @"url": @"C"},
                           @"D": @{@"author": @"D", @"url": @"D"}
                           };
  
  XCTAssertTrue([newRemote isEqualToDictionary: newClient]);
  XCTAssertTrue([newRemote isEqualToDictionary: [OfflineDB shadow]]);
  XCTAssertTrue([newRemote isEqualToDictionary: expect]);
}

-(void)testScenarioSeeRemoteFirstMergeClient5 {
  
  // B, C, D
  NSDictionary *remote = @{
                           @"B": @{@"author": @"B", @"url": @"B"},
                           @"C": @{@"author": @"C", @"url": @"C"},
                           @"D": @{@"author": @"D", @"url": @"D"}
                           };
  // A, C, D
  NSDictionary *client = @{
                           @"A": @{@"author": @"A", @"url": @"A"},
                           @"C": @{@"author": @"C", @"url": @"C"},
                           @"D": @{@"author": @"D", @"url": @"D"}
                           };
  
  NSDictionary *shadow = @{
                           @"A": @{@"author": @"A", @"url": @"A"},
                           @"B": @{@"author": @"B", @"url": @"B"},
                           @"C": @{@"author": @"C", @"url": @"C"},
                           @"D": @{@"author": @"D", @"url": @"D"}
                           };
  
  // A, B, C, D
  [OfflineDB setShadow: shadow];
  
  // -B
  NSDictionary *need_to_apply_to_remote = [DSWrapper diffWins: client loses: [OfflineDB shadow]];
  
  // -A, +B
  NSDictionary *need_to_apply_to_client = [DSWrapper diffWins: remote loses: client];
  
  // B, C, D
  NSDictionary *newClient = [DSWrapper mergeInto: client applyDiff: need_to_apply_to_client];
  
  // C, D
  newClient = [DSWrapper mergeInto: newClient applyDiff: need_to_apply_to_remote];
  
  // [B, C, D] + [-B] = C, D
  NSDictionary *newRemote = [DSWrapper mergeInto: remote applyDiff: need_to_apply_to_remote];
  
  [OfflineDB setShadow: newRemote];
  
  NSDictionary *expect = @{
                           @"C": @{@"author": @"C", @"url": @"C"},
                           @"D": @{@"author": @"D", @"url": @"D"}
                           };
  
  XCTAssertTrue([newRemote isEqualToDictionary: newClient]);
  XCTAssertTrue([newRemote isEqualToDictionary: [OfflineDB shadow]]);
  XCTAssertTrue([newRemote isEqualToDictionary: expect]);
}

-(void)testScenarioRemoteWasReseted {
  
  NSDictionary *remote = @{};
  NSDictionary *client = self.scenario1[@"client"];
  [OfflineDB setShadow: remote];
  
  NSDictionary *diff_client_shadow = [DSWrapper diffWins: client loses: [OfflineDB shadow]];
  
  NSDictionary *need_to_apply_to_client = [DSWrapper diffWins: remote loses: client];
  NSDictionary *newClient = [DSWrapper mergeInto: client applyDiff: need_to_apply_to_client];
  newClient = [DSWrapper mergeInto: newClient applyDiff: diff_client_shadow];
  
  NSDictionary *need_to_apply_to_remote = [DSWrapper diffWins: newClient loses: remote];
  NSDictionary *newRemote = [DSWrapper mergeInto: remote applyDiff: need_to_apply_to_remote];
  
  [OfflineDB setShadow: newRemote];
  
  XCTAssertTrue([newRemote isEqualToDictionary: newClient] &&
                [newRemote isEqualToDictionary: [OfflineDB shadow]] && newRemote != nil);
}

-(void)testScenarioRemoteWasReseted2 {
  
  NSDictionary *remote = @{};
  NSDictionary *client = @{
                           @"A": @{@"author": @"A", @"url": @"A"},
                           @"B": @{@"author": @"B", @"url": @"B"},
                           };
  NSDictionary *shadow = @{
                           @"A": @{@"author": @"A", @"url": @"A"},
                           @"B": @{@"author": @"B", @"url": @"B"},
                           @"C": @{@"author": @"C", @"url": @"C"}
                           };
  [OfflineDB setShadow: shadow];
  
  // -C
  NSDictionary *diff_client_shadow = [DSWrapper diffWins: client loses: [OfflineDB shadow]];
  
  // 
  NSDictionary *need_to_apply_to_client = [DSWrapper diffWins: remote loses: client];
  NSDictionary *newClient = [DSWrapper mergeInto: client applyDiff: need_to_apply_to_client];
  newClient = [DSWrapper mergeInto: newClient applyDiff: diff_client_shadow];
  
  NSDictionary *need_to_apply_to_remote = [DSWrapper diffWins: newClient loses: remote];
  NSDictionary *newRemote = [DSWrapper mergeInto: remote applyDiff: need_to_apply_to_remote];
  
  [OfflineDB setShadow: newRemote];
  
  XCTAssertTrue([newRemote isEqualToDictionary: newClient] &&
                [newRemote isEqualToDictionary: [OfflineDB shadow]] && newRemote != nil);
}

@end


