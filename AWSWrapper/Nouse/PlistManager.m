//
//  PlistManager.m
//  LoginManager
//
//  Created by Stan Liu on 27/03/2017.
//  Copyright © 2017 Stan Liu. All rights reserved.
//

#import "PlistManager.h"

@implementation PlistManager


// return defaulManager
-(NSFileManager *)fileManager {
	
	return [NSFileManager defaultManager];
}

// return ../Documents
-(NSString *)standardPath {
	
	return NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,  NSUserDomainMask,  YES).firstObject;
}

// return ../User
-(NSString *)pathOfUserDirectory:(NSString *)user {
	
	NSString *userName = [NSString stringWithFormat: @"/%@", user];
	return [[self standardPath] stringByAppendingString: userName];
}

// return ../User/xxx.plist
-(NSString *)pathOfPlist:(NSString *)plist user:(NSString *)user {
	
	NSString *plistName = [NSString stringWithFormat:@"/%@.plist", plist];
	return [[self pathOfUserDirectory: user] stringByAppendingString: plistName];
}

// detect is the same username directory existed?
-(bool)directoryExistOfUser:(NSString *)user {
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString *userPath = [self pathOfUserDirectory: user];
	return [fileManager fileExistsAtPath: userPath];
}

// To create a Directory with Folder
-(bool)createDirectoryOfPath:(NSString *)path {
	
	NSError *error;
	NSFileManager *fileManager = [NSFileManager defaultManager];
	return [fileManager createDirectoryAtPath: path withIntermediateDirectories: YES attributes: nil error: &error];
}

// detect is the plist exist in user name directory folder
-(bool)plistExistOfPath:(NSString *)path {
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	return [fileManager fileExistsAtPath: path];
}

// load bookmarks with user name and filename .plist
// e.g. Stan/bookmark.plist
-(void)loadBookmarksWithUser:(NSString *)user file:(NSString *)file completion:(void(^)(NSMutableArray *bookmarks, NSString *path))completion {
	
	//NSError *error;
	bool success;
	NSMutableArray *bookmarks;
	//NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString *userPath = [self pathOfUserDirectory: user];
	if (![self directoryExistOfUser: userPath]) {
		
		[self createDirectoryOfPath: userPath];
		//[fileManager createDirectoryAtPath: userPath withIntermediateDirectories: YES attributes: nil error: &error];
	}
	
	NSString *path = [self pathOfPlist: file user: user];
	
	if (![self plistExistOfPath: path]) {
		
		bookmarks = [NSMutableArray array];
		success = [bookmarks writeToFile: path atomically: YES];
		
	} else {
		
		bookmarks = [[NSMutableArray alloc] initWithContentsOfFile: path];
	}
	NSLog(@"bookmarks: %@ ", bookmarks);
	NSLog(@"load at: %@ ", path);
	completion ? completion(bookmarks, path) : completion(bookmarks, path);
}

-(void)saveBookmark:(NSDictionary *)bookmark in:(NSString *)user {
	
	[self bookmarkExist: bookmark ofUser: user completion:^(bool isExist, NSMutableArray *bookmarks, NSString *path, NSDictionary *object) {
		
		if (!isExist) {
			
			[bookmarks addObject: bookmark];
			bool success = [bookmarks writeToFile: path atomically: YES];
			NSLog(@"save bookmark status: %@", success ? @"Success" : @"Failured");
		}
	}];
}

-(void)deleteBookmark:(NSDictionary *)bookmark ofUser:(NSString *)user {
	
	[self bookmarkExist: bookmark ofUser: user completion:^(bool isExist, NSMutableArray *bookmarks, NSString *path, NSDictionary *object) {
		
		if (isExist) {
			
			[bookmarks removeObject: object];
			
			bool success = [bookmarks writeToFile: path atomically: YES];
			NSLog(@"delete bookmark status: %@", success ? @"Success" : @"Failured");
		}
	}];
}

-(void)bookmarkExist:(NSDictionary *)bookmark ofUser:(NSString *)user completion:(void(^)(bool isExist, NSMutableArray *bookmarks, NSString *path, NSDictionary *object))completion {
	
	completion = [completion copy];
	
	__block bool isExist;
	__block NSDictionary *existObject;
	
	[self loadBookmarksWithUser: user file: bookmarks_identifier completion:^(NSMutableArray *bookmarks, NSString *path) {
		
		if (bookmarks.count == 0) {completion(false, bookmarks, path, nil);}
		
		[bookmarks enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
			NSString *currentName = bookmark[@"comicName"];
			NSString *comicName = bookmarks[idx][@"comicName"];
			
			NSLog(@"index: %ld", (long)idx);
			bool e = [currentName isEqualToString: comicName];
			NSLog(@"comicName: %@ exist: %@", currentName, e ? @"YES": @"NO");
			if (e) {
				isExist = YES;
				existObject = obj;
				completion(isExist, bookmarks, path, existObject);
				return;
			} else {
				isExist = NO;
			}
		}];
		
		completion(isExist, bookmarks, path, existObject);
	}];
}


@end
