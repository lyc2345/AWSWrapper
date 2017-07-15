//
//  NSArray+Sort.m
//  
//
//  Created by Stan Liu on 15/07/2017.
//
//

#import <Foundation/Foundation.h>
@import AWSWrapper.DSWrapper;

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
