//
//  DSTest1.m
//  AWSWrapper
//
//  Created by Stan Liu on 14/07/2017.
//  Copyright © 2017 lyc2345. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TestCase.h"
#import "DispatchQueue.h"
#import "NSArray+Sort.h"
@import AWSWrapper;

static TestCase *testcase;
static DispatchQueue *dispatchQueue;

SpecBegin(DSOPSLocalTests2)

describe(@"Test S1P1", ^{
  
  // commitId passes, remoteHash passed.
  NSDictionary *client = @{
                           @"B": @{@"author": @"B", @"url": @"B1"},
                           @"D": @{@"author": @"D", @"url": @"D"},
                           @"E": @{@"author": @"E", @"url": @"E"}
                           };
  NSDictionary *shadow = @{
                           @"A": @{@"author": @"A", @"url": @"A"},
                           @"B": @{@"author": @"B", @"url": @"B"}
                           };
  NSDictionary *remote = @{
                           @"A": @{@"author": @"A", @"url": @"A"},
                           @"B": @{@"author": @"B", @"url": @"B"}
                           };
  
  NSDictionary *diff_client_shadow = [DSWrapper diffWins: client loses: shadow];
  NSDictionary *need_to_apply_to_client = [DSWrapper diffWins: remote loses: client];
  __block NSDictionary *newClient = [DSWrapper mergeInto: client applyDiff: need_to_apply_to_client];
  
  waitUntil(^(DoneCallback done) {
    newClient = [DSWrapper mergeInto: newClient
                           applyDiff: diff_client_shadow
                          primaryKey: @"comicName"
                       shouldReplace: ^BOOL(id oldValue, id newValue) {
                         return NO;
                       }];
    done();
  });
  
  NSDictionary *need_to_apply_to_remote = [DSWrapper diffWins: newClient loses: remote];
  NSDictionary *newRemote = [DSWrapper mergeInto: remote applyDiff: need_to_apply_to_remote];
  [DSWrapper setShadow: newRemote];
  
  NSDictionary *expectResult = @{
                                 @"B": @{@"author": @"B", @"url": @"B"},
                                 @"D": @{@"author": @"D", @"url": @"D"},
                                 @"E": @{@"author": @"E", @"url": @"E"}
                                 };
  NSLog(@"fuck: %@", [[DSWrapper arrayFromDict: newRemote] dictSort]);
  
  it(@"result", ^{
    
    expect([[DSWrapper arrayFromDict: newRemote] dictSort]).to.equal([[DSWrapper arrayFromDict: expectResult] dictSort]);
    expect([[DSWrapper arrayFromDict: newClient] dictSort]).to.equal([[DSWrapper arrayFromDict: expectResult] dictSort]);
    
    XCTAssertTrue([[[DSWrapper arrayFromDict: newRemote] dictSort] isEqualToArray: [[DSWrapper arrayFromDict: expectResult] dictSort]]);
  });
});

describe(@"Test S1P2", ^{
  
  // commitId passes, remoteHash passed.
  NSDictionary *client = @{
                           @"B": @{@"author": @"B", @"url": @"B2"},
                           @"D": @{@"author": @"D", @"url": @"D1"},
                           @"F": @{@"author": @"F", @"url": @"F"}
                           };
  NSDictionary *shadow = @{
                           @"B": @{@"author": @"B", @"url": @"B"},
                           @"D": @{@"author": @"D", @"url": @"D"},
                           @"E": @{@"author": @"E", @"url": @"E"}
                           };
  NSDictionary *remote = @{
                           @"B": @{@"author": @"B", @"url": @"B"},
                           @"D": @{@"author": @"D", @"url": @"D"},
                           @"E": @{@"author": @"E", @"url": @"E"}
                           };
  
  NSDictionary *diff_client_shadow = [DSWrapper diffWins: client loses: shadow];
  NSDictionary *need_to_apply_to_client = [DSWrapper diffWins: remote loses: client];
  __block NSDictionary *newClient = [DSWrapper mergeInto: client applyDiff: need_to_apply_to_client];
  
  waitUntil(^(DoneCallback done) {
    newClient = [DSWrapper mergeInto: newClient
                           applyDiff: diff_client_shadow
                          primaryKey: @"comicName"
                       shouldReplace: ^BOOL(id oldValue, id newValue) {
                         return NO;
                       }];
    done();
  });
  
  NSDictionary *need_to_apply_to_remote = [DSWrapper diffWins: newClient loses: remote];
  NSDictionary *newRemote = [DSWrapper mergeInto: remote applyDiff: need_to_apply_to_remote];
  [DSWrapper setShadow: newRemote];
  
  NSDictionary *expectResult = @{
                                 @"B": @{@"author": @"B", @"url": @"B"},
                                 @"D": @{@"author": @"D", @"url": @"D"},
                                 @"F": @{@"author": @"F", @"url": @"F"}
                                 };
  NSLog(@"fuck: %@", [[DSWrapper arrayFromDict: newRemote] dictSort]);
  
  it(@"result", ^{
    
    expect([[DSWrapper arrayFromDict: newRemote] dictSort]).to.equal([[DSWrapper arrayFromDict: expectResult] dictSort]);
    expect([[DSWrapper arrayFromDict: newClient] dictSort]).to.equal([[DSWrapper arrayFromDict: expectResult] dictSort]);
    
    XCTAssertTrue([[[DSWrapper arrayFromDict: newRemote] dictSort] isEqualToArray: [[DSWrapper arrayFromDict: expectResult] dictSort]]);
  });
});

