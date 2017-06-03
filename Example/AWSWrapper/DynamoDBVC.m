//
//  DynamoDBVC.m
//  LoginManager
//
//  Created by Stan Liu on 27/03/2017.
//  Copyright © 2017 Stan Liu. All rights reserved.
//

#import "DynamoDBVC.h"
#import "Bookmark.h"
#import "RecentVisit.h"
#import "BookmarkManager.h"
#import "LoginManager.h"
#import "DSWrapper.h"

NSString *const cellIdentifier = @"cell";

@interface DynamoDBVC () <UITableViewDelegate, UITableViewDataSource> {
	
	__weak IBOutlet UITableView *_tableView;
}

@property NSDictionary *localBookmark;
@property Bookmark *remoteBookmark;
@property NSDictionary *localRecentVisitItems;
@property RecentVisit *remoteRecentVisitItems;

@end

@implementation DynamoDBVC

- (void)viewDidLoad {
    [super viewDidLoad];
	
	[_tableView registerClass: [UITableViewCell class] forCellReuseIdentifier: cellIdentifier];
	
	UIBarButtonItem *uploadBtn = [[UIBarButtonItem alloc] initWithTitle: @"Upload" style: UIBarButtonItemStylePlain target: self action: @selector(upload:)];
	self.navigationItem.rightBarButtonItem = uploadBtn;

	[self reloadBookmarks];
	[self reloadRecentlyVisit];
}

-(void)reloadBookmarks {
	
	BookmarkManager *bookmarkManager = [BookmarkManager new];
	LoginManager *loginManager = [LoginManager shared];
	NSString *userId = loginManager.awsIdentityId != nil ? loginManager.awsIdentityId : loginManager.offlineIdentity;
	NSDictionary *localBookmarkRecord = [bookmarkManager getOfflineRecordOfIdentity: userId type: RecordTypeBookmark];
	
	self.localBookmark = localBookmarkRecord;
	[_tableView reloadData];
	
	if ([LoginManager shared].awsIdentityId) {
		
		[bookmarkManager pull: [Bookmark class] withUser: loginManager.awsIdentityId completion:^(NSArray *items, NSError *error) {
			
			dispatch_async(dispatch_get_main_queue(), ^{
				
				self.remoteBookmark = items.firstObject;
				[_tableView reloadSections: [NSIndexSet indexSetWithIndex: 1] withRowAnimation: UITableViewRowAnimationNone];
			});
		}];
	}
}

-(void)reloadRecentlyVisit {
	
	BookmarkManager *bookmarkManager = [BookmarkManager new];
	LoginManager *loginManager = [LoginManager shared];
	NSString *userId = loginManager.awsIdentityId != nil ? loginManager.awsIdentityId : loginManager.offlineIdentity;
	NSDictionary *localRecentlyVisit = [bookmarkManager getOfflineRecordOfIdentity: userId type: RecordTypeRecentlyVisit];
	
	self.localRecentVisitItems = localRecentlyVisit;
	[_tableView reloadData];
	
	if ([LoginManager shared].awsIdentityId) {
		
		[bookmarkManager pull: [RecentVisit class] withUser: loginManager.awsIdentityId completion:^(NSArray *items, NSError *error) {
			
			dispatch_async(dispatch_get_main_queue(), ^{
				
				self.remoteRecentVisitItems = items.firstObject;
				[_tableView reloadSections: [NSIndexSet indexSetWithIndex: 3] withRowAnimation: UITableViewRowAnimationNone];
			});
		}];
	}
}

-(void)upload:(id)sender {
	
	BookmarkManager *bookmarkManager = [BookmarkManager new];
	
	Bookmark *bookmark = [Bookmark new];
	bookmark._id = self.localBookmark[@"_identity"];
	bookmark._userId = self.localBookmark[@"_identity"];
	bookmark._dicts = self.localBookmark[@"_dicts"];
	bookmark._remoteHash = self.localBookmark[@"_remoteHash"];
	bookmark._commitId = self.localBookmark[@"_commitId"];
	
	[bookmarkManager mergePushWithRecord: bookmark type: RecordTypeBookmark completion:^(NSError *error) {
		
		dispatch_sync(dispatch_get_main_queue(), ^{
			[self reloadBookmarks];
		});
	}];
	
	RecentVisit *recentVisit = [RecentVisit new];
	recentVisit._id = self.localRecentVisitItems[@"_identity"];
	recentVisit._userId = self.localRecentVisitItems[@"_identity"];
	recentVisit._dicts = self.localRecentVisitItems[@"_dicts"];
	recentVisit._remoteHash = self.localRecentVisitItems[@"_remoteHash"];
	recentVisit._commitId = self.localRecentVisitItems[@"_commitId"];
	
	[bookmarkManager mergePushWithRecord: recentVisit type: RecordTypeRecentlyVisit completion:^(NSError *error) {
		
		dispatch_sync(dispatch_get_main_queue(), ^{
			[self reloadRecentlyVisit];
		});
	}];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	
	return 4;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	if (section == 0) {
		return [(NSArray *)self.localBookmark[@"_dicts"] count];
	} else if (section == 1) {
		return self.remoteBookmark._dicts.count;
	} else if (section == 2) {
		return [(NSArray *)self.localRecentVisitItems[@"_dicts"] count];
	} else if (section == 3){
		return self.remoteRecentVisitItems._dicts.count;
	}
	return 0;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	
	if (section == 0) {
		return [NSString stringWithFormat:@"LB: %lu- %@", (unsigned long)[(NSArray *)self.localBookmark[@"_dicts"] count], [self.localBookmark[@"_commitId"] substringWithRange: NSMakeRange(((NSString *)self.localBookmark[@"_commitId"]).length - 10, 10)]];
	} else if (section == 1) {
		return [NSString stringWithFormat:@"B: %lu - %@",(unsigned long)self.remoteBookmark._dicts.count, [self.remoteBookmark._commitId substringWithRange: NSMakeRange(self.remoteBookmark._commitId.length - 10, 10)]];
	} else if (section == 2) {
		return [NSString stringWithFormat:@"LB: %lu- %@", (unsigned long)[(NSArray *)self.localRecentVisitItems[@"_dicts"] count], [self.localRecentVisitItems[@"_commitId"] substringWithRange: NSMakeRange(((NSString *)self.localRecentVisitItems[@"_commitId"]).length - 10, 10)]];
	} else if (section == 3) {
		return [NSString stringWithFormat:@"B: %lu - %@",(unsigned long)self.remoteRecentVisitItems._dicts.count, [self.remoteRecentVisitItems._commitId substringWithRange: NSMakeRange(self.remoteRecentVisitItems._commitId.length - 10, 10)]];
	}
	return @"";
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	return indexPath.section % 2 == 0 ? YES : NO;
}

