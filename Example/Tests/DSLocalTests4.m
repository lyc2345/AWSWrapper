//
//  DSTest1.m
//  AWSWrapper
//
//  Created by Stan Liu on 14/07/2017.
//  Copyright © 2017 lyc2345. All rights reserved.
//

#import "DynamoTestBase.h"
#import "DispatchQueue.h"
#import "NSArray+Sort.h"
#import "Specta/Specta.h"
#import "Expecta/Expecta.h"
@import AWSWrapper;

static DynamoTestBase *testcase;
static DispatchQueue *dispatchQueue;

SpecBegin(DSLocalTests4)

// Device A, A1, R1, [A, B]

describe(@"Device A, A2, R2", ^{
  
  // commitId passes, remoteHash passed.
  NSDictionary *client = @{
                           @"A": @{@"author": @"A", @"url": @"A"},
                           @"B": @{@"author": @"B", @"url": @"B1"},
                           @"C": @{@"author": @"C", @"url": @"C"}
                           };
  NSDictionary *shadow = @{
                           @"A": @{@"author": @"A", @"url": @"A"},
                           @"B": @{@"author": @"B", @"url": @"B"}
                           };
  NSDictionary *remote = @{
                           @"A": @{@"author": @"A", @"url": @"A"},
                           @"B": @{@"author": @"B", @"url": @"B"}
                           };
  
  NSDictionary *diff_client_shadow = [DSWrapper diffWins: client loses: shadow primaryKey: @"comicName"];
  __block NSDictionary *newClient = remote;
  
  waitUntil(^(DoneCallback done) {
    newClient = [DSWrapper mergeInto: newClient
                           applyDiff: diff_client_shadow
                          primaryKey: @"comicName"
                       shouldReplace: ^BOOL(id oldValue, id newValue) {
                         return YES;
                       }];
    done();
  });
  
  NSDictionary *need_to_apply_to_remote = [DSWrapper diffWins: newClient loses: remote];
  NSDictionary *newRemote = [DSWrapper mergeInto: remote applyDiff: need_to_apply_to_remote];
  [DSWrapper setShadow: newRemote];
  
  NSDictionary *expectResult = @{
                                 @"A": @{@"author": @"A", @"url": @"A"},
                                 @"B": @{@"author": @"B", @"url": @"B1"},
                                 @"C": @{@"author": @"C", @"url": @"C"}
                                 };
  it(@"result", ^{
    
    expect([[DSWrapper arrayFromDict: newRemote] dictSort]).to.equal([[DSWrapper arrayFromDict: expectResult] dictSort]);
    expect([[DSWrapper arrayFromDict: newClient] dictSort]).to.equal([[DSWrapper arrayFromDict: expectResult] dictSort]);
    
    XCTAssertTrue([[[DSWrapper arrayFromDict: newRemote] dictSort] isEqualToArray: [[DSWrapper arrayFromDict: expectResult] dictSort]]);
  });
});

describe(@"DeviceB, B1, R2", ^{
  
  // commitId passes, remoteHash passed.
  NSDictionary *client = @{
                           };
  NSDictionary *shadow = @{
                           };
  NSDictionary *remote = @{
                           @"A": @{@"author": @"A", @"url": @"A"},
                           @"B": @{@"author": @"B", @"url": @"B1"},
                           @"C": @{@"author": @"C", @"url": @"C"}
                           };
  
  NSDictionary *diff_client_shadow = [DSWrapper diffWins: client loses: shadow primaryKey: @"comicName"];
  __block NSDictionary *newClient = remote;
  
  waitUntil(^(DoneCallback done) {
    newClient = [DSWrapper mergeInto: newClient
                           applyDiff: diff_client_shadow
                          primaryKey: @"comicName"
                       shouldReplace: ^BOOL(id oldValue, id newValue) {
                         return YES;
                       }];
    done();
  });
  
  NSDictionary *need_to_apply_to_remote = [DSWrapper diffWins: newClient loses: remote];
  NSDictionary *newRemote = [DSWrapper mergeInto: remote applyDiff: need_to_apply_to_remote];
  [DSWrapper setShadow: newRemote];
  
  NSDictionary *expectResult = @{
                                 @"A": @{@"author": @"A", @"url": @"A"},
                                 @"B": @{@"author": @"B", @"url": @"B1"},
                                 @"C": @{@"author": @"C", @"url": @"C"}
                                 };
  it(@"result", ^{
    
    expect([[DSWrapper arrayFromDict: newRemote] dictSort]).to.equal([[DSWrapper arrayFromDict: expectResult] dictSort]);
    expect([[DSWrapper arrayFromDict: newClient] dictSort]).to.equal([[DSWrapper arrayFromDict: expectResult] dictSort]);
    
    XCTAssertTrue([[[DSWrapper arrayFromDict: newRemote] dictSort] isEqualToArray: [[DSWrapper arrayFromDict: expectResult] dictSort]]);
  });
});