describe(@"Test S2P1", ^{
  
  // commitId passes, remoteHash passed.
  NSDictionary *client = @{
                           @"B": @{@"author": @"B", @"url": @"B3"},
                           @"D": @{@"author": @"D", @"url": @"D3"},
                           @"G": @{@"author": @"G", @"url": @"G"}
                           };
  NSDictionary *shadow = @{
                           @"B": @{@"author": @"B", @"url": @"B"},
                           @"D": @{@"author": @"D", @"url": @"D"},
                           @"E": @{@"author": @"E", @"url": @"E"}
                           };
  NSDictionary *remote = @{
                           @"B": @{@"author": @"B", @"url": @"B"},
                           @"D": @{@"author": @"D", @"url": @"D"},
                           @"F": @{@"author": @"F", @"url": @"F"}
                           };
  
  NSDictionary *diff_client_shadow = [DSWrapper diffWins: client loses: shadow];
  NSDictionary *need_to_apply_to_client = [DSWrapper diffWins: remote loses: client];
  __block NSDictionary *newClient = [DSWrapper mergeInto: client applyDiff: need_to_apply_to_client];
  
  waitUntil(^(DoneCallback done) {
    newClient = [DSWrapper mergeInto: newClient
                           applyDiff: diff_client_shadow
                          primaryKey: @"comicName"
                       shouldReplace: ^BOOL(id oldValue, id newValue) {
                         return NO;
                       }];
    done();
  });
  
  NSDictionary *need_to_apply_to_remote = [DSWrapper diffWins: newClient loses: remote];
  NSDictionary *newRemote = [DSWrapper mergeInto: remote applyDiff: need_to_apply_to_remote];
  [DSWrapper setShadow: newRemote];
  
  NSDictionary *expectResult = @{
                                 @"B": @{@"author": @"B", @"url": @"B"},
                                 @"D": @{@"author": @"D", @"url": @"D"},
                                 @"F": @{@"author": @"F", @"url": @"F"},
                                 @"G": @{@"author": @"G", @"url": @"G"}
                                 };
  NSLog(@"fuck: %@", [[DSWrapper arrayFromDict: newRemote] dictSort]);
  
  it(@"result", ^{
    
    expect([[DSWrapper arrayFromDict: newRemote] dictSort]).to.equal([[DSWrapper arrayFromDict: expectResult] dictSort]);
    expect([[DSWrapper arrayFromDict: newClient] dictSort]).to.equal([[DSWrapper arrayFromDict: expectResult] dictSort]);
    
    XCTAssertTrue([[[DSWrapper arrayFromDict: newRemote] dictSort] isEqualToArray: [[DSWrapper arrayFromDict: expectResult] dictSort]]);
  });
});

describe(@"Test S1P3", ^{
  
  // commitId passes, remoteHash passed.
  NSDictionary *client = @{
                           @"A": @{@"author": @"A", @"url": @"A1"},
                           @"B": @{@"author": @"B", @"url": @"B1"},
                           @"D": @{@"author": @"D", @"url": @"D3"},
                           @"F": @{@"author": @"F", @"url": @"F"},
                           @"H": @{@"author": @"H", @"url": @"H"}
                           };
  NSDictionary *shadow = @{
                           @"B": @{@"author": @"B", @"url": @"B"},
                           @"D": @{@"author": @"D", @"url": @"D"},
                           @"F": @{@"author": @"F", @"url": @"F"}
                           };
  NSDictionary *remote = @{
                           @"B": @{@"author": @"B", @"url": @"B"},
                           @"D": @{@"author": @"D", @"url": @"D"},
                           @"F": @{@"author": @"F", @"url": @"F"},
                           @"G": @{@"author": @"G", @"url": @"G"}
                           };
  
  NSDictionary *diff_client_shadow = [DSWrapper diffWins: client loses: shadow];
  NSDictionary *need_to_apply_to_client = [DSWrapper diffWins: remote loses: client];
  __block NSDictionary *newClient = [DSWrapper mergeInto: client applyDiff: need_to_apply_to_client];
  
  waitUntil(^(DoneCallback done) {
    newClient = [DSWrapper mergeInto: newClient
                           applyDiff: diff_client_shadow
                          primaryKey: @"comicName"
                       shouldReplace: ^BOOL(id oldValue, id newValue) {
                         return NO;
                       }];
    done();
  });
  
  NSDictionary *need_to_apply_to_remote = [DSWrapper diffWins: newClient loses: remote];
  NSDictionary *newRemote = [DSWrapper mergeInto: remote applyDiff: need_to_apply_to_remote];
  [DSWrapper setShadow: newRemote];
  
  NSDictionary *expectResult = @{
                                 @"A": @{@"author": @"A", @"url": @"A1"},
                                 @"B": @{@"author": @"B", @"url": @"B"},
                                 @"D": @{@"author": @"D", @"url": @"D"},
                                 @"F": @{@"author": @"F", @"url": @"F"},
                                 @"G": @{@"author": @"G", @"url": @"G"},
                                 @"H": @{@"author": @"H", @"url": @"H"}
                                 };
  NSLog(@"fuck: %@", [[DSWrapper arrayFromDict: newRemote] dictSort]);
  
  it(@"result", ^{
    
    expect([[DSWrapper arrayFromDict: newRemote] dictSort]).to.equal([[DSWrapper arrayFromDict: expectResult] dictSort]);
    expect([[DSWrapper arrayFromDict: newClient] dictSort]).to.equal([[DSWrapper arrayFromDict: expectResult] dictSort]);
    
    XCTAssertTrue([[[DSWrapper arrayFromDict: newRemote] dictSort] isEqualToArray: [[DSWrapper arrayFromDict: expectResult] dictSort]]);
  });
});


SpecEnd
