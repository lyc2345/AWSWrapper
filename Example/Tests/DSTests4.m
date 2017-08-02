//
//  DSTest1.m
//  AWSWrapper
//
//  Created by Stan Liu on 14/07/2017.
//  Copyright © 2017 lyc2345. All rights reserved.
//

#import "DynamoTestBase.h"
#import "DispatchQueue.h"
@import Specta;
@import AWSWrapper;

static DynamoTestBase *testcase;
static DispatchQueue *dispatchQueue;

SpecBegin(DSTests4)

describe(@"Tests4", ^{
  
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
      [dispatchQueue performGroupedDelay: 2 block:^{
        [testcase initial: @{
                             @"A": @{@"author": @"A", @"url": @"A"},
                             @"B": @{@"author": @"B", @"url": @"B"}
                             }
               exeHandler:^(NSString *commitId, NSString *remoteHash, NSDictionary *shadow, NSError *error) {
                 
                 expect(error).to.beNil;
                 expect(commitId).notTo.beNil;
                 expect(remoteHash).notTo.beNil;
                 
               } completion:^(NSDictionary *newShadow, NSError *error) {
                 
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
      
      // Device A, A2, R2
      [dispatchQueue performGroupedDelay: 2 block:^{
        NSDictionary *expectShadow = @{
                                       @"A": @{@"author": @"A", @"url": @"A"},
                                       @"B": @{@"author": @"B", @"url": @"B"}
                                       };
        NSDictionary *client = @{
                                 @"A": @{@"author": @"A", @"url": @"A"},
                                 @"B": @{@"author": @"B", @"url": @"B1"},
                                 @"C": @{@"author": @"C", @"url": @"C"}
                                 };
        [testcase examineSpec: @"Device A, A2, R2"
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
                 
               } completion:^(NSDictionary *newShadow, NSError *error) {
                 
                 NSDictionary *expectRemote = @{
                                                @"A": @{@"author": @"A", @"url": @"A"},
                                                @"B": @{@"author": @"B", @"url": @"B1"},
                                                @"C": @{@"author": @"C", @"url": @"C"}
                                                };
                 
                 expect(error).to.beNil;
                 expect(newShadow).to.equal(expectRemote);
               }];
      }];
      
      // Device B, B1, R2
      [dispatchQueue performGroupedDelay: 2 block:^{
        NSDictionary *expectShadow = @{
                                       };
        NSDictionary *client = @{
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
                 
               } completion:^(NSDictionary *newShadow, NSError *error) {
                 
                 NSDictionary *expectRemote = @{
                                                @"A": @{@"author": @"A", @"url": @"A"},
                                                @"B": @{@"author": @"B", @"url": @"B1"},
                                                @"C": @{@"author": @"C", @"url": @"C"}
                                                };
                 
                 expect(error).to.beNil;
                 expect(newShadow).to.equal(expectRemote);
               }];
      }];
      
      // Device B, B3, R3
      [dispatchQueue performGroupedDelay: 2 block:^{
        NSDictionary *expectShadow = @{
                                       @"A": @{@"author": @"A", @"url": @"A"},
                                       @"B": @{@"author": @"B", @"url": @"B1"},
                                       @"C": @{@"author": @"C", @"url": @"C"}
                                       };
        NSDictionary *client = @{
                                 @"A": @{@"author": @"A", @"url": @"A"},
                                 @"B": @{@"author": @"B", @"url": @"B2"},
                                 @"C": @{@"author": @"C", @"url": @"C1"},
                                 @"D": @{@"author": @"D", @"url": @"D"}
                                 };
        [testcase examineSpec: @"Device B, B3, R3"
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
                 
               } completion:^(NSDictionary *newShadow, NSError *error) {
                 
                 NSDictionary *expectRemote = @{
                                                @"A": @{@"author": @"A", @"url": @"A"},
                                                @"B": @{@"author": @"B", @"url": @"B2"},
                                                @"C": @{@"author": @"C", @"url": @"C1"},
                                                @"D": @{@"author": @"D", @"url": @"D"}
                                                };
                 expect(error).to.beNil;
                 expect(newShadow).to.equal(expectRemote);
               }];
      }];
      
      // Device A, A3, R4
      [dispatchQueue performGroupedDelay: 2 block:^{
        NSDictionary *expectShadow = @{
                                       @"A": @{@"author": @"A", @"url": @"A"},
                                       @"B": @{@"author": @"B", @"url": @"B1"},
                                       @"C": @{@"author": @"C", @"url": @"C"}
                                       };
        NSDictionary *client = @{
                                 @"A": @{@"author": @"A", @"url": @"A"},
                                 @"B": @{@"author": @"B", @"url": @"B1"},
                                 @"F": @{@"author": @"F", @"url": @"F"},
                                 @"G": @{@"author": @"G", @"url": @"G"}
                                 };
        NSDictionary *actualRemote = @{
                                       @"A": @{@"author": @"A", @"url": @"A"},
                                       @"B": @{@"author": @"B", @"url": @"B2"},
                                       @"C": @{@"author": @"C", @"url": @"C1"},
                                       @"D": @{@"author": @"D", @"url": @"D"}
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
        
        [testcase examineSpec: @"Device A, A3, R4"
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
                 
               } completion:^(NSDictionary *newShadow, NSError *error) {
                 
                 NSDictionary *expectRemote = @{
                                                @"A": @{@"author": @"A", @"url": @"A"},
                                                @"B": @{@"author": @"B", @"url": @"B2"},
                                                @"C": @{@"author": @"C", @"url": @"C1"},
                                                @"D": @{@"author": @"D", @"url": @"D"},
                                                @"F": @{@"author": @"F", @"url": @"F"},
                                                @"G": @{@"author": @"G", @"url": @"G"}
                                                };
                 expect(error).to.beNil;
                 expect(newShadow).to.equal(expectRemote);
               }];
      }];
      
      
      // Device B, B4, R4
      [dispatchQueue performGroupedDelay: 2 block:^{
        NSDictionary *expectShadow = @{
                                       @"A": @{@"author": @"A", @"url": @"A"},
                                       @"B": @{@"author": @"B", @"url": @"B2"},
                                       @"C": @{@"author": @"C", @"url": @"C1"},
                                       @"D": @{@"author": @"D", @"url": @"D"}
                                       };
        NSDictionary *client = @{
                                 @"A": @{@"author": @"A", @"url": @"A"},
                                 @"B": @{@"author": @"B", @"url": @"B2"},
                                 @"C": @{@"author": @"C", @"url": @"C1"},
                                 @"D": @{@"author": @"D", @"url": @"D"}
                                 };
        NSDictionary *actualRemote = @{
                                       @"A": @{@"author": @"A", @"url": @"A"},
                                       @"B": @{@"author": @"B", @"url": @"B2"},
                                       @"C": @{@"author": @"C", @"url": @"C1"},
                                       @"D": @{@"author": @"D", @"url": @"D"},
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
        //NSDictionary *need_to_apply_to_remote = [DSWrapper diffWins: newClient loses: actualRemote];
        
        [testcase examineSpec: @"Device B, B4, R4"
                     commitId: @"23-r032f2f0-2f"
                   remoteHash: nil
                   clientDict: client
                 expectShadow: expectShadow
               examineHandler:^(NSDictionary *shadow) {
                 
                 expect(shadow).notTo.equal(expectShadow);
                 
               } shouldReplace:^BOOL(id oldValue, id newValue) {
                 
                 return YES;
                 
               } exeHandler:^(NSDictionary *diff, NSError *error) {
                 
                 expect(error).to.beNil;
                 expect(diff).to.equal(nil);
                 
               } completion:^(NSDictionary *newShadow, NSError *error) {
                 
                 NSDictionary *expectRemote = @{
                                                @"A": @{@"author": @"A", @"url": @"A"},
                                                @"B": @{@"author": @"B", @"url": @"B2"},
                                                @"C": @{@"author": @"C", @"url": @"C1"},
                                                @"D": @{@"author": @"D", @"url": @"D"},
                                                @"F": @{@"author": @"F", @"url": @"F"},
                                                @"G": @{@"author": @"G", @"url": @"G"}
                                                };
                 expect(error).to.beNil;
                 expect(newShadow).to.equal(expectRemote);
               }];
      }];
      
      // Device A, A5, R5
      [dispatchQueue performGroupedDelay: 2 block:^{
        NSDictionary *expectShadow = @{
                                       @"A": @{@"author": @"A", @"url": @"A"},
                                       @"B": @{@"author": @"B", @"url": @"B2"},
                                       @"C": @{@"author": @"C", @"url": @"C1"},
                                       @"D": @{@"author": @"D", @"url": @"D"},
                                       @"F": @{@"author": @"F", @"url": @"F"},
                                       @"G": @{@"author": @"G", @"url": @"G"}
                                       };
        NSDictionary *client = @{
                                 @"A": @{@"author": @"A", @"url": @"A"},
                                 @"B": @{@"author": @"B", @"url": @"B2"},
                                 @"C": @{@"author": @"C", @"url": @"C1"},
                                 @"F": @{@"author": @"F", @"url": @"F"},
                                 @"G": @{@"author": @"G", @"url": @"G"},
                                 @"H": @{@"author": @"H", @"url": @"H"}
                                 };
        NSDictionary *actualRemote = @{
                                       @"A": @{@"author": @"A", @"url": @"A"},
                                       @"B": @{@"author": @"B", @"url": @"B2"},
                                       @"C": @{@"author": @"C", @"url": @"C1"},
                                       @"D": @{@"author": @"D", @"url": @"D"},
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
        
        [testcase examineSpec: @"Device A, A5, R5"
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
                 expect(diff).to.equal(need_to_apply_to_remote);
                 
               } completion:^(NSDictionary *newShadow, NSError *error) {
                 
                 NSDictionary *expectRemote = @{
                                                @"A": @{@"author": @"A", @"url": @"A"},
                                                @"B": @{@"author": @"B", @"url": @"B2"},
                                                @"C": @{@"author": @"C", @"url": @"C1"},
                                                @"F": @{@"author": @"F", @"url": @"F"},
                                                @"G": @{@"author": @"G", @"url": @"G"},
                                                @"H": @{@"author": @"H", @"url": @"H"}
                                                };
                 expect(error).to.beNil;
                 expect(newShadow).to.equal(expectRemote);
               }];
      }];
      
      // Device B, B5, R6
      [dispatchQueue performGroupedDelay: 2 block:^{
        NSDictionary *expectShadow = @{
                                       @"A": @{@"author": @"A", @"url": @"A"},
                                       @"B": @{@"author": @"B", @"url": @"B2"},
                                       @"C": @{@"author": @"C", @"url": @"C1"},
                                       @"D": @{@"author": @"D", @"url": @"D"},
                                       @"F": @{@"author": @"F", @"url": @"F"},
                                       @"G": @{@"author": @"G", @"url": @"G"}
                                       };
        NSDictionary *client = @{
                                 @"A": @{@"author": @"A", @"url": @"A"},
                                 @"B": @{@"author": @"B", @"url": @"B3"},
                                 @"C": @{@"author": @"C", @"url": @"C1"},
                                 @"D": @{@"author": @"D", @"url": @"D"},
                                 @"F": @{@"author": @"F", @"url": @"F"},
                                 @"G": @{@"author": @"G", @"url": @"G"},
                                 @"K": @{@"author": @"K", @"url": @"K"}
                                 };
        NSDictionary *actualRemote = @{
                                       @"A": @{@"author": @"A", @"url": @"A"},
                                       @"B": @{@"author": @"B", @"url": @"B2"},
                                       @"C": @{@"author": @"C", @"url": @"C1"},
                                       @"F": @{@"author": @"F", @"url": @"F"},
                                       @"G": @{@"author": @"G", @"url": @"G"},
                                       @"H": @{@"author": @"H", @"url": @"H"}
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
        
        [testcase examineSpec: @"Device B, B5, R6"
                     commitId: @"3f30232v23=2v09v223f"
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
                 
               } completion:^(NSDictionary *newShadow, NSError *error) {
                 
                 NSDictionary *expectRemote = @{
                                                @"A": @{@"author": @"A", @"url": @"A"},
                                                @"B": @{@"author": @"B", @"url": @"B3"},
                                                @"C": @{@"author": @"C", @"url": @"C1"},
                                                @"F": @{@"author": @"F", @"url": @"F"},
                                                @"G": @{@"author": @"G", @"url": @"G"},
                                                @"H": @{@"author": @"H", @"url": @"H"},
                                                @"K": @{@"author": @"K", @"url": @"K"}
                                                };
                 expect(error).to.beNil;
                 expect(newShadow).to.equal(expectRemote);
               }];
      }];
      
      // Final check if remote data is the same with expectData.
      [dispatchQueue performGroupedDelay: 2 block:^{
        [testcase pullToCheck: @{
//                                 @"A": @{@"author": @"A", @"url": @"A"},
//                                 @"B": @{@"author": @"B", @"url": @"B1"},
//                                 @"C": @{@"author": @"C", @"url": @"C1"},
//                                 @"D": @{@"author": @"D", @"url": @"D"},
//                                 @"E": @{@"author": @"E", @"url": @"E"},
//                                 @"F": @{@"author": @"F", @"url": @"F"},
//                                 @"G": @{@"author": @"G", @"url": @"G1"}
                                 @"A": @{@"author": @"A", @"url": @"A"},
                                 @"B": @{@"author": @"B", @"url": @"B3"},
                                 @"C": @{@"author": @"C", @"url": @"C1"},
                                 @"F": @{@"author": @"F", @"url": @"F"},
                                 @"G": @{@"author": @"G", @"url": @"G"},
                                 @"H": @{@"author": @"H", @"url": @"H"},
                                 @"K": @{@"author": @"K", @"url": @"K"}
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