describe(@"Device B, B2, R3", ^{
  
  // commitId passes, remoteHash passed.
  NSDictionary *client = @{
                           @"A": @{@"author": @"A", @"url": @"A"},
                           @"B": @{@"author": @"B", @"url": @"B2"},
                           @"C": @{@"author": @"C", @"url": @"C1"},
                           @"D": @{@"author": @"D", @"url": @"D"},
                           };
  NSDictionary *shadow = @{
                           @"A": @{@"author": @"A", @"url": @"A"},
                           @"B": @{@"author": @"B", @"url": @"B1"},
                           @"C": @{@"author": @"C", @"url": @"C"}
                           };
  NSDictionary *remote = @{
                           @"A": @{@"author": @"A", @"url": @"A"},
                           @"B": @{@"author": @"B", @"url": @"B1"},
                           @"C": @{@"author": @"C", @"url": @"C"}
                           };
  
  NSDictionary *diff_client_shadow = [DSWrapper diffWins: client loses: shadow primaryKey: @"comicName"];
  __block NSDictionary *newClient = remote;
  
  waitUntil(^(DoneCallback done) {
    newClient = [DSWrapper mergeInto: newClient
                           applyDiff: diff_client_shadow
                          primaryKey: @"comicName"
                       shouldReplace: ^BOOL(id oldValue, id newValue) {
                         return YES;
                       }];
    done();
  });
  
  NSDictionary *need_to_apply_to_remote = [DSWrapper diffWins: newClient loses: remote];
  NSDictionary *newRemote = [DSWrapper mergeInto: remote applyDiff: need_to_apply_to_remote];
  [DSWrapper setShadow: newRemote];
  
  NSDictionary *expectResult = @{
                                 @"A": @{@"author": @"A", @"url": @"A"},
                                 @"B": @{@"author": @"B", @"url": @"B2"},
                                 @"C": @{@"author": @"C", @"url": @"C1"},
                                 @"D": @{@"author": @"D", @"url": @"D"}
                                 };
  it(@"result", ^{
    
    expect([[DSWrapper arrayFromDict: newRemote] dictSort]).to.equal([[DSWrapper arrayFromDict: expectResult] dictSort]);
    expect([[DSWrapper arrayFromDict: newClient] dictSort]).to.equal([[DSWrapper arrayFromDict: expectResult] dictSort]);
    
    XCTAssertTrue([[[DSWrapper arrayFromDict: newRemote] dictSort] isEqualToArray: [[DSWrapper arrayFromDict: expectResult] dictSort]]);
  });
});

describe(@"Device A, A2, R4", ^{
  
  // commitId passes, remoteHash passed.
  NSDictionary *client = @{
                           @"A": @{@"author": @"A", @"url": @"A"},
                           @"B": @{@"author": @"B", @"url": @"B1"},
                           @"F": @{@"author": @"F", @"url": @"F"},
                           @"G": @{@"author": @"G", @"url": @"G"}
                           };
  NSDictionary *shadow = @{
                           @"A": @{@"author": @"A", @"url": @"A"},
                           @"B": @{@"author": @"B", @"url": @"B1"},
                           @"C": @{@"author": @"C", @"url": @"C"}
                           };
  NSDictionary *remote = @{
                           @"A": @{@"author": @"A", @"url": @"A"},
                           @"B": @{@"author": @"B", @"url": @"B2"},
                           @"C": @{@"author": @"C", @"url": @"C1"},
                           @"D": @{@"author": @"D", @"url": @"D"}
                           };
  
  NSDictionary *diff_client_shadow = [DSWrapper diffWins: client loses: shadow primaryKey: @"comicName"];
  __block NSDictionary *newClient = remote;
  
  waitUntil(^(DoneCallback done) {
    newClient = [DSWrapper mergeInto: newClient
                           applyDiff: diff_client_shadow
                          primaryKey: @"comicName"
                       shouldReplace: ^BOOL(id oldValue, id newValue) {
                         return YES;
                       }];
    done();
  });
  
  NSDictionary *need_to_apply_to_remote = [DSWrapper diffWins: newClient loses: remote];
  NSDictionary *newRemote = [DSWrapper mergeInto: remote applyDiff: need_to_apply_to_remote];
  [DSWrapper setShadow: newRemote];
  
  NSDictionary *expectResult = @{
                                 @"A": @{@"author": @"A", @"url": @"A"},
                                 @"B": @{@"author": @"B", @"url": @"B2"},
                                 @"C": @{@"author": @"C", @"url": @"C1"},
                                 @"D": @{@"author": @"D", @"url": @"D"},
                                 @"F": @{@"author": @"F", @"url": @"F"},
                                 @"G": @{@"author": @"G", @"url": @"G"}
                                 };
  it(@"result", ^{
    
    expect([[DSWrapper arrayFromDict: newRemote] dictSort]).to.equal([[DSWrapper arrayFromDict: expectResult] dictSort]);
    expect([[DSWrapper arrayFromDict: newClient] dictSort]).to.equal([[DSWrapper arrayFromDict: expectResult] dictSort]);
    
    XCTAssertTrue([[[DSWrapper arrayFromDict: newRemote] dictSort] isEqualToArray: [[DSWrapper arrayFromDict: expectResult] dictSort]]);
  });
});

