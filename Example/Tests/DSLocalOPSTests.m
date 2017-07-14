//
//  DynamoSyncLocalComparisonTests.m
//  AWSWrapper
//
//  Created by Stan Liu on 01/07/2017.
//  Copyright © 2017 lyc2345. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <XCTest/XCTestExpectation.h>
@import AWSWrapper;

@interface NSArray (Sort)

-(NSArray *)sort;

@end

@implementation NSArray (Sort)

-(NSArray *)sort {
  
  return [self sortedArrayUsingSelector: @selector(localizedCompare:)];
}

-(NSArray *)dictSort {
  
  return [self sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
    
    NSString *author1 = obj1[@"comicName"];
    NSString *author2 = obj2[@"comicName"];
    
    return [author1 localizedStandardCompare: author2];
  }];
}
@end

@implementation DSWrapper (Testing)

+(void)setShadow:(NSDictionary *)s {
  
  [[NSUserDefaults standardUserDefaults] setObject: s forKey: @"__dynamo_testing_shadow"];
}

+(NSDictionary *)shadow {
  
  return [[NSUserDefaults standardUserDefaults] dictionaryForKey: @"__dynamo_testing_shadow"];
}

@end

@interface DSLocalOPSTests : XCTestCase

@end

@implementation DSLocalOPSTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
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

    }];
}


