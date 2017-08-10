//
//  DSTest1.m
//  AWSWrapper
//
//  Created by Stan Liu on 14/07/2017.
//  Copyright © 2017 lyc2345. All rights reserved.
//

#import "DynamoTestBase.h"
#import "DispatchQueue.h"
#import "Specta/Specta.h"
#import "Expecta/Expecta.h"
@import AWSWrapper;

static DynamoTestBase *testcase;
static DispatchQueue *dispatchQueue;

SpecBegin(DSOPSTests2)

describe(@"DSOPSTests2", ^{
  
  beforeAll(^{
    
    waitUntil(^(DoneCallback done) {
      testcase = [DynamoTestBase new];
      dispatchQueue = [DispatchQueue new];
      done();
    });
  });
  
  it(@"Test start", ^{
    
    __block NSDictionary *dataInitialShadow;
    
    waitUntil(^(DoneCallback done) {
      
      // First Initial Remote data.
      [dispatchQueue performGroupedDelay: 2 block:^{
        [testcase initial: @{
                             @"A": @{@"author": @"A", @"url": @"A"},
                             @"B": @{@"author": @"B", @"url": @"B"}
                             }
               exeHandler:^(NSString *commitId, NSString *remoteHash, NSDictionary *shadow, NSError *error) {
                 
                 expect(error).to.beNil;
                 expect(commitId).notTo.beNil;
                 expect(remoteHash).notTo.beNil;
                 
               } completion:^(NSDictionary *newShadow, NSString *commitId, NSError *error) {
                 
                 expect(error).to.beNil;
                 newShadow = dataInitialShadow;
               }];
      }];
      
      // Second to verify thie Initial Data compares with shadow.
      [dispatchQueue performGroupedDelay: 2 block:^{
        [testcase pullToCheck: dataInitialShadow
                   exeHandler:^(BOOL isSame) {
                     
                     // If here failed, says initial push to remote is failed.
                     expect(isSame).to.beTruthy;
                     
                   } completion:^(NSError *error) {
                     
                     expect(error).to.beNil;
                   }];
      }];
      
      // Start Scenario 1, part 1.
      [dispatchQueue performGroupedDelay: 2 block:^{
        NSDictionary *expectShadow = @{
                                       @"A": @{@"author": @"A", @"url": @"A"},
                                       @"B": @{@"author": @"B", @"url": @"B"}
                                       };
        NSDictionary *client = @{
                                 @"B": @{@"author": @"B", @"url": @"B1"},
                                 @"D": @{@"author": @"D", @"url": @"D"},
                                 @"E": @{@"author": @"E", @"url": @"E"}
                                 };
        [testcase examineSpec: @"S1P1"
                     commitId: nil
                   remoteHash: nil
                   clientDict: client
                 expectShadow: nil
               examineHandler:^(NSDictionary *shadow) {
                 
                 expect(shadow).to.equal(expectShadow);
                 
               } shouldReplace:^BOOL(id oldValue, id newValue) {
                 
                 return NO;
                 
               } exeHandler:^(NSDictionary *diff, NSError *error) {
                 
                 expect(error).to.beNil;
                 
               } completion:^(NSDictionary *newShadow, NSString *commitId, NSError *error) {
                 
                 NSDictionary *expectRemote = @{
                                                @"B": @{@"author": @"B", @"url": @"B"},
                                                @"D": @{@"author": @"D", @"url": @"D"},
                                                @"E": @{@"author": @"E", @"url": @"E"}
                                                };
                 
                 expect(error).to.beNil;
                 expect(newShadow).to.equal(expectRemote);
               }];
      }];
      
      // Start Scenario 1, part 2.
      [dispatchQueue performGroupedDelay: 2 block:^{
        NSDictionary *expectShadow = @{
                                       @"B": @{@"author": @"B", @"url": @"B"},
                                       @"D": @{@"author": @"D", @"url": @"D"},
                                       @"E": @{@"author": @"E", @"url": @"E"}
                                       };
        NSDictionary *client = @{
                                 @"B": @{@"author": @"B", @"url": @"B2"},
                                 @"D": @{@"author": @"D", @"url": @"D1"},
                                 @"F": @{@"author": @"F", @"url": @"F"}
                                 };
        [testcase examineSpec: @"S1P2"
                     commitId: nil
                   remoteHash: nil
                   clientDict: client
                 expectShadow: nil
               examineHandler:^(NSDictionary *shadow) {
                 
                 expect(shadow).to.equal(expectShadow);
                 
               } shouldReplace:^BOOL(id oldValue, id newValue) {
                 
                 return NO;
                 
               } exeHandler:^(NSDictionary *diff, NSError *error) {
                 
                 expect(error).to.beNil;
                 
               } completion:^(NSDictionary *newShadow, NSString *commitId, NSError *error) {
                 
                 NSDictionary *expectRemote = @{
                                                @"B": @{@"author": @"B", @"url": @"B"},
                                                @"D": @{@"author": @"D", @"url": @"D"},
                                                @"F": @{@"author": @"F", @"url": @"F"}
                                                };
                 expect(error).to.beNil;
                 expect(newShadow).to.equal(expectRemote);
               }];
      }];
      
      // Start Scenario 2, part 1.
      [dispatchQueue performGroupedDelay: 2 block:^{
        NSDictionary *expectShadow = @{
                                       @"B": @{@"author": @"B", @"url": @"B"},
                                       @"D": @{@"author": @"D", @"url": @"D"},
                                       @"E": @{@"author": @"E", @"url": @"E"}
                                       };
        NSDictionary *client = @{
                                 @"B": @{@"author": @"B", @"url": @"B3"},
                                 @"D": @{@"author": @"D", @"url": @"D3"},
                                 @"G": @{@"author": @"G", @"url": @"G"}
                                 };
        NSDictionary *actualRemote = @{
                                       @"B": @{@"author": @"B", @"url": @"B"},
                                       @"D": @{@"author": @"D", @"url": @"D"},
                                       @"F": @{@"author": @"F", @"url": @"F"}
                                       };
        NSDictionary *diff_cilent_shadow = [DSWrapper diffWins: client loses: expectShadow];
        NSDictionary *need_to_apply_to_client = [DSWrapper diffWins: actualRemote loses: client];
        NSDictionary *newClient = [DSWrapper mergeInto: client applyDiff: need_to_apply_to_client];
        newClient = [DSWrapper mergeInto: newClient
                               applyDiff: diff_cilent_shadow
                              primaryKey: @"comicName"
                           shouldReplace:^BOOL(id oldValue, id newValue) {
                             return NO;
                           }];
        NSDictionary *need_to_apply_to_remote = [DSWrapper diffWins: newClient loses: actualRemote];
        
        [testcase examineSpec: @"S2P1"
                     commitId: @"123123gfdg213123gdgd2112312312312"
                   remoteHash: nil
                   clientDict: client
                 expectShadow: expectShadow
               examineHandler:^(NSDictionary *shadow) {
                 
                 expect(shadow).notTo.equal(expectShadow);
                 
               } shouldReplace:^BOOL(id oldValue, id newValue) {
                 
                 return NO;
                 
               } exeHandler:^(NSDictionary *diff, NSError *error) {
                 
                 expect(error).to.beNil;
                 expect(diff).to.equal(need_to_apply_to_remote);
                 
               } completion:^(NSDictionary *newShadow, NSString *commitId, NSError *error) {
                 
                 NSDictionary *expectRemote = @{
                                                @"B": @{@"author": @"B", @"url": @"B"},
                                                @"D": @{@"author": @"D", @"url": @"D"},
                                                @"F": @{@"author": @"F", @"url": @"F"},
                                                @"G": @{@"author": @"G", @"url": @"G"}
                                                };
                 expect(error).to.beNil;
                 expect(newShadow).to.equal(expectRemote);
               }];
      }];
      
      // Start Scenario 1, part 3.
      [dispatchQueue performGroupedDelay: 2 block:^{
        NSDictionary *expectShadow = @{
                                       @"B": @{@"author": @"B", @"url": @"B"},
                                       @"D": @{@"author": @"D", @"url": @"D"},
                                       @"F": @{@"author": @"F", @"url": @"F"}
                                       };
        NSDictionary *client = @{
                                 @"A": @{@"author": @"A", @"url": @"A1"},
                                 @"B": @{@"author": @"B", @"url": @"B1"},
                                 @"D": @{@"author": @"D", @"url": @"D3"},
                                 @"F": @{@"author": @"F", @"url": @"F"},
                                 @"H": @{@"author": @"H", @"url": @"H"}
                                 };
        NSDictionary *actualRemote = @{
                                       @"B": @{@"author": @"B", @"url": @"B"},
                                       @"D": @{@"author": @"D", @"url": @"D"},
                                       @"F": @{@"author": @"F", @"url": @"F"},
                                       @"G": @{@"author": @"G", @"url": @"G"}
                                       };
        NSDictionary *diff_cilent_shadow = [DSWrapper diffWins: client loses: expectShadow primaryKey: @"comicName"];
        
        NSDictionary *newClient = actualRemote;
        newClient = [DSWrapper mergeInto: newClient
                               applyDiff: diff_cilent_shadow
                              primaryKey: @"comicName"
                           shouldReplace:^BOOL(id oldValue, id newValue) {
                             return NO;
                           }];
        NSDictionary *need_to_apply_to_remote = [DSWrapper diffWins: newClient loses: actualRemote];
        
        [testcase examineSpec: @"S1P3"
                     commitId: @"1231435323213123gdfgdf2112312312312"
                   remoteHash: nil
                   clientDict: client
                 expectShadow: expectShadow
               examineHandler:^(NSDictionary *shadow) {
                 
                 expect(shadow).notTo.equal(expectShadow);
                 
               } shouldReplace:^BOOL(id oldValue, id newValue) {
                 
                 return NO;
                 
               } exeHandler:^(NSDictionary *diff, NSError *error) {
                 
                 expect(error).to.beNil;
                 expect(diff).to.equal(need_to_apply_to_remote);
                 
               } completion:^(NSDictionary *newShadow, NSString *commitId, NSError *error) {
                 
                 NSDictionary *expectRemote = @{
                                                @"A": @{@"author": @"A", @"url": @"A1"},
                                                @"B": @{@"author": @"B", @"url": @"B"},
                                                @"D": @{@"author": @"D", @"url": @"D"},
                                                @"F": @{@"author": @"F", @"url": @"F"},
                                                @"G": @{@"author": @"G", @"url": @"G"},
                                                @"H": @{@"author": @"H", @"url": @"H"}
                                                };
                 expect(error).to.beNil;
                 expect(newShadow).to.equal(expectRemote);
               }];
      }];
      
      // Final check if remote data is the same with expectData.
      [dispatchQueue performGroupedDelay: 2 block:^{
        [testcase pullToCheck: @{
                                 @"A": @{@"author": @"A", @"url": @"A1"},
                                 @"B": @{@"author": @"B", @"url": @"B"},
                                 @"D": @{@"author": @"D", @"url": @"D"},
                                 @"F": @{@"author": @"F", @"url": @"F"},
                                 @"G": @{@"author": @"G", @"url": @"G"},
                                 @"H": @{@"author": @"H", @"url": @"H"}
                                 }
                   exeHandler:^(BOOL isSame) {
                     expect(isSame).to.beTruthy;
                   } completion:^(NSError *error) {
                     expect(error).to.beNil;
                     expect(error).notTo.beNil;
                     done();
                   }];
      }];
    });
  });
  
  afterAll(^{
    
    [dispatchQueue waitForGroup];
    dispatchQueue = nil;
    testcase = nil;
  });
  
});

SpecEnd
