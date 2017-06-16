//
//  DSUnitTest.m
//  DSUnitTest
//
//  Created by Stan Liu on 26/04/2017.
//  Copyright © 2017 Stan Liu. All rights reserved.
//

#import <XCTest/XCTest.h>
@import AWSWrapper.DSWrapper;

@interface NSArray (Sort)

-(NSArray *)sort;

@end

@interface DSWrapper (Testing)

+(void)setShadow:(NSDictionary *)s;
+(NSDictionary *)shadow;

@end

@implementation DSWrapper (Testing)

+(void)setShadow:(NSDictionary *)s {
  
  [[NSUserDefaults standardUserDefaults] setObject: s forKey: @"__testing_shadow"];
}

+(NSDictionary *)shadow {
  
  return [[NSUserDefaults standardUserDefaults] dictionaryForKey: @"__testing_shadow"];
}

@end

@interface DSUnitTest : XCTestCase

@property NSDictionary *scenario1;
@property NSDictionary *scenario2;
@property NSDictionary *scenario3;
@property NSDictionary *scenario4;

@end

@implementation DSUnitTest

- (void)setUp {
  [super setUp];
  // Put setup code here. This method is called before the invocation of each test method in the class.
  
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
  
  NSDictionary *need_to_apply_to_client = [DSWrapper diffWins: remote andLoses: client];
  NSDictionary *newClient = [DSWrapper applyInto: client From: need_to_apply_to_client];
  
  XCTAssertTrue([remote isEqualToDictionary: newClient]);
}

-(void)testScenarioSeeClientFirst1 {
  
  NSDictionary *remote = self.scenario1[@"remote"];
  NSDictionary *client = self.scenario1[@"client"];
  
  [DSWrapper setShadow: remote isBookmark: YES];
  NSDictionary *need_to_apply_to_remote = [DSWrapper diffShadowAndClient: client isBookmark: YES];
  
  NSDictionary *newRemote = [DSWrapper applyInto: remote From: need_to_apply_to_remote];
  
  [DSWrapper setShadow: newRemote];
  
  XCTAssertTrue([client isEqualToDictionary: newRemote] &&
                [newRemote isEqualToDictionary: [DSWrapper shadow]]);
}