-(NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	UITableViewRowAction *delete = [UITableViewRowAction rowActionWithStyle: UITableViewRowActionStyleDefault title: @"Delete" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
		
		BookmarkManager *bookmarkManager = [BookmarkManager new];
		
		if (indexPath.section == 0) {
			
			[tableView beginUpdates];
			self.localBookmark = [bookmarkManager deleteOffline: [DSWrapper arrayFromDict: self.localBookmark[@"_dicts"]][indexPath.row] type: RecordTypeBookmark ofIdentity: self.localBookmark[@"_identity"]];
			[tableView deleteRowsAtIndexPaths: @[indexPath] withRowAnimation: UITableViewRowAnimationLeft];
			[tableView reloadSectionIndexTitles];
			[tableView endUpdates];
			
		} else if (indexPath.section == 2) {
			
			[tableView beginUpdates];
			self.localRecentVisitItems = [bookmarkManager deleteOffline: [DSWrapper arrayFromDict: self.localRecentVisitItems[@"_dicts"]][indexPath.row] type: RecordTypeRecentlyVisit ofIdentity: self.localRecentVisitItems[@"_identity"]];
			[tableView deleteRowsAtIndexPaths: @[indexPath] withRowAnimation: UITableViewRowAnimationLeft];
			[tableView reloadSectionIndexTitles];
			[tableView endUpdates];
		}
		
	}];
	
	return @[delete];
	/*
	UITableViewRowAction *insert = [UITableViewRowAction rowActionWithStyle: UITableViewRowActionStyleDefault title: @"Insert" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
		
		action.backgroundColor = [UIColor blueColor];
		
		BookmarkManager *bookmarkManager = [BookmarkManager new];
		if (indexPath.section == 0) {
			[bookmarkManager addOfflineBookmark: nil ofIdentity: self.localBookmark[@"_userId"]];
			
		} else if (indexPath.section == 2) {
			
		}
	}];
	return @[delete, insert];
	 */
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: cellIdentifier];
	
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
	}
	
	if (indexPath.section == 0) {
		
		NSArray *bks = [DSWrapper arrayFromDict: self.localBookmark[@"_dicts"]];
		NSDictionary *bk = bks[indexPath.row];
		//NSDictionary *bk = self.localBookmark[@"_dicts"][indexPath.row];
		
		cell.textLabel.text = [NSString stringWithFormat: @"%@, %@, %@", bk[@"comicName"], bk[@"author"], bk[@"url"]];
		
	} else if (indexPath.section == 1) {
		
		NSArray *comics = [DSWrapper arrayFromDict: self.remoteBookmark._dicts];
		NSDictionary *comic = comics[indexPath.row];
		NSString *comicName = comic[@"comicName"];
		NSString *author = comic[@"author"];
		NSString *url = comic[@"url"];
		cell.textLabel.text = [NSString stringWithFormat: @"%@, %@, %@", comicName, author, url];
		cell.detailTextLabel.text = [NSString stringWithFormat: @"url: %@", url];
		
	} else if (indexPath.section == 2)  {
		
		NSArray *bks = [DSWrapper arrayFromDict: self.localRecentVisitItems[@"_dicts"]];
		NSDictionary *bk = bks[indexPath.row];
		//NSDictionary *bk = self.localBookmark[@"_dicts"][indexPath.row];
		
		cell.textLabel.text = [NSString stringWithFormat: @"%@, %@, %@", bk[@"comicName"], bk[@"author"], bk[@"url"]];
		
	} else if (indexPath.section == 3)  {
		
		NSArray *comics = [DSWrapper arrayFromDict: self.remoteRecentVisitItems._dicts];
		NSDictionary *comic = comics[indexPath.row];
		NSString *comicName = comic[@"comicName"];
		NSString *author = comic[@"author"];
		NSString *url = comic[@"url"];
		cell.textLabel.text = [NSString stringWithFormat: @"%@, %@, %@", comicName, author, url];
		cell.detailTextLabel.text = [NSString stringWithFormat: @"url: %@", url];
	}
	return cell;
}

@end
