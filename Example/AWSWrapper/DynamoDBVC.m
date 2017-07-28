//
//  DynamoDBVC.m
//  LoginManager
//
//  Created by Stan Liu on 27/03/2017.
//  Copyright © 2017 Stan Liu. All rights reserved.
//

#import "DynamoDBVC.h"
@import AWSWrapper;

NSString *const cellIdentifier = @"cell";

@interface DynamoDBVC () <UITableViewDelegate, UITableViewDataSource> {
	
	__weak IBOutlet UITableView *_tableView;
}

@property NSDictionary *localBookmark;
@property NSDictionary *remoteBookmark;
@property NSDictionary *localRecentVisitItems;
@property NSDictionary *remoteRecentVisitItems;

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
	
	DynamoService *dynamoService = [DynamoService new];
	LoginManager *loginManager = [LoginManager shared];
	NSString *userId = loginManager.awsIdentityId != nil ? loginManager.awsIdentityId : loginManager.offlineIdentity;
	NSDictionary *localBookmarkRecord = [[OfflineDB new] getOfflineRecordOfIdentity: userId type: RecordTypeBookmark];
	
	self.localBookmark = localBookmarkRecord;
	[_tableView reloadData];
	
	if ([LoginManager shared].awsIdentityId) {
		[dynamoService pullType: RecordTypeBookmark user: loginManager.awsIdentityId completion:^(NSDictionary *item, NSError *error) {
			
			dispatch_async(dispatch_get_main_queue(), ^{
				
				self.remoteBookmark = item;
				[_tableView reloadSections: [NSIndexSet indexSetWithIndex: 1] withRowAnimation: UITableViewRowAnimationNone];
			});
		}];
	}
}

-(void)reloadRecentlyVisit {
	
	DynamoService *dynamoService = [DynamoService new];
	LoginManager *loginManager = [LoginManager shared];
	NSString *userId = loginManager.awsIdentityId != nil ? loginManager.awsIdentityId : loginManager.offlineIdentity;
	NSDictionary *localRecentlyVisit = [[OfflineDB new] getOfflineRecordOfIdentity: userId type: RecordTypeRecentlyVisit];
	
	self.localRecentVisitItems = localRecentlyVisit;
	[_tableView reloadData];
	
	if ([LoginManager shared].awsIdentityId) {
		
    [dynamoService pullType: RecordTypeRecentlyVisit user: loginManager.awsIdentityId completion:^(NSDictionary *item, NSError *error) {
			
			dispatch_async(dispatch_get_main_queue(), ^{
				
        self.remoteRecentVisitItems = item;
				[_tableView reloadSections: [NSIndexSet indexSetWithIndex: 3] withRowAnimation: UITableViewRowAnimationNone];
			});
		}];
	}
}

-(void)upload:(id)sender {
	
	DynamoService *dynamoService = [DynamoService new];
	
//  [dynamoService mergePushType:RecordTypeBookmark userId: [LoginManager shared].awsIdentityId completion:^(NSDictionary *responseItem, NSError *error) {
//		
//		dispatch_sync(dispatch_get_main_queue(), ^{
//			[self reloadBookmarks];
//		});
//	}];
//	
//   [dynamoService mergePushType:RecordTypeRecentlyVisit userId: [LoginManager shared].awsIdentityId completion:^(NSDictionary *responseItem, NSError *error) {
//		
//		dispatch_sync(dispatch_get_main_queue(), ^{
//			[self reloadRecentlyVisit];
//		});
//	}];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	
	return 4;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	if (section == 0) {
		return [(NSArray *)self.localBookmark[@"_dicts"] count];
	} else if (section == 1) {
    return [(NSArray *)self.remoteBookmark[@"_dicts"] count];
	} else if (section == 2) {
		return [(NSArray *)self.localRecentVisitItems[@"_dicts"] count];
	} else if (section == 3){
    return [(NSArray *)self.remoteRecentVisitItems[@"_dicts"] count];
	}
	return 0;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	
	if (section == 0) {
		return [NSString stringWithFormat:@"LB: %lu- %@", (unsigned long)[(NSArray *)self.localBookmark[@"_dicts"] count], [self.localBookmark[@"_commitId"] substringWithRange: NSMakeRange(((NSString *)self.localBookmark[@"_commitId"]).length - 10, 10)]];
	} else if (section == 1) {
    return [NSString stringWithFormat:@"LB: %lu- %@", (unsigned long)[(NSArray *)self.remoteBookmark[@"_dicts"] count], [self.remoteBookmark[@"_commitId"] substringWithRange: NSMakeRange(((NSString *)self.remoteBookmark[@"_commitId"]).length - 10, 10)]];

	} else if (section == 2) {
		return [NSString stringWithFormat:@"LB: %lu- %@", (unsigned long)[(NSArray *)self.localRecentVisitItems[@"_dicts"] count], [self.localRecentVisitItems[@"_commitId"] substringWithRange: NSMakeRange(((NSString *)self.localRecentVisitItems[@"_commitId"]).length - 10, 10)]];
	} else if (section == 3) {
    return [NSString stringWithFormat:@"LB: %lu- %@", (unsigned long)[(NSArray *)self.remoteRecentVisitItems[@"_dicts"] count], [self.remoteRecentVisitItems[@"_commitId"] substringWithRange: NSMakeRange(((NSString *)self.remoteRecentVisitItems[@"_commitId"]).length - 10, 10)]];
	}
	return @"";
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	return indexPath.section % 2 == 0 ? YES : NO;
}

