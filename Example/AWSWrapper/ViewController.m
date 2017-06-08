//
//  ViewController.m
//  LoginManager
//
//  Created by Stan Liu on 16/03/2017.
//  Copyright © 2017 Stan Liu. All rights reserved.
//

#import "ViewController.h"
#import "DynamoDBVC.h"
@import AWSWrapper;

@interface ViewController () <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource> {
  
  __weak IBOutlet UITableView *_tableView;
  __weak IBOutlet UITableView *_userTable;
}

@property (weak, nonatomic) IBOutlet UILabel *identityLabel;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UITextField *nameTF;
@property (weak, nonatomic) IBOutlet UILabel *checkLoginLabel;

@property NSString *currentUser;
@property NSArray *userList;

@property NSDictionary *localBookmark;
@property NSDictionary *remoteBookmark;
@property NSDictionary *localRecentVisitItems;
@property NSDictionary *remoteRecentVisitItems;

@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	__weak ViewController *weakSelf = self;
	
	[LoginManager shared].AWSLoginStatusChangedHandler = ^{
		[weakSelf refreshLoginStatusThroughNotification];
	};
	
	self.nameTF.delegate = self;
	
	[SyncManager shared];
	
	[self refreshLoginStatusThroughNotification];
  
  _tableView.delegate = self;
  _tableView.dataSource = self;
  
  [_tableView registerClass: [UITableViewCell class] forCellReuseIdentifier: @"cell"];
  
  _userTable.delegate = self;
  _userTable.dataSource = self;
  
  [_userTable registerClass: [UITableViewCell class] forCellReuseIdentifier: @"usercell"];
  
  self.userList = [NSArray array];
  self.currentUser = @"";
}

-(void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear: animated];
  
  [self reloadBookmarks];
  [self reloadRecentlyVisit];
}

-(void)refreshLoginStatusThroughNotification {
	
	NSLog(@"notification log in || out");
	
	if ([LoginManager shared].isAWSLogin || [LoginManager shared].isLogin) {
		
		[self.loginBtn setTitle: @"Logout" forState: UIControlStateNormal];
		self.identityLabel.text = [LoginManager shared].awsIdentityId;
		self.usernameLabel.text = [LoginManager shared].user;
	} else {
		[self.loginBtn setTitle: @"Login" forState: UIControlStateNormal];
		self.identityLabel.text = @"";
		self.usernameLabel.text = @"";
	}
	
	_checkLoginLabel.text = [NSString stringWithFormat:@"status offline: %@, remote: %@", ([LoginManager shared].isLogin) ? @"YES" : @"NO" , ([LoginManager shared].isAWSLogin) ? @"YES" : @"NO"];
}

- (IBAction)log:(id)sender {
	
	if ([LoginManager shared].isAWSLogin) {
		
		[[LoginManager shared] logout:^(id result, NSError *error) {
			if (!error) {
				NSLog(@"log out result: %@", result);
			}
			NSLog(@"logout error: %@", error);
		}];
		
	} else if ([LoginManager shared].isAWSLogin || [LoginManager shared].isLogin) {
 
		[[LoginManager shared] logoutOfflineCompletion:^(NSError *error) {
			
		}];
	
	} else {
    
    NSBundle *podBundle = [NSBundle bundleForClass: [SignInViewController class]];
    NSURL *url = [podBundle URLForResource: @"Resources" withExtension: @"bundle"];
    NSBundle *resourceBundle = [NSBundle bundleWithURL: url];
    
		UIStoryboard *signinSB = [UIStoryboard storyboardWithName: @"SignIn" bundle: resourceBundle];
		SignInViewController *signinVC = [signinSB instantiateViewControllerWithIdentifier: NSStringFromClass([SignInViewController class])];
		
		[self.navigationController pushViewController: signinVC animated: true];
	}
}

- (IBAction)load:(id)sender {
	
	NSArray *userList = [[NSUserDefaults standardUserDefaults] arrayForKey: @"__USER_LIST"];
	NSString *currentUser = [[NSUserDefaults standardUserDefaults] stringForKey: @"__CURRENT_USER"];
  self.currentUser = currentUser;
  self.userList = userList;
  
  dispatch_async(dispatch_get_main_queue(), ^{
    [_userTable reloadData];
  });
  
	
	[self refreshLoginStatusThroughNotification];
  
  [self reloadBookmarks];
  [self reloadRecentlyVisit];
}


