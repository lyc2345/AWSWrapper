//
//  DS.m
//  Differential
//
//  Created by Stan Liu on 22/04/2017.
//  Copyright © 2017 Stan Liu. All rights reserved.
//

#import "DS.h"

@implementation DS

// generate diff content
+(NSDictionary *)diffSetsFormatFromWin:(NSMutableSet *)wins loses:(NSMutableSet *)loses {
  
  return @{@"_winSet": wins, @"_loseSet": loses};
}

+(NSDictionary *)diffFormatFromAdd:(NSArray *)add delete:(NSArray *)delete replace:(NSArray *)replace {
  
  return @{@"_add": add, @"_delete": delete, @"_replace": replace};
}

+(NSDictionary *)diffShadowAndClient:(NSArray *)client shadow:(NSArray *)shadow {
  
  NSDictionary *sets = [DS diffSetWins: client losesSet: shadow];
  if (!sets) {
    return nil;
  }
  
  NSMutableSet *winsMutableSet = sets[@"_winSet"];
  NSMutableSet *losesMutableSet = sets[@"_loseSet"];
  
  NSArray *waitToAdd = [winsMutableSet allObjects];
  NSArray *waitToDelete = [losesMutableSet allObjects];
  
  NSDictionary *diff = [DS diffFormatFromAdd: waitToAdd delete: waitToDelete replace: @[]];
  //NSLog(@"diff: %@", diff);
  return diff;
}

// Generate both wins set and loses set.
/*
 e.g.
 wins  : [B, C, D]
 loses : [A, B, C]
 */
+(NSDictionary *)diffSetWins:(NSArray *)wins losesSet:(NSArray *)loses {
  
  // 1. Convert array to mutable set
  NSMutableSet *winsMutableSet = [NSMutableSet setWithArray: wins];
  NSMutableSet *losesMutableSet = [NSMutableSet setWithArray: loses];
  
  // 2. set common set as losesMutableSet (see losesMutableSet as origin sets)
  /*
   e.g. [A, B, C]
   */
  NSMutableSet *commonSet = [NSMutableSet setWithSet: losesMutableSet];
  
  // 3. intersect commonSet with winMutableSet
  // e.g. [A, B, C] intersect [B, C, D] = [B, C]
  [commonSet intersectSet: winsMutableSet];
  
  // 4. commonSet minus losesMutableSet because loses so = wait to be deleted
  // e.g. [A, B, C] - [B, C] = [A], because wait to be deleted = -A
  [losesMutableSet minusSet: commonSet];
  
  // 5. commonSet minus winMutableSet because wins so = wait to be added
  // e.g. [B, C, D] - [B, C] = [D], because wait to be added = +D
  [winsMutableSet minusSet: commonSet];
  
  if (!(winsMutableSet.count > 0 || losesMutableSet.count > 0)) {
    return nil;
  }
  // e.g. diff = Add: [+D], Delete: [-A]
  NSDictionary *diffSet = [DS diffSetsFormatFromWin: winsMutableSet loses: losesMutableSet];
  NSLog(@"diffSet: %@", diffSet);
  return diffSet;
}

+(NSDictionary *)diffWins:(NSArray *)wins andLoses:(NSArray *)loses {
  
  NSDictionary *sets = [DS diffSetWins: wins losesSet: loses];
  if (!sets) {
    return nil;
  }
  
  NSMutableSet *winsMutableSet = sets[@"_winSet"];
  NSMutableSet *losesMutableSet = sets[@"_loseSet"];
  
  NSArray *waitToAdd = [winsMutableSet allObjects];
  NSArray *waitToDelete = [losesMutableSet allObjects];
  
  // replace is empty because this case the duplicate always add new, delete old.
  NSDictionary *diff = [DS diffFormatFromAdd: waitToAdd delete: waitToDelete replace: @[]];
  return diff;
}

+(NSDictionary *)diffWins:(NSArray *)wins
                 andLoses:(NSArray *)loses
               primaryKey:(NSString *)key
            shouldReplace:(BOOL(^)(id oldValue, id newValue))shouldReplace {
  
  NSDictionary *sets = [DS diffSetWins: wins losesSet: loses];
  if (!sets) {
    return nil;
  }
  
  NSMutableSet *winsMutableSet = sets[@"_winSet"];
  NSMutableSet *losesMutableSet = sets[@"_loseSet"];
  
  NSArray *waitToAdd = [winsMutableSet allObjects];
  NSArray *waitToDelete = [losesMutableSet allObjects];
  
  NSMutableArray *oldValue = [NSMutableArray array];
  NSMutableArray *newValue = [NSMutableArray array];
  
  [waitToAdd enumerateObjectsUsingBlock:^(id  _Nonnull addObj, NSUInteger idx, BOOL * _Nonnull stop) {
    
    [waitToDelete enumerateObjectsUsingBlock:^(id  _Nonnull delObj, NSUInteger idx, BOOL * _Nonnull stop) {
      
      // if 2 dictioanries have same primary key
      if ([addObj[key] isEqualToString: delObj[key]]) {
        
        // means the object in waitToAdd array will be the new value, opposite old value in waitToDelete.
        [newValue addObject: addObj];
        [oldValue addObject: delObj];
      }
    }];
  }];
  
  // send these old and new value, let user to define which one are going to be keep.
  BOOL replace = shouldReplace(oldValue, newValue);
  
  // newAdd just keep the data that never keep before.
  NSMutableSet *originAddSet = [NSMutableSet setWithArray: waitToAdd];
  [originAddSet minusSet: [NSSet setWithArray: newValue]];
  NSArray *newAdd = [originAddSet allObjects];
  
  if (!replace) {
    
    NSMutableSet *originDelSet = [NSMutableSet setWithArray: waitToDelete];
    [originDelSet minusSet: [NSSet setWithArray: oldValue]];
    // if don't replace. leave old data and delete the changed data.
    // p.s. just keep the data that want to remove BUT NOT EDIT
    NSArray *newDel = [originDelSet allObjects];
    return [DS diffFormatFromAdd: newAdd delete: newDel replace: @[]];
  }
  // newValue is the data that keeps before and now going to edit.
  return [DS diffFormatFromAdd: newAdd delete: waitToDelete replace: newValue];
}

+(NSArray *)mergeInto:(NSArray *)into applyDiff:(NSDictionary *)diff {
  
  NSMutableArray *newInto;
  
  NSArray *add = diff[@"_add"];
  NSArray *delete = diff[@"_delete"];
  NSArray *replace = diff[@"_replace"];
  
  NSMutableSet *intoMutableSet = [NSMutableSet setWithArray: into];
  
  NSSet *deleteSet = [NSSet setWithArray: delete];
  [intoMutableSet minusSet: deleteSet];
  
  newInto = [[intoMutableSet allObjects] mutableCopy];
  
  [add enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
    
    if (![newInto containsObject: obj]) {
      [newInto addObject: obj];
    }
  }];
  
  if (replace && replace.count > 0) {
    [replace enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
      
      if (![newInto containsObject: obj]) {
        [newInto addObject: obj];
      }
    }];
  }
  
  return newInto;
}


@end

