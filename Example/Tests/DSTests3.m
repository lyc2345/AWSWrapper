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

SpecBegin(DSTests3)

describe(@"Tests3", ^{
  
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
      
      // Device A, A1, R1
      [dispatchQueue performGroupedDelay: 0.3 block:^{
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
      [dispatchQueue performGroupedDelay: 0.3 block:^{
        [testcase pullToCheck: dataInitialShadow
                   exeHandler:^(BOOL isSame) {
                     
                     // If here failed, says initial push to remote is failed.
                     expect(isSame).to.beTruthy;
                     
                   } completion:^(NSError *error) {
                     
                     expect(error).to.beNil;
                   }];
      }];
      
      // Device B, B1, R2
      [dispatchQueue performGroupedDelay: 0.3 block:^{
        NSDictionary *expectShadow = @{
                                       };
        NSDictionary *client = @{
                                 @"C": @{@"author": @"C", @"url": @"C"},
                                 @"D": @{@"author": @"D", @"url": @"D"}
                                 };
        [testcase examineSpec: @"Device B, B1, R2"
                     commitId: @"4543fm3f30f30fmf330"
                   remoteHash: nil
                   clientDict: client
                 expectShadow: expectShadow
               examineHandler:^(NSDictionary *shadow) {
                 
                 expect(shadow).notTo.equal(expectShadow);
                 
               } shouldReplace:^BOOL(id oldValue, id newValue) {
                 
                 return YES;
                 
               } exeHandler:^(NSDictionary *diff, NSError *error) {
                 
                 expect(error).to.beNil;
                 
               } completion:^(NSDictionary *newShadow, NSString *commitId, NSError *error) {
                 
                 NSDictionary *expectRemote = @{
                                                @"A": @{@"author": @"A", @"url": @"A"},
                                                @"B": @{@"author": @"B", @"url": @"B"},
                                                @"C": @{@"author": @"C", @"url": @"C"},
                                                @"D": @{@"author": @"D", @"url": @"D"}
                                                };
                 
                 expect(error).to.beNil;
                 expect(newShadow).to.equal(expectRemote);
               }];
      }];
      
      // Device B, B2, R3
      [dispatchQueue performGroupedDelay: 0.3 block:^{
        NSDictionary *expectShadow = @{
                                       @"A": @{@"author": @"A", @"url": @"A"},
                                       @"B": @{@"author": @"B", @"url": @"B"},
                                       @"C": @{@"author": @"C", @"url": @"C"},
                                       @"D": @{@"author": @"D", @"url": @"D"}
                                       };
        NSDictionary *client = @{
                                 @"A": @{@"author": @"A", @"url": @"A"},
                                 @"B": @{@"author": @"B", @"url": @"B"},
                                 @"C": @{@"author": @"C", @"url": @"C"},
                                 @"D": @{@"author": @"D", @"url": @"D"},
                                 @"E": @{@"author": @"E", @"url": @"E"},
                                 @"F": @{@"author": @"F", @"url": @"F"},
                                 @"G": @{@"author": @"G", @"url": @"G"}
                                 };
        [testcase examineSpec: @"S1P2"
                     commitId: nil
                   remoteHash: nil
                   clientDict: client
                 expectShadow: nil
               examineHandler:^(NSDictionary *shadow) {
                 
                 expect(shadow).to.equal(expectShadow);
                 
               } shouldReplace:^BOOL(id oldValue, id newValue) {
                 
                 return YES;
                 
               } exeHandler:^(NSDictionary *diff, NSError *error) {
                 
                 expect(error).to.beNil;
                 
               } completion:^(NSDictionary *newShadow, NSString *commitId, NSError *error) {
                 
                 NSDictionary *expectRemote = @{
                                                @"A": @{@"author": @"A", @"url": @"A"},
                                                @"B": @{@"author": @"B", @"url": @"B"},
                                                @"C": @{@"author": @"C", @"url": @"C"},
                                                @"D": @{@"author": @"D", @"url": @"D"},
                                                @"E": @{@"author": @"E", @"url": @"E"},
                                                @"F": @{@"author": @"F", @"url": @"F"},
                                                @"G": @{@"author": @"G", @"url": @"G"}
                                                };
                 expect(error).to.beNil;
                 expect(newShadow).to.equal(expectRemote);
               }];
      }];
      
      // Device A, A2, R3
      [dispatchQueue performGroupedDelay: 0.3 block:^{
        NSDictionary *expectShadow = @{
                                       @"A": @{@"author": @"A", @"url": @"A"},
                                       @"B": @{@"author": @"B", @"url": @"B"}
                                       };
        NSDictionary *client = @{
                                 @"A": @{@"author": @"A", @"url": @"A"},
                                 @"B": @{@"author": @"B", @"url": @"B"}
                                 };
        NSDictionary *actualRemote = @{
                                       @"A": @{@"author": @"A", @"url": @"A"},
                                       @"B": @{@"author": @"B", @"url": @"B"},
                                       @"C": @{@"author": @"C", @"url": @"C"},
                                       @"D": @{@"author": @"D", @"url": @"D"},
                                       @"E": @{@"author": @"E", @"url": @"E"},
                                       @"F": @{@"author": @"F", @"url": @"F"},
                                       @"G": @{@"author": @"G", @"url": @"G"}
                                       };
        NSDictionary *diff_cilent_shadow = [DSWrapper diffWins: client loses: expectShadow primaryKey: @"comicName"];
        
        NSDictionary *newClient = actualRemote;
        newClient = [DSWrapper mergeInto: newClient
                               applyDiff: diff_cilent_shadow
                              primaryKey: @"comicName"
                           shouldReplace:^BOOL(id oldValue, id newValue) {
                             return YES;
                           }];
        NSDictionary *need_to_apply_to_remote = [DSWrapper diffWins: newClient loses: actualRemote];
        
        [testcase examineSpec: @"Device A, A2, R3"
                     commitId: @"123123gfdg213123gdgd2112312312312"
                   remoteHash: nil
                   clientDict: client
                 expectShadow: expectShadow
               examineHandler:^(NSDictionary *shadow) {
                 
                 expect(shadow).notTo.equal(expectShadow);
                 
               } shouldReplace:^BOOL(id oldValue, id newValue) {
                 
                 return YES;
                 
               } exeHandler:^(NSDictionary *diff, NSError *error) {
                 
                 expect(error).to.beNil;
                 expect(diff).to.equal(need_to_apply_to_remote);
                 
               } completion:^(NSDictionary *newShadow, NSString *commitId, NSError *error) {
                 
                 NSDictionary *expectRemote = @{
                                                @"A": @{@"author": @"A", @"url": @"A"},
                                                @"B": @{@"author": @"B", @"url": @"B"},
                                                @"C": @{@"author": @"C", @"url": @"C"},
                                                @"D": @{@"author": @"D", @"url": @"D"},
                                                @"E": @{@"author": @"E", @"url": @"E"},
                                                @"F": @{@"author": @"F", @"url": @"F"},
                                                @"G": @{@"author": @"G", @"url": @"G"}
                                                };
                 expect(error).to.beNil;
                 expect(newShadow).to.equal(expectRemote);
               }];
      }];
      
      // Device A, A3, R4
      [dispatchQueue performGroupedDelay: 0.3 block:^{
        NSDictionary *expectShadow = @{
                                       @"A": @{@"author": @"A", @"url": @"A"},
                                       @"B": @{@"author": @"B", @"url": @"B"},
                                       @"C": @{@"author": @"C", @"url": @"C"},
                                       @"D": @{@"author": @"D", @"url": @"D"},
                                       @"E": @{@"author": @"E", @"url": @"E"},
                                       @"F": @{@"author": @"F", @"url": @"F"},
                                       @"G": @{@"author": @"G", @"url": @"G"}
                                       };
        NSDictionary *client = @{
                                 @"A": @{@"author": @"A", @"url": @"A"},
                                 @"B": @{@"author": @"B", @"url": @"B1"},
                                 @"C": @{@"author": @"C", @"url": @"C1"},
                                 @"D": @{@"author": @"D", @"url": @"D"},
                                 @"E": @{@"author": @"E", @"url": @"E"},
                                 @"F": @{@"author": @"F", @"url": @"F"},
                                 @"G": @{@"author": @"G", @"url": @"G1"}
                                 };
        NSDictionary *actualRemote = @{
                                       @"A": @{@"author": @"A", @"url": @"A"},
                                       @"B": @{@"author": @"B", @"url": @"B"},
                                       @"C": @{@"author": @"C", @"url": @"C"},
                                       @"D": @{@"author": @"D", @"url": @"D"},
                                       @"E": @{@"author": @"E", @"url": @"E"},
                                       @"F": @{@"author": @"F", @"url": @"F"},
                                       @"G": @{@"author": @"G", @"url": @"G"}
                                       };
        NSDictionary *diff_cilent_shadow = [DSWrapper diffWins: client loses: expectShadow primaryKey: @"comicName"];
        
        NSDictionary *newClient = actualRemote;
        newClient = [DSWrapper mergeInto: newClient
                               applyDiff: diff_cilent_shadow
                              primaryKey: @"comicName"
                           shouldReplace:^BOOL(id oldValue, id newValue) {
                             return YES;
                           }];
        NSDictionary *need_to_apply_to_remote = [DSWrapper diffWins: newClient loses: actualRemote primaryKey: @"comicName"];
        
        [testcase examineSpec: @"Device A, A3, R4"
                     commitId: nil
                   remoteHash: nil
                   clientDict: client
                 expectShadow: nil
               examineHandler:^(NSDictionary *shadow) {
                 
                 expect(shadow).to.equal(expectShadow);
                 
               } shouldReplace:^BOOL(id oldValue, id newValue) {
                 
                 return YES;
                 
               } exeHandler:^(NSDictionary *diff, NSError *error) {
                 
                 expect(error).to.beNil;
                 //expect(diff).to.equal(need_to_apply_to_remote);
                 
               } completion:^(NSDictionary *newShadow, NSString *commitId, NSError *error) {
                 
                 NSDictionary *expectRemote = @{
                                                @"A": @{@"author": @"A", @"url": @"A"},
                                                @"B": @{@"author": @"B", @"url": @"B1"},
                                                @"C": @{@"author": @"C", @"url": @"C1"},
                                                @"D": @{@"author": @"D", @"url": @"D"},
                                                @"E": @{@"author": @"E", @"url": @"E"},
                                                @"F": @{@"author": @"F", @"url": @"F"},
                                                @"G": @{@"author": @"G", @"url": @"G1"}
                                                };
                 expect(error).to.beNil;
                 expect(newShadow).to.equal(expectRemote);
               }];
      }];
      
      // Device B, B4, R5
      [dispatchQueue performGroupedDelay: 0.3 block:^{
        NSDictionary *expectShadow = @{
                                       @"A": @{@"author": @"A", @"url": @"A"},
                                       @"B": @{@"author": @"B", @"url": @"B"},
                                       @"C": @{@"author": @"C", @"url": @"C"},
                                       @"D": @{@"author": @"D", @"url": @"D"},
                                       @"E": @{@"author": @"E", @"url": @"E"},
                                       @"F": @{@"author": @"F", @"url": @"F"},
                                       @"G": @{@"author": @"G", @"url": @"G"}
                                       };
        NSDictionary *client = @{
                                 @"A": @{@"author": @"A", @"url": @"A"},
                                 @"B": @{@"author": @"B", @"url": @"B"},
                                 @"C": @{@"author": @"C", @"url": @"C"},
                                 @"D": @{@"author": @"D", @"url": @"D"},
                                 @"E": @{@"author": @"E", @"url": @"E"},
                                 @"F": @{@"author": @"F", @"url": @"F"},
                                 @"G": @{@"author": @"G", @"url": @"G"}
                                 };
        NSDictionary *actualRemote = @{
                                       @"A": @{@"author": @"A", @"url": @"A"},
                                       @"B": @{@"author": @"B", @"url": @"B1"},
                                       @"C": @{@"author": @"C", @"url": @"C1"},
                                       @"D": @{@"author": @"D", @"url": @"D"},
                                       @"E": @{@"author": @"E", @"url": @"E"},
                                       @"F": @{@"author": @"F", @"url": @"F"},
                                       @"G": @{@"author": @"G", @"url": @"G1"}
                                       };
        NSDictionary *diff_cilent_shadow = [DSWrapper diffWins: client loses: expectShadow primaryKey: @"comicName"];
        
        NSDictionary *newClient = actualRemote;
        newClient = [DSWrapper mergeInto: newClient
                               applyDiff: diff_cilent_shadow
                              primaryKey: @"comicName"
                           shouldReplace:^BOOL(id oldValue, id newValue) {
                             return YES;
                           }];
        NSDictionary *need_to_apply_to_remote = [DSWrapper diffWins: newClient loses: actualRemote];
        
        [testcase examineSpec: @"Device A, A2, R3"
                     commitId: @"123123gfdg213123gdgd2112312312312"
                   remoteHash: nil
                   clientDict: client
                 expectShadow: expectShadow
               examineHandler:^(NSDictionary *shadow) {
                 
                 expect(shadow).notTo.equal(expectShadow);
                 
               } shouldReplace:^BOOL(id oldValue, id newValue) {
                 
                 return YES;
                 
               } exeHandler:^(NSDictionary *diff, NSError *error) {
                 
                 expect(error).to.beNil;
                 expect(diff).to.equal(need_to_apply_to_remote);
                 
               } completion:^(NSDictionary *newShadow, NSString *commitId, NSError *error) {
                 
                 NSDictionary *expectRemote = @{
                                                @"A": @{@"author": @"A", @"url": @"A"},
                                                @"B": @{@"author": @"B", @"url": @"B1"},
                                                @"C": @{@"author": @"C", @"url": @"C1"},
                                                @"D": @{@"author": @"D", @"url": @"D"},
                                                @"E": @{@"author": @"E", @"url": @"E"},
                                                @"F": @{@"author": @"F", @"url": @"F"},
                                                @"G": @{@"author": @"G", @"url": @"G1"}
                                                };
                 expect(error).to.beNil;
                 expect(newShadow).to.equal(expectRemote);
               }];
      }];
      
      // Final check if remote data is the same with expectData.
      [dispatchQueue performGroupedDelay: 0.3 block:^{
        [testcase pullToCheck: @{
                                 @"A": @{@"author": @"A", @"url": @"A"},
                                 @"B": @{@"author": @"B", @"url": @"B1"},
                                 @"C": @{@"author": @"C", @"url": @"C1"},
                                 @"D": @{@"author": @"D", @"url": @"D"},
                                 @"E": @{@"author": @"E", @"url": @"E"},
                                 @"F": @{@"author": @"F", @"url": @"F"},
                                 @"G": @{@"author": @"G", @"url": @"G1"}
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