- (IBAction)save:(id)sender {
	
	// Save local
 NSDictionary *bookmark = @{@"comicName": self.nameTF.text, @"author": self.nameTF.text, @"url": self.nameTF.text};
	
	if ([LoginManager shared].isLogin) {
		
		[[BookmarkManager new] addOffline: bookmark type: RecordTypeBookmark ofIdentity: [LoginManager shared].awsIdentityId];
	}

  [[BookmarkManager new] mergePushType: RecordTypeBookmark userId: [LoginManager shared].awsIdentityId completion:^(NSDictionary *responseItem, NSError *error) {
    
    if (error) {
      NSLog(@"error: %@", error);
      return;
    }
    [self reloadBookmarks];
  }];
}

- (IBAction)saveRecentlyVisit:(id)sender {
	
	// Save local
 NSDictionary *recentlyVisit = @{@"comicName": self.nameTF.text, @"author": self.nameTF.text, @"url": self.nameTF.text};
	
	if ([LoginManager shared].isLogin) {
		
		[[BookmarkManager new] addOffline: recentlyVisit type: RecordTypeRecentlyVisit ofIdentity: [LoginManager shared].awsIdentityId];
		
	}
  [[BookmarkManager new] mergePushType: RecordTypeRecentlyVisit userId:[LoginManager shared].awsIdentityId completion:^(NSDictionary *responseItem, NSError *error) {
    
    if (error) {
      NSLog(@"error: %@", error);
      return;
    }
    [self reloadRecentlyVisit];
  }];
}

- (IBAction)syncRemote:(id)sender {
	
	//[[SyncManager shared] startLoginFlow];
  NSString *userId = [LoginManager shared].awsIdentityId;
  [[BookmarkManager new] mergePushType: RecordTypeBookmark userId: userId completion:^(NSDictionary *responseItem, NSError *error) {
    
    dispatch_sync(dispatch_get_main_queue(), ^{
      [self reloadBookmarks];
    });
  }];
  [[BookmarkManager new] mergePushType: RecordTypeRecentlyVisit userId: userId completion:^(NSDictionary *responseItem, NSError *error) {
    
    dispatch_sync(dispatch_get_main_queue(), ^{
      [self reloadRecentlyVisit];
    });
  }];
}