describe(@"Device A, A4, R5", ^{
  
  // commitId passes, remoteHash passed.
  NSDictionary *client = @{
                           @"A": @{@"author": @"A", @"url": @"A"},
                           @"B": @{@"author": @"B", @"url": @"B2"},
                           @"C": @{@"author": @"C", @"url": @"C1"},
                           @"F": @{@"author": @"F", @"url": @"F"},
                           @"G": @{@"author": @"G", @"url": @"G"},
                           @"H": @{@"author": @"H", @"url": @"H"}
                           };
  NSDictionary *shadow = @{
                           @"A": @{@"author": @"A", @"url": @"A"},
                           @"B": @{@"author": @"B", @"url": @"B2"},
                           @"C": @{@"author": @"C", @"url": @"C1"},
                           @"D": @{@"author": @"D", @"url": @"D"},
                           @"F": @{@"author": @"F", @"url": @"F"},
                           @"G": @{@"author": @"G", @"url": @"G"}
                           };
  NSDictionary *remote = @{
                           @"A": @{@"author": @"A", @"url": @"A"},
                           @"B": @{@"author": @"B", @"url": @"B2"},
                           @"C": @{@"author": @"C", @"url": @"C1"},
                           @"D": @{@"author": @"D", @"url": @"D"},
                           @"F": @{@"author": @"F", @"url": @"F"},
                           @"G": @{@"author": @"G", @"url": @"G"}
                           };
  
  NSDictionary *diff_client_shadow = [DSWrapper diffWins: client loses: shadow primaryKey: @"comicName"];
  __block NSDictionary *newClient = remote;
  
  waitUntil(^(DoneCallback done) {
    newClient = [DSWrapper mergeInto: newClient
                           applyDiff: diff_client_shadow
                          primaryKey: @"comicName"
                       shouldReplace: ^BOOL(id oldValue, id newValue) {
                         return YES;
                       }];
    done();
  });
  
  NSDictionary *need_to_apply_to_remote = [DSWrapper diffWins: newClient loses: remote];
  NSDictionary *newRemote = [DSWrapper mergeInto: remote applyDiff: need_to_apply_to_remote];
  [DSWrapper setShadow: newRemote];
  
  NSDictionary *expectResult = @{
                                 @"A": @{@"author": @"A", @"url": @"A"},
                                 @"B": @{@"author": @"B", @"url": @"B2"},
                                 @"C": @{@"author": @"C", @"url": @"C1"},
                                 @"F": @{@"author": @"F", @"url": @"F"},
                                 @"G": @{@"author": @"G", @"url": @"G"},
                                 @"H": @{@"author": @"H", @"url": @"H"}
                                 };
  it(@"result", ^{
    
    expect([[DSWrapper arrayFromDict: newRemote] dictSort]).to.equal([[DSWrapper arrayFromDict: expectResult] dictSort]);
    expect([[DSWrapper arrayFromDict: newClient] dictSort]).to.equal([[DSWrapper arrayFromDict: expectResult] dictSort]);
    
    XCTAssertTrue([[[DSWrapper arrayFromDict: newRemote] dictSort] isEqualToArray: [[DSWrapper arrayFromDict: expectResult] dictSort]]);
  });
});

