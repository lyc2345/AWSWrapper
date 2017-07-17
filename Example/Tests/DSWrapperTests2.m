//
//  DSTest1.m
//  AWSWrapper
//
//  Created by Stan Liu on 14/07/2017.
//  Copyright © 2017 lyc2345. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSArray+Sort.h"
@import AWSWrapper;

SpecBegin(DSWrapperTests2)


describe(@"Device A, A2, R3", ^{
  
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
  NSDictionary *need_to_apply_to_client = [DSWrapper diffWins: remote loses: client primaryKey: @"comicName"];
  __block NSDictionary *newClient = [DSWrapper mergeInto: client applyDiff: need_to_apply_to_client];
  
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
  NSLog(@"fuck: %@", [[DSWrapper arrayFromDict: newRemote] dictSort]);
  
  it(@"result", ^{
    
    expect([[DSWrapper arrayFromDict: newRemote] dictSort]).to.equal([[DSWrapper arrayFromDict: expectResult] dictSort]);
    expect([[DSWrapper arrayFromDict: newClient] dictSort]).to.equal([[DSWrapper arrayFromDict: expectResult] dictSort]);
    
    XCTAssertTrue([[[DSWrapper arrayFromDict: newRemote] dictSort] isEqualToArray: [[DSWrapper arrayFromDict: expectResult] dictSort]]);
  });
});

SpecEnd

