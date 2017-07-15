//
//  BookmarkManager_NSArray_Sort.h
//  AWSWrapper
//
//  Created by Stan Liu on 15/07/2017.
//  Copyright © 2017 lyc2345. All rights reserved.
//

@import Foundation;
@import AWSWrapper.DSWrapper;

@interface NSArray (Sort)

-(NSArray *)sort;
-(NSArray *)dictSort;

@end


@interface DSWrapper (Testing)

+(void)setShadow:(NSDictionary *)s;

+(NSDictionary *)shadow;

@end