-(void)testS1P1 {
  // commitId passes, remoteHash passed.
  NSDictionary *client = @{
                           @"A": @{@"author": @"A", @"url": @"A"},
                           @"B": @{@"author": @"B", @"url": @"B"},
                           @"C": @{@"author": @"C", @"url": @"C"},
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
  NSDictionary *newClient = [DSWrapper mergeInto: client applyDiff: need_to_apply_to_client];
  
  newClient = [DSWrapper mergeInto: newClient
                         applyDiff: diff_client_shadow
                        primaryKey: @"comicName"
                     shouldReplace: ^BOOL(id oldValue, id newValue) {
                       return NO;
                     }];
  
  
  NSDictionary *need_to_apply_to_remote = [DSWrapper diffWins: newClient loses: remote];
  NSDictionary *newRemote = [DSWrapper mergeInto: remote applyDiff: need_to_apply_to_remote];
  [DSWrapper setShadow: newRemote];
  
  NSDictionary *expectResult = @{
                                 @"A": @{@"author": @"A", @"url": @"A"},
                                 @"B": @{@"author": @"B", @"url": @"B"},
                                 @"C": @{@"author": @"C", @"url": @"C"},
                                 @"D": @{@"author": @"D", @"url": @"D"},
                                 @"E": @{@"author": @"E", @"url": @"E"}
                                 };
  NSLog(@"fuck: %@", [[DSWrapper arrayFromDict: newRemote] dictSort]);
  XCTAssertTrue([[[DSWrapper arrayFromDict: newRemote] dictSort] isEqualToArray: [[DSWrapper arrayFromDict: expectResult] dictSort]]);
  XCTAssertTrue([[[DSWrapper arrayFromDict: newClient] dictSort] isEqualToArray: [[DSWrapper arrayFromDict: expectResult] dictSort]]);
}

-(void)testS1P2 {
  // commitId passes, remoteHash passed.
  NSDictionary *client = @{
                           @"B": @{@"author": @"B", @"url": @"B"},
                           @"C": @{@"author": @"C", @"url": @"C"},
                           @"E": @{@"author": @"E", @"url": @"E"},
                           @"F": @{@"author": @"F", @"url": @"F"}
                           };
  NSDictionary *shadow = @{
                           @"A": @{@"author": @"A", @"url": @"A"},
                           @"B": @{@"author": @"B", @"url": @"B"},
                           @"C": @{@"author": @"C", @"url": @"C"},
                           @"D": @{@"author": @"D", @"url": @"D"},
                           @"E": @{@"author": @"E", @"url": @"E"}
                           };
  NSDictionary *remote = @{
                           @"A": @{@"author": @"A", @"url": @"A"},
                           @"B": @{@"author": @"B", @"url": @"B"},
                           @"C": @{@"author": @"C", @"url": @"C"},
                           @"D": @{@"author": @"D", @"url": @"D"},
                           @"E": @{@"author": @"E", @"url": @"E"}
                           };
  
  NSDictionary *diff_client_shadow = [DSWrapper diffWins: client loses: shadow];
  NSDictionary *need_to_apply_to_client = [DSWrapper diffWins: remote loses: client];
  NSDictionary *newClient = [DSWrapper mergeInto: client applyDiff: need_to_apply_to_client];
  
  newClient = [DSWrapper mergeInto: newClient
                         applyDiff: diff_client_shadow
                        primaryKey: @"comicName"
                     shouldReplace: ^BOOL(id oldValue, id newValue) {
                       return NO;
                     }];
  
  
  NSDictionary *need_to_apply_to_remote = [DSWrapper diffWins: newClient loses: remote];
  NSDictionary *newRemote = [DSWrapper mergeInto: remote applyDiff: need_to_apply_to_remote];
  [DSWrapper setShadow: newRemote];
  
  NSDictionary *expectResult = @{
                                 @"B": @{@"author": @"B", @"url": @"B"},
                                 @"C": @{@"author": @"C", @"url": @"C"},
                                 @"E": @{@"author": @"E", @"url": @"E"},
                                 @"F": @{@"author": @"F", @"url": @"F"}
                                 };
  NSLog(@"fuck: %@", [[DSWrapper arrayFromDict: newRemote] dictSort]);
  XCTAssertTrue([[[DSWrapper arrayFromDict: newRemote] dictSort] isEqualToArray: [[DSWrapper arrayFromDict: expectResult] dictSort]]);
  XCTAssertTrue([[[DSWrapper arrayFromDict: newClient] dictSort] isEqualToArray: [[DSWrapper arrayFromDict: expectResult] dictSort]]);
}

-(void)testS2P1 {
  // commitId passes, remoteHash passed.
  NSDictionary *client = @{
                           @"B": @{@"author": @"B", @"url": @"B"},
                           @"C": @{@"author": @"C", @"url": @"C"},
                           @"D": @{@"author": @"D", @"url": @"D"},
                           @"E": @{@"author": @"E", @"url": @"E"},
                           @"G": @{@"author": @"G", @"url": @"G"}
                           };
  NSDictionary *shadow = @{
                           @"A": @{@"author": @"A", @"url": @"A"},
                           @"B": @{@"author": @"B", @"url": @"B"},
                           @"C": @{@"author": @"C", @"url": @"C"},
                           @"D": @{@"author": @"D", @"url": @"D"},
                           @"E": @{@"author": @"E", @"url": @"E"}
                           };
  NSDictionary *remote = @{
                           @"B": @{@"author": @"B", @"url": @"B"},
                           @"C": @{@"author": @"C", @"url": @"C"},
                           @"E": @{@"author": @"E", @"url": @"E"},
                           @"F": @{@"author": @"F", @"url": @"F"}
                           };
  
  NSDictionary *diff_client_shadow = [DSWrapper diffWins: client loses: shadow];
  NSDictionary *need_to_apply_to_client = [DSWrapper diffWins: remote loses: client];
  NSDictionary *newClient = [DSWrapper mergeInto: client applyDiff: need_to_apply_to_client];
  
  newClient = [DSWrapper mergeInto: newClient
                         applyDiff: diff_client_shadow
                        primaryKey: @"comicName"
                     shouldReplace: ^BOOL(id oldValue, id newValue) {
                       return NO;
                     }];
  
  
  NSDictionary *need_to_apply_to_remote = [DSWrapper diffWins: newClient loses: remote];
  NSDictionary *newRemote = [DSWrapper mergeInto: remote applyDiff: need_to_apply_to_remote];
  [DSWrapper setShadow: newRemote];
  
  NSDictionary *expectResult = @{
                                 @"B": @{@"author": @"B", @"url": @"B"},
                                 @"C": @{@"author": @"C", @"url": @"C"},
                                 @"E": @{@"author": @"E", @"url": @"E"},
                                 @"F": @{@"author": @"F", @"url": @"F"},
                                 @"G": @{@"author": @"G", @"url": @"G"}
                                 };
  NSLog(@"fuck: %@", [[DSWrapper arrayFromDict: newRemote] dictSort]);
  XCTAssertTrue([[[DSWrapper arrayFromDict: newRemote] dictSort] isEqualToArray: [[DSWrapper arrayFromDict: expectResult] dictSort]]);
  XCTAssertTrue([[[DSWrapper arrayFromDict: newClient] dictSort] isEqualToArray: [[DSWrapper arrayFromDict: expectResult] dictSort]]);
}

-(void)testS1P3 {
  // commitId passes, remoteHash passed.
  NSDictionary *client = @{
                           @"A": @{@"author": @"A", @"url": @"A"},
                           @"B": @{@"author": @"B", @"url": @"B1"},
                           @"E": @{@"author": @"E", @"url": @"E"},
                           @"F": @{@"author": @"F", @"url": @"F1"}
                           };
  NSDictionary *shadow = @{
                           @"B": @{@"author": @"B", @"url": @"B"},
                           @"C": @{@"author": @"C", @"url": @"C"},
                           @"E": @{@"author": @"E", @"url": @"E"},
                           @"F": @{@"author": @"F", @"url": @"F"}
                           };
  NSDictionary *remote = @{
                           @"B": @{@"author": @"B", @"url": @"B"},
                           @"C": @{@"author": @"C", @"url": @"C"},
                           @"E": @{@"author": @"E", @"url": @"E"},
                           @"F": @{@"author": @"F", @"url": @"F"},
                           @"G": @{@"author": @"G", @"url": @"G"}
                           };
  
  NSDictionary *diff_client_shadow = [DSWrapper diffWins: client loses: shadow];
  NSDictionary *need_to_apply_to_client = [DSWrapper diffWins: remote loses: client];
  NSDictionary *newClient = [DSWrapper mergeInto: client applyDiff: need_to_apply_to_client];
  
  newClient = [DSWrapper mergeInto: newClient
                         applyDiff: diff_client_shadow
                        primaryKey: @"comicName"
                     shouldReplace: ^BOOL(id oldValue, id newValue) {
                       return NO;
                     }];
  
  
  NSDictionary *need_to_apply_to_remote = [DSWrapper diffWins: newClient loses: remote];
  NSDictionary *newRemote = [DSWrapper mergeInto: remote applyDiff: need_to_apply_to_remote];
  [DSWrapper setShadow: newRemote];
  
  NSDictionary *expectResult = @{
                                 @"A": @{@"author": @"A", @"url": @"A"},
                                 @"B": @{@"author": @"B", @"url": @"B"},
                                 @"E": @{@"author": @"E", @"url": @"E"},
                                 @"F": @{@"author": @"F", @"url": @"F"},
                                 @"G": @{@"author": @"G", @"url": @"G"}
                                 };
  NSLog(@"fuck: %@", [[DSWrapper arrayFromDict: newRemote] dictSort]);
  XCTAssertTrue([[[DSWrapper arrayFromDict: newRemote] dictSort] isEqualToArray: [[DSWrapper arrayFromDict: expectResult] dictSort]]);
  XCTAssertTrue([[[DSWrapper arrayFromDict: newClient] dictSort] isEqualToArray: [[DSWrapper arrayFromDict: expectResult] dictSort]]);
}



@end
