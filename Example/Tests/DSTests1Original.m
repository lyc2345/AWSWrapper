//
//  DSTest1.m
//  AWSWrapper
//
//  Created by Stan Liu on 14/07/2017.
//  Copyright © 2017 lyc2345. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "DynamoTestBase.h"
#import "DispatchQueue.h"
@import AWSWrapper;

@interface DSTests1Original : XCTestCase

@property (nonatomic) DynamoTestBase *testcase;
@property (nonatomic) DispatchQueue *dispatchQueue;

@end

@implementation DSTests1Original

- (void)setUp {
  [super setUp];
  
  _testcase = [DynamoTestBase new];
  _dispatchQueue = [DispatchQueue new];
}

- (void)tearDown {
  
  [_dispatchQueue waitForGroup];
  _dispatchQueue = nil;
  [super tearDown];
}

- (void)testAll {
  
  __block NSDictionary *dataInitialShadow;
  
  // First Initial Remote data.
  [_dispatchQueue performGroupedDelay: 2 block:^{
    [_testcase initial: @{
                          @"A": @{@"author": @"A", @"url": @"A"},
                          @"B": @{@"author": @"B", @"url": @"B"}
                          }
            exeHandler:^(NSString *commitId, NSString *remoteHash, NSDictionary *shadow, NSError *error) {
              
              XCTAssertNil(error);
              XCTAssertNotNil(commitId);
              XCTAssertNotNil(remoteHash);
              
            } completion:^(NSDictionary *newShadow, NSString *commitId, NSError *error) {
              
              if (error) { XCTFail(@"expectation failed with error: %@", error); }
              dataInitialShadow = newShadow;
            }];
  }];
  
  // Second to verify thie Initial Data compares with shadow.
  [_dispatchQueue performGroupedDelay: 2 block:^{
    [_testcase pullToCheck: dataInitialShadow
                exeHandler:^(BOOL isSame) {
                  
                  // If here failed, says initial push to remote is failed.
                  XCTAssertTrue(isSame);
                } completion:^(NSError *error) {
                  
                  if (error) { XCTFail(@"expectation failed with error: %@", error); }
                }];
  }];
  
  // Start Scenario 1, part 1.
  [_dispatchQueue performGroupedDelay: 2 block:^{
    NSDictionary *expectShadow = @{
                                   @"A": @{@"author": @"A", @"url": @"A"},
                                   @"B": @{@"author": @"B", @"url": @"B"}
                                   };
    NSDictionary *client = @{
                             @"A": @{@"author": @"A", @"url": @"A"},
                             @"B": @{@"author": @"B", @"url": @"B"},
                             @"C": @{@"author": @"C", @"url": @"C"},
                             @"D": @{@"author": @"D", @"url": @"D"},
                             @"E": @{@"author": @"E", @"url": @"E"}
                             };
    [_testcase examineSpec: @"S1P1"
                  commitId: nil
                remoteHash: nil
                clientDict: client
              expectShadow: nil
            examineHandler:^(NSDictionary *shadow) {
              
              XCTAssertTrue([expectShadow isEqualToDictionary: shadow]);
              
            } shouldReplace:^BOOL(id oldValue, id newValue) {
              
              return YES;
              
            } exeHandler:^(NSDictionary *diff, NSError *error) {
              
              if (error) { XCTFail(@"expectation failed with error: %@", error); }
              
            } completion:^(NSDictionary *newShadow, NSString *commitId, NSError *error) {
              
              NSDictionary *expectRemote = @{
                                             @"A": @{@"author": @"A", @"url": @"A"},
                                             @"B": @{@"author": @"B", @"url": @"B"},
                                             @"C": @{@"author": @"C", @"url": @"C"},
                                             @"D": @{@"author": @"D", @"url": @"D"},
                                             @"E": @{@"author": @"E", @"url": @"E"}
                                             };
              XCTAssertTrue([newShadow isEqualToDictionary: expectRemote]);
              
              if (error) { XCTFail(@"expectation failed with error: %@", error); }
            }];
  }];
  
  // Start Scenario 1, part 2.
  [_dispatchQueue performGroupedDelay: 2 block:^{
    NSDictionary *expectShadow = @{
                                   @"A": @{@"author": @"A", @"url": @"A"},
                                   @"B": @{@"author": @"B", @"url": @"B"},
                                   @"C": @{@"author": @"C", @"url": @"C"},
                                   @"D": @{@"author": @"D", @"url": @"D"},
                                   @"E": @{@"author": @"E", @"url": @"E"}
                                   };
    NSDictionary *client = @{
                             @"B": @{@"author": @"B", @"url": @"B"},
                             @"C": @{@"author": @"C", @"url": @"C"},
                             @"E": @{@"author": @"E", @"url": @"E"},
                             @"F": @{@"author": @"F", @"url": @"F"}
                             };
    [_testcase examineSpec: @"S1P2"
                  commitId: nil
                remoteHash: nil
                clientDict: client
              expectShadow: nil
            examineHandler:^(NSDictionary *shadow) {
              
              XCTAssertTrue([expectShadow isEqualToDictionary: shadow]);
              
            } shouldReplace:^BOOL(id oldValue, id newValue) {
              
              return YES;
              
            } exeHandler:^(NSDictionary *diff, NSError *error) {
              
              if (error) { XCTFail(@"expectation failed with error: %@", error); }
              
            } completion:^(NSDictionary *newShadow, NSString *commitId, NSError *error) {
              
              NSDictionary *expectRemote = @{
                                             @"B": @{@"author": @"B", @"url": @"B"},
                                             @"C": @{@"author": @"C", @"url": @"C"},
                                             @"E": @{@"author": @"E", @"url": @"E"},
                                             @"F": @{@"author": @"F", @"url": @"F"}
                                             };
              XCTAssertTrue([newShadow isEqualToDictionary: expectRemote]);
              
              if (error) { XCTFail(@"expectation failed with error: %@", error); }
            }];
  }];
  
  // Start Scenario 2, part 1.
  [_dispatchQueue performGroupedDelay: 2 block:^{
    NSDictionary *expectShadow = @{
                                   @"A": @{@"author": @"A", @"url": @"A"},
                                   @"B": @{@"author": @"B", @"url": @"B"},
                                   @"C": @{@"author": @"C", @"url": @"C"},
                                   @"D": @{@"author": @"D", @"url": @"D"},
                                   @"E": @{@"author": @"E", @"url": @"E"}
                                   };
    NSDictionary *client = @{
                             @"B": @{@"author": @"B", @"url": @"B"},
                             @"C": @{@"author": @"C", @"url": @"C"},
                             @"D": @{@"author": @"D", @"url": @"D"},
                             @"E": @{@"author": @"E", @"url": @"E"},
                             @"G": @{@"author": @"G", @"url": @"G"}
                             };
    NSDictionary *actualRemote = @{
                                   @"B": @{@"author": @"B", @"url": @"B"},
                                   @"C": @{@"author": @"C", @"url": @"C"},
                                   @"E": @{@"author": @"E", @"url": @"E"},
                                   @"F": @{@"author": @"F", @"url": @"F"}
                                   };
    NSDictionary *diff_cilent_shadow = [DSWrapper diffWins: client loses: expectShadow];
    NSDictionary *need_to_apply_to_client = [DSWrapper diffWins: actualRemote loses: client];
    NSDictionary *newClient = [DSWrapper mergeInto: client applyDiff: need_to_apply_to_client];
    newClient = [DSWrapper mergeInto: newClient
                           applyDiff: diff_cilent_shadow
                          primaryKey: @"comicName"
                       shouldReplace:^BOOL(id oldValue, id newValue) {
                         return YES;
                       }];
    NSDictionary *need_to_apply_to_remote = [DSWrapper diffWins: newClient loses: actualRemote];
    
    [_testcase examineSpec: @"S2P1"
                  commitId: @"123123gfdg213123gdgd2112312312312"
                remoteHash: nil
                clientDict: client
              expectShadow: expectShadow
            examineHandler:^(NSDictionary *shadow) {
              
              XCTAssertFalse([expectShadow isEqualToDictionary: shadow]);
              
            } shouldReplace:^BOOL(id oldValue, id newValue) {
              
              return YES;
              
            } exeHandler:^(NSDictionary *diff, NSError *error) {
              
              if (error) { XCTFail(@"expectation failed with error: %@", error); }
              XCTAssertTrue([diff isEqualToDictionary: need_to_apply_to_remote]);
              
            } completion:^(NSDictionary *newShadow, NSString *commitId, NSError *error) {
              
              NSDictionary *expectRemote = @{
                                             @"B": @{@"author": @"B", @"url": @"B"},
                                             @"C": @{@"author": @"C", @"url": @"C"},
                                             @"E": @{@"author": @"E", @"url": @"E"},
                                             @"F": @{@"author": @"F", @"url": @"F"},
                                             @"G": @{@"author": @"G", @"url": @"G"}
                                             };
              XCTAssertTrue([newShadow isEqualToDictionary: expectRemote]);
              
              if (error) { XCTFail(@"expectation failed with error: %@", error); }
            }];
  }];
  
  // Start Scenario 1, part 3.
  [_dispatchQueue performGroupedDelay: 2 block:^{
    NSDictionary *expectShadow = @{
                                   @"B": @{@"author": @"B", @"url": @"B"},
                                   @"C": @{@"author": @"C", @"url": @"C"},
                                   @"E": @{@"author": @"E", @"url": @"E"},
                                   @"F": @{@"author": @"F", @"url": @"F"}
                                   };
    NSDictionary *client = @{
                             @"A": @{@"author": @"A", @"url": @"A"},
                             @"B": @{@"author": @"B", @"url": @"B1"},
                             @"E": @{@"author": @"E", @"url": @"E"},
                             @"F": @{@"author": @"F", @"url": @"F1"}
                             };
    NSDictionary *actualRemote = @{
                                   @"B": @{@"author": @"B", @"url": @"B"},
                                   @"C": @{@"author": @"C", @"url": @"C"},
                                   @"E": @{@"author": @"E", @"url": @"E"},
                                   @"F": @{@"author": @"F", @"url": @"F"},
                                   @"G": @{@"author": @"G", @"url": @"G"}
                                   };
    NSDictionary *diff_cilent_shadow = [DSWrapper diffWins: client loses: expectShadow];
    NSDictionary *need_to_apply_to_client = [DSWrapper diffWins: actualRemote loses: client];
    NSDictionary *newClient = [DSWrapper mergeInto: client applyDiff: need_to_apply_to_client];
    newClient = [DSWrapper mergeInto: newClient
                           applyDiff: diff_cilent_shadow
                          primaryKey: @"comicName"
                       shouldReplace:^BOOL(id oldValue, id newValue) {
                         return YES;
                       }];
    NSDictionary *need_to_apply_to_remote = [DSWrapper diffWins: newClient loses: actualRemote];
    
    [_testcase examineSpec: @"S1P3"
                  commitId: @"1231435323213123gdfgdf2112312312312"
                remoteHash: nil
                clientDict: client
              expectShadow: expectShadow
            examineHandler:^(NSDictionary *shadow) {
              
              XCTAssertFalse([expectShadow isEqualToDictionary: shadow]);
              
            } shouldReplace:^BOOL(id oldValue, id newValue) {
              
              return YES;
              
            } exeHandler:^(NSDictionary *diff, NSError *error) {
              
              if (error) { XCTFail(@"expectation failed with error: %@", error); }
              XCTAssertTrue([diff isEqualToDictionary: need_to_apply_to_remote]);
              
            } completion:^(NSDictionary *newShadow, NSString *commitId, NSError *error) {
              
              NSDictionary *expectRemote = @{
                                             @"A": @{@"author": @"A", @"url": @"A"},
                                             @"B": @{@"author": @"B", @"url": @"B1"},
                                             @"E": @{@"author": @"E", @"url": @"E"},
                                             @"F": @{@"author": @"F", @"url": @"F1"},
                                             @"G": @{@"author": @"G", @"url": @"G"}
                                             };
              XCTAssertTrue([newShadow isEqualToDictionary: expectRemote]);
              
              if (error) { XCTFail(@"expectation failed with error: %@", error); }
            }];
  }];
  
  // Final check if remote data is the same with expectData.
  [_dispatchQueue performGroupedDelay: 2 block:^{
    [_testcase pullToCheck: @{
                              @"A": @{@"author": @"A", @"url": @"A"},
                              @"B": @{@"author": @"B", @"url": @"B1"},
                              @"E": @{@"author": @"E", @"url": @"E"},
                              @"F": @{@"author": @"F", @"url": @"F1"},
                              @"G": @{@"author": @"G", @"url": @"G"}
                              }
                exeHandler:^(BOOL isSame) {
                  
                  XCTAssertTrue(isSame);
                } completion:^(NSError *error) {
                  
                  if (error) { XCTFail(@"expectation failed with error: %@", error); }
                }];
  }];
}

@end
