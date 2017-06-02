//
//  PlistManager.h
//  LoginManager
//
//  Created by Stan Liu on 27/03/2017.
//  Copyright © 2017 Stan Liu. All rights reserved.
//

#import <Foundation/Foundation.h>



#define bookmarks_identifier (@"bookmarks")

@interface PlistManager : NSObject

// local
-(void)loadBookmarksWithUser:(NSString *)user file:(NSString *)file completion:(void(^)(NSMutableArray *bookmarks, NSString *path))completion;


-(void)saveBookmark:(NSDictionary *)bookmark in:(NSString *)user;


/**
 To Delete bookmark locally in plist
 
 @param bookmark dictionary, keys: comicName, author, url
 @param user username
 */
-(void)deleteBookmark:(NSDictionary *)bookmark ofUser:(NSString *)user;


@end