describe(@"Device B, B4, R4", ^{
  
  // commitId passes, remoteHash passed.
  NSDictionary *client = @{
                           @"A": @{@"author": @"A", @"url": @"A"},
                           @"B": @{@"author": @"B", @"url": @"B2"},
                           @"C": @{@"author": @"C", @"url": @"C1"},
                           @"D": @{@"author": @"D", @"url": @"D"}
                           };
  NSDictionary *shadow = @{
                           @"A": @{@"author": @"A", @"url": @"A"},
                           @"B": @{@"author": @"B", @"url": @"B2"},
                           @"C": @{@"author": @"C", @"url": @"C1"},
                           @"D": @{@"author": @"D", @"url": @"D"}
                           };
  NSDictionary *remote = @{
                           @"A": @{@"author": @"A", @"url": @"A"},
                           @"B": @{@"author": @"B", @"url": @"B2"},
                           @"C": @{@"author": @"C", @"url": @"C1"},
                           @"D": @{@"author": @"D", @"url": @"D"},
                           @"F": @{@"author": @"F", @"url": @"F"},
                           @"G": @{@"author": @"G", @"url": @"G"}
                           };
  
  NSDictionary *diff_client_shadow = [DSWrapper diffWins: client loses: shadow primaryKey: @"comicName"];
  __block NSDictionary *newClient = remote;
  
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
                                 @"A": @{@"author": @"A", @"url": @"A"},
                                 @"B": @{@"author": @"B", @"url": @"B2"},
                                 @"C": @{@"author": @"C", @"url": @"C1"},
                                 @"D": @{@"author": @"D", @"url": @"D"},
                                 @"F": @{@"author": @"F", @"url": @"F"},
                                 @"G": @{@"author": @"G", @"url": @"G"}
                                 };
  it(@"result", ^{
    
    expect([[DSWrapper arrayFromDict: newRemote] dictSort]).to.equal([[DSWrapper arrayFromDict: expectResult] dictSort]);
    expect([[DSWrapper arrayFromDict: newClient] dictSort]).to.equal([[DSWrapper arrayFromDict: expectResult] dictSort]);
    
    XCTAssertTrue([[[DSWrapper arrayFromDict: newRemote] dictSort] isEqualToArray: [[DSWrapper arrayFromDict: expectResult] dictSort]]);
  });
});

describe(@"Device B, B4, R6", ^{
  
  // commitId passes, remoteHash passed.
  NSDictionary *client = @{
                           @"A": @{@"author": @"A", @"url": @"A"},
                           @"B": @{@"author": @"B", @"url": @"B3"},
                           @"C": @{@"author": @"C", @"url": @"C1"},
                           @"D": @{@"author": @"D", @"url": @"D"},
                           @"F": @{@"author": @"F", @"url": @"F"},
                           @"G": @{@"author": @"G", @"url": @"G"},
                           @"K": @{@"author": @"K", @"url": @"K"}
                           };
  NSDictionary *shadow = @{
                           @"A": @{@"author": @"A", @"url": @"A"},
                           @"B": @{@"author": @"B", @"url": @"B2"},
                           @"C": @{@"author": @"C", @"url": @"C1"},
                           @"D": @{@"author": @"D", @"url": @"D"},
                           @"F": @{@"author": @"F", @"url": @"F"},
                           @"G": @{@"author": @"G", @"url": @"G"}
                           };
  NSDictionary *remote = @{
                           @"A": @{@"author": @"A", @"url": @"A"},
                           @"B": @{@"author": @"B", @"url": @"B2"},
                           @"C": @{@"author": @"C", @"url": @"C1"},
                           @"F": @{@"author": @"F", @"url": @"F"},
                           @"G": @{@"author": @"G", @"url": @"G"},
                           @"H": @{@"author": @"H", @"url": @"H"}
                           };
  
  NSDictionary *diff_client_shadow = [DSWrapper diffWins: client loses: shadow primaryKey: @"comicName"];
  __block NSDictionary *newClient = remote;
  
  waitUntil(^(DoneCallback done) {
    newClient = [DSWrapper mergeInto: newClient
                           applyDiff: diff_client_shadow
                          primaryKey: @"comicName"
                       shouldReplace: ^BOOL(id oldValue, id newValue) {
                         return YES;
                       }];
    done();
  });
  
  NSDictionary *need_to_apply_to_remote = [DSWrapper diffWins: newClient loses: remote];
  NSDictionary *newRemote = [DSWrapper mergeInto: remote applyDiff: need_to_apply_to_remote];
  [DSWrapper setShadow: newRemote];
  
  NSDictionary *expectResult = @{
                                 @"A": @{@"author": @"A", @"url": @"A"},
                                 @"B": @{@"author": @"B", @"url": @"B3"},
                                 @"C": @{@"author": @"C", @"url": @"C1"},
                                 @"F": @{@"author": @"F", @"url": @"F"},
                                 @"G": @{@"author": @"G", @"url": @"G"},
                                 @"H": @{@"author": @"H", @"url": @"H"},
                                 @"K": @{@"author": @"K", @"url": @"K"}
                                 };
  it(@"result", ^{
    
    expect([[DSWrapper arrayFromDict: newRemote] dictSort]).to.equal([[DSWrapper arrayFromDict: expectResult] dictSort]);
    expect([[DSWrapper arrayFromDict: newClient] dictSort]).to.equal([[DSWrapper arrayFromDict: expectResult] dictSort]);
    
    XCTAssertTrue([[[DSWrapper arrayFromDict: newRemote] dictSort] isEqualToArray: [[DSWrapper arrayFromDict: expectResult] dictSort]]);
  });
});

SpecEnd