-(void)testScenarioSeeRemoteFirstMergeClient1 {
  
  NSDictionary *remote = self.scenario1[@"remote"];
  NSDictionary *client = self.scenario1[@"client"];
  
  [DSWrapper setShadow: remote isBookmark: YES];
  
  NSDictionary *need_to_apply_to_client = [DSWrapper diffWins: remote andLoses: client];
  
  NSDictionary *newClient = [DSWrapper applyInto: client From: need_to_apply_to_client];
  
  NSDictionary *need_to_apply_to_remote = [DSWrapper diffShadowAndClient: newClient isBookmark: YES];
  
  NSDictionary *newRemote = [DSWrapper applyInto: remote From: need_to_apply_to_remote];
  
  [DSWrapper setShadow: newRemote];
  
  XCTAssertTrue([newRemote isEqualToDictionary: newClient] &&
                [newRemote isEqualToDictionary: [DSWrapper shadow]]);
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
  [DSWrapper setShadow: remote isBookmark: YES];
  
  // -A, +B, +D, +E
  NSDictionary *need_to_apply_to_remote = [DSWrapper diffShadowAndClient: client isBookmark: YES];
  
  // +A, -B, -D, -E
  NSDictionary *need_to_apply_to_client = [DSWrapper diffWins: remote andLoses: client];
  
  // A, C
  NSDictionary *newClient = [DSWrapper applyInto: client From: need_to_apply_to_client];
  
  // B, C, D, E
  newClient = [DSWrapper applyInto: newClient From: need_to_apply_to_remote];
  
  // B, D, E
  NSDictionary *newRemote = [DSWrapper applyInto: remote From: need_to_apply_to_remote];
  
  [DSWrapper setShadow: newRemote];
  
  NSDictionary *expect = @{
                           @"B": @{@"author": @"B", @"url": @"B"},
                           @"C": @{@"author": @"C", @"url": @"C"},
                           @"D": @{@"author": @"D", @"url": @"D"},
                           @"E": @{@"author": @"E", @"url": @"E"}
                           };
  
  XCTAssertTrue([newRemote isEqualToDictionary: newClient] &&
                [newRemote isEqualToDictionary: [DSWrapper shadow]] &&
                [newRemote isEqualToDictionary: expect]);
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
  [DSWrapper setShadow: remote isBookmark: YES];
  
  // -A, +D
  NSDictionary *need_to_apply_to_remote = [DSWrapper diffShadowAndClient: client isBookmark: YES];
  
  // +C, +D
  NSDictionary *need_to_apply_to_client = [DSWrapper diffWins: remote andLoses: client];
  
  // A, B, C, D
  NSDictionary *newClient = [DSWrapper applyInto: client From: need_to_apply_to_client];
  
  newClient = [DSWrapper applyInto: newClient From: need_to_apply_to_remote];
  
  // B, C, D
  NSDictionary *newRemote = [DSWrapper applyInto: remote From: need_to_apply_to_remote];
  
  [DSWrapper setShadow: newRemote];
  
  NSDictionary *expect = @{
                           @"B": @{@"author": @"B", @"url": @"B"},
                           @"C": @{@"author": @"C", @"url": @"C"},
                           @"D": @{@"author": @"D", @"url": @"D"}
                           };
  
  XCTAssertTrue([newRemote isEqualToDictionary: newClient] &&
                [newRemote isEqualToDictionary: [DSWrapper shadow]] &&
                [newRemote isEqualToDictionary: expect]);
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
  [DSWrapper setShadow: shadow isBookmark: YES];
  
  // +C, +D
  NSDictionary *need_to_apply_to_remote = [DSWrapper diffShadowAndClient: client isBookmark: YES];
  
  // +A, -C, -D
  NSDictionary *need_to_apply_to_client = [DSWrapper diffWins: remote andLoses: client];
  
  // A, B
  NSDictionary *newClient = [DSWrapper applyInto: client From: need_to_apply_to_client];
  
  // A, B, C, D
  newClient = [DSWrapper applyInto: newClient From: need_to_apply_to_remote];
  
  // A, B, C, D
  NSDictionary *newRemote = [DSWrapper applyInto: remote From: need_to_apply_to_remote];
  
  [DSWrapper setShadow: newRemote];
  
  NSDictionary *expect = @{
                           @"A": @{@"author": @"A", @"url": @"A"},
                           @"B": @{@"author": @"B", @"url": @"B"},
                           @"C": @{@"author": @"C", @"url": @"C"},
                           @"D": @{@"author": @"D", @"url": @"D"}
                           };
  
  XCTAssertTrue([newRemote isEqualToDictionary: newClient] &&
                [newRemote isEqualToDictionary: [DSWrapper shadow]] &&
                [newRemote isEqualToDictionary: expect]);
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
  [DSWrapper setShadow: shadow isBookmark: YES];
  
  // -B
  NSDictionary *need_to_apply_to_remote = [DSWrapper diffShadowAndClient: client isBookmark: YES];
  
  // -A, +B
  NSDictionary *need_to_apply_to_client = [DSWrapper diffWins: remote andLoses: client];
  
  // B, C, D
  NSDictionary *newClient = [DSWrapper applyInto: client From: need_to_apply_to_client];
  
  // C, D
  newClient = [DSWrapper applyInto: newClient From: need_to_apply_to_remote];
  
  // [B, C, D] + [-B] = C, D
  NSDictionary *newRemote = [DSWrapper applyInto: remote From: need_to_apply_to_remote];
  
  [DSWrapper setShadow: newRemote];
  
  NSDictionary *expect = @{
                           @"C": @{@"author": @"C", @"url": @"C"},
                           @"D": @{@"author": @"D", @"url": @"D"}
                           };
  
  XCTAssertTrue([newRemote isEqualToDictionary: newClient] &&
                [newRemote isEqualToDictionary: [DSWrapper shadow]] &&
                [newRemote isEqualToDictionary: expect]);
}

-(void)testScenarioRemoteWasReseted {
  
  NSDictionary *remote = @{};
  NSDictionary *client = self.scenario1[@"client"];
  [DSWrapper setShadow: remote isBookmark: YES];
  
  NSDictionary *diff_client_shadow = [DSWrapper diffShadowAndClient: client isBookmark: YES];
  
  NSDictionary *need_to_apply_to_client = [DSWrapper diffWins: remote andLoses: client];
  NSDictionary *newClient = [DSWrapper applyInto: client From: need_to_apply_to_client];
  newClient = [DSWrapper applyInto: newClient From: diff_client_shadow];
  
  NSDictionary *need_to_apply_to_remote = [DSWrapper diffWins: newClient andLoses: remote];
  NSDictionary *newRemote = [DSWrapper applyInto: remote From: need_to_apply_to_remote];
  
  [DSWrapper setShadow: newRemote];
  
  XCTAssertTrue([newRemote isEqualToDictionary: newClient] &&
                [newRemote isEqualToDictionary: [DSWrapper shadow]] && newRemote != nil);
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
                           }
  [DSWrapper setShadow: shadow isBookmark: YES];
  
  // -C
  NSDictionary *diff_client_shadow = [DSWrapper diffShadowAndClient: client isBookmark: YES];
  
  // 
  NSDictionary *need_to_apply_to_client = [DSWrapper diffWins: remote andLoses: client];
  NSDictionary *newClient = [DSWrapper applyInto: client From: need_to_apply_to_client];
  newClient = [DSWrapper applyInto: newClient From: diff_client_shadow];
  
  NSDictionary *need_to_apply_to_remote = [DSWrapper diffWins: newClient andLoses: remote];
  NSDictionary *newRemote = [DSWrapper applyInto: remote From: need_to_apply_to_remote];
  
  [DSWrapper setShadow: newRemote];
  
  XCTAssertTrue([newRemote isEqualToDictionary: newClient] &&
                [newRemote isEqualToDictionary: [DSWrapper shadow]] && newRemote != nil);
}

@end