-(void)reloadBookmarks {
  
  BookmarkManager *bookmarkManager = [BookmarkManager new];
  LoginManager *loginManager = [LoginManager shared];
  NSString *userId = loginManager.awsIdentityId != nil ? loginManager.awsIdentityId : loginManager.offlineIdentity;
  NSDictionary *localBookmarkRecord = [bookmarkManager getOfflineRecordOfIdentity: userId type: RecordTypeBookmark];
  
  self.localBookmark = localBookmarkRecord;
  dispatch_async(dispatch_get_main_queue(), ^{
    [_tableView reloadData];
  });
  
  if ([LoginManager shared].awsIdentityId) {
    [bookmarkManager pullType: RecordTypeBookmark user: loginManager.awsIdentityId completion:^(NSDictionary *item, NSError *error) {
      
      dispatch_async(dispatch_get_main_queue(), ^{
        
        self.remoteBookmark = item;
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
  
  dispatch_async(dispatch_get_main_queue(), ^{
    [_tableView reloadData];
  });
  
  if ([LoginManager shared].awsIdentityId) {
    
    [bookmarkManager pullType: RecordTypeRecentlyVisit user: loginManager.awsIdentityId completion:^(NSDictionary *item, NSError *error) {
      
      dispatch_async(dispatch_get_main_queue(), ^{
        
        self.remoteRecentVisitItems = item;
        [_tableView reloadSections: [NSIndexSet indexSetWithIndex: 3] withRowAnimation: UITableViewRowAnimationNone];
      });
    }];
  }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
	
	[textField resignFirstResponder];
	return true;
}

// MARK: TableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  
  if (tableView == _userTable) {
    return 2;
  }
  return 4;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  
  if (tableView == _userTable) {
    switch (section) {
      case 0:
        return 1;
        break;
      default:
        return self.userList.count;
    }
  }
  
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
  
  if (tableView == _userTable) {
    switch (section) {
      case 0:
        return @"current";
        break;
      default:
        return @"user list";
    }
  }
  
  if (section == 0) {
    return [NSString stringWithFormat:@"Local B count %lu- %@", (unsigned long)[(NSArray *)self.localBookmark[@"_dicts"] count], [self.localBookmark[@"_commitId"] substringWithRange: NSMakeRange(((NSString *)self.localBookmark[@"_commitId"]).length - 10, 10)]];
  } else if (section == 1) {
    return [NSString stringWithFormat:@"Remote B count %lu- %@", (unsigned long)[(NSArray *)self.remoteBookmark[@"_dicts"] count], [self.remoteBookmark[@"_commitId"] substringWithRange: NSMakeRange(((NSString *)self.remoteBookmark[@"_commitId"]).length - 10, 10)]];
    
  } else if (section == 2) {
    return [NSString stringWithFormat:@"Local R count %lu- %@", (unsigned long)[(NSArray *)self.localRecentVisitItems[@"_dicts"] count], [self.localRecentVisitItems[@"_commitId"] substringWithRange: NSMakeRange(((NSString *)self.localRecentVisitItems[@"_commitId"]).length - 10, 10)]];
  } else if (section == 3) {
    return [NSString stringWithFormat:@"Remote R count %lu- %@", (unsigned long)[(NSArray *)self.remoteRecentVisitItems[@"_dicts"] count], [self.remoteRecentVisitItems[@"_commitId"] substringWithRange: NSMakeRange(((NSString *)self.remoteRecentVisitItems[@"_commitId"]).length - 10, 10)]];
  }
  return @"";
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
  
  if (tableView == _userTable) {
    return NO;
  }
  
  return indexPath.section % 2 == 0 ? YES : NO;
}

-(NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  UITableViewRowAction *delete = [UITableViewRowAction rowActionWithStyle: UITableViewRowActionStyleDefault title: @"Delete" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
    
    BookmarkManager *bookmarkManager = [BookmarkManager new];
    
    if (indexPath.section == 0) {
      
      [tableView beginUpdates];
      self.localBookmark = [bookmarkManager deleteOffline: [DSWrapper arrayFromDict: self.localBookmark[@"_dicts"]][indexPath.row] type: RecordTypeBookmark ofIdentity: self.localBookmark[@"_userId"]];
      [tableView deleteRowsAtIndexPaths: @[indexPath] withRowAnimation: UITableViewRowAnimationLeft];
      [tableView reloadSectionIndexTitles];
      [tableView endUpdates];
      
    } else if (indexPath.section == 2) {
      
      [tableView beginUpdates];
      self.localRecentVisitItems = [bookmarkManager deleteOffline: [DSWrapper arrayFromDict: self.localRecentVisitItems[@"_dicts"]][indexPath.row] type: RecordTypeRecentlyVisit ofIdentity: self.localRecentVisitItems[@"_userId"]];
      [tableView deleteRowsAtIndexPaths: @[indexPath] withRowAnimation: UITableViewRowAnimationLeft];
      [tableView reloadSectionIndexTitles];
      [tableView endUpdates];
    }
    
  }];
  
  return @[delete];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  if (tableView == _userTable) {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"usercell"];
    if (!cell) {
      cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleSubtitle reuseIdentifier: @"cell"];
    }
    
    switch (indexPath.section) {
      case 0:
        cell.textLabel.text = self.currentUser;
        cell.detailTextLabel.text = [LoginManager shared].awsIdentityId;
        return cell;
        break;
      default: {
        
        NSDictionary *user = self.userList[indexPath.row];
        cell.textLabel.text = user[@"_userId"];
        cell.detailTextLabel.text = [NSString stringWithFormat: @"user: %@, password: %@", user[@"_user"], user[@"_password"]];
        return cell;
      }
    }
    
    return cell;
  }
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"cell"];
  
  if (!cell) {
    cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleSubtitle reuseIdentifier: @"cell"];
  }
  
  if (indexPath.section == 0) {
    
    NSArray *bks = [DSWrapper arrayFromDict: self.localBookmark[@"_dicts"]];
    NSDictionary *bk = bks[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat: @"%@, %@, %@", bk[@"comicName"], bk[@"author"], bk[@"url"]];
    
  } else if (indexPath.section == 1) {
    
    NSArray *comics = [DSWrapper arrayFromDict: self.remoteBookmark[@"_dicts"]];
    NSDictionary *bk = comics[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat: @"%@, %@, %@", bk[@"comicName"], bk[@"author"], bk[@"url"]];
    
  } else if (indexPath.section == 2)  {
    
    NSArray *bks = [DSWrapper arrayFromDict: self.localRecentVisitItems[@"_dicts"]];
    NSDictionary *bk = bks[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat: @"%@, %@, %@", bk[@"comicName"], bk[@"author"], bk[@"url"]];
    
  } else if (indexPath.section == 3)  {
    
    NSArray *comics = [DSWrapper arrayFromDict: self.remoteRecentVisitItems[@"_dicts"]];
    NSDictionary *bk = comics[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat: @"%@, %@, %@", bk[@"comicName"], bk[@"author"], bk[@"url"]];
  }
  return cell;
}



@end