-(NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	UITableViewRowAction *delete = [UITableViewRowAction rowActionWithStyle: UITableViewRowActionStyleDefault title: @"Delete" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
		
		DynamoService *dynamoService = [DynamoService new];
		
		if (indexPath.section == 0) {
			
			[tableView beginUpdates];
			self.localBookmark = [[OfflineDB new] deleteOffline: [DSWrapper arrayFromDict: self.localBookmark[@"_dicts"]][indexPath.row] type: RecordTypeBookmark ofIdentity: self.localBookmark[@"_userId"]];
			[tableView deleteRowsAtIndexPaths: @[indexPath] withRowAnimation: UITableViewRowAnimationLeft];
			[tableView reloadSectionIndexTitles];
			[tableView endUpdates];
			
		} else if (indexPath.section == 2) {
			
			[tableView beginUpdates];
			self.localRecentVisitItems = [[OfflineDB new] deleteOffline: [DSWrapper arrayFromDict: self.localRecentVisitItems[@"_dicts"]][indexPath.row] type: RecordTypeRecentlyVisit ofIdentity: self.localRecentVisitItems[@"_userId"]];
			[tableView deleteRowsAtIndexPaths: @[indexPath] withRowAnimation: UITableViewRowAnimationLeft];
			[tableView reloadSectionIndexTitles];
			[tableView endUpdates];
		}
		
	}];
	
	return @[delete];
	/*
	UITableViewRowAction *insert = [UITableViewRowAction rowActionWithStyle: UITableViewRowActionStyleDefault title: @"Insert" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
		
		action.backgroundColor = [UIColor blueColor];
		
		DynamoService *dynamoService = [DynamoService new];
		if (indexPath.section == 0) {
			[dynamoService addOfflineBookmark: nil ofIdentity: self.localBookmark[@"_userId"]];
			
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
		
		NSArray *comics = [DSWrapper arrayFromDict: self.remoteBookmark[@"_dicts"]];
    NSDictionary *bk = comics[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat: @"%@, %@, %@", bk[@"comicName"], bk[@"author"], bk[@"url"]];
		
	} else if (indexPath.section == 2)  {
		
		NSArray *bks = [DSWrapper arrayFromDict: self.localRecentVisitItems[@"_dicts"]];
		NSDictionary *bk = bks[indexPath.row];
		//NSDictionary *bk = self.localBookmark[@"_dicts"][indexPath.row];
		
		cell.textLabel.text = [NSString stringWithFormat: @"%@, %@, %@", bk[@"comicName"], bk[@"author"], bk[@"url"]];
		
	} else if (indexPath.section == 3)  {
    
    NSArray *comics = [DSWrapper arrayFromDict: self.remoteRecentVisitItems[@"_dicts"]];
    NSDictionary *bk = comics[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat: @"%@, %@, %@", bk[@"comicName"], bk[@"author"], bk[@"url"]];
  }
	return cell;
}

@end
