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
#import "DetailVC.h"

@interface ViewController () <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, DynamoSyncDelegate> {
  
  __weak IBOutlet UITableView *_tableView;
  __weak IBOutlet UITableView *_userTable;
  
  DynamoSync *_dsync;
}

@property (weak, nonatomic) IBOutlet UILabel *identityLabel;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UITextField *nameTF;
@property (weak, nonatomic) IBOutlet UITextField *authorTF;
@property (weak, nonatomic) IBOutlet UITextField *urlTF;

@property (weak, nonatomic) IBOutlet UILabel *checkLoginLabel;

@property (strong, nonatomic) OfflineDB *offlineDB;
@property (strong, nonatomic) OfflineCognito *offlineCognito;

@property NSString *currentUser;
@property NSArray *userList;

@property NSDictionary *localBookmark;
@property NSDictionary *remoteBookmark;
@property NSDictionary *localHistoryItems;
@property NSDictionary *remoteHistoryItems;

@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	__weak ViewController *weakSelf = self;
	
	[LoginManager shared].AWSLoginStatusChangedHandler = ^{
		[weakSelf refreshLoginStatusThroughNotification];
	};
	
	self.nameTF.delegate = self;
  self.authorTF.delegate = self;
  self.urlTF.delegate = self;
	
	[self refreshLoginStatusThroughNotification];
  
  _tableView.delegate = self;
  _tableView.dataSource = self;
  
  _userTable.delegate = self;
  _userTable.dataSource = self;
  
  self.currentUser = @"";
  
  self.offlineDB = [OfflineDB new];
  self.offlineCognito = [OfflineCognito new];
  
  NSArray *userlist = [[NSUserDefaults standardUserDefaults] arrayForKey: @"__OFFLINE_USER_LIST"];
  if (userlist) {
    self.userList = userlist;
  } else {
    self.userList = [NSArray array];
  }
  
  
  _dsync = [[DynamoSync alloc] init];
  _dsync.delegate = self;
}

-(void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear: animated];
  

  [self load: nil];
}

-(void)refreshLoginStatusThroughNotification {
	
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
		
	} else if ([LoginManager shared].isLogin) {
 
    [[LoginManager shared] logout:^(id result, NSError *error) {
      
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
	
  NSArray *userList = [[NSUserDefaults standardUserDefaults] arrayForKey: @"__OFFLINE_USER_LIST"];
	NSString *currentUser = [[NSUserDefaults standardUserDefaults] stringForKey: @"__CURRENT_USER"];
  self.currentUser = currentUser;
  self.userList = userList;
  
  dispatch_async(dispatch_get_main_queue(), ^{
    [_userTable reloadData];
  });
	
	[self refreshLoginStatusThroughNotification];
  
  [self reloadBookmarks];
  [self reloadHistory];
}


- (IBAction)save:(id)sender {
	
	// Save local
 NSDictionary *bookmark = @{@"comicName": self.nameTF.text, @"author": [NSString stringWithFormat: @"author %@", self.authorTF.text], @"url": [NSString stringWithFormat: @"http://www.wikipedia/%@", self.urlTF.text]};
  //NSDictionary *bookmark = @{@"comicName": self.nameTF.text, @"author": self.nameTF.text, @"url": self.nameTF.text};
	
	if ([LoginManager shared].isLogin) {
		
		[self.offlineDB addOffline: bookmark type: RecordTypeBookmark ofIdentity: [LoginManager shared].awsIdentityId];
    
    NSDictionary *localBookmarkRecord = [self.offlineDB getOfflineRecordOfIdentity: [LoginManager shared].offlineIdentity type: RecordTypeBookmark];
    
    self.localBookmark = localBookmarkRecord;
    dispatch_async(dispatch_get_main_queue(), ^{
      [_tableView reloadData];
    });
	}
}

- (IBAction)saveHistory:(id)sender {
	
	// Save local
 NSDictionary *history = @{@"comicName": self.nameTF.text, @"author": self.nameTF.text, @"url": self.nameTF.text};
	
	if ([LoginManager shared].isLogin) {
		
		[self.offlineDB addOffline: history type: RecordTypeHistory ofIdentity: [LoginManager shared].awsIdentityId];
	}
}

- (IBAction)syncRemote:(id)sender {
	
  NSString *userId = [LoginManager shared].awsIdentityId;
  NSDictionary *bk = [self.offlineDB getOfflineRecordOfIdentity: userId type: RecordTypeBookmark];
  [_dsync syncWithUserId: userId
               tableName: @"Bookmark"
              dictionary: bk
                  shadow: [OfflineDB shadowIsBookmark: YES ofIdentity: userId]
           shouldReplace:^BOOL(id oldValue, id newValue) {
             
             
             NSLog(@"old: %@, new: %@", oldValue, newValue);
             
             return YES;
             
             
           } completion:^(NSDictionary *diff, NSError *error) {
             [self reloadBookmarks];
           }];
}

- (IBAction)syncRecently:(id)sender {
  
  NSString *userId = [LoginManager shared].awsIdentityId;
  NSDictionary *rv = [self.offlineDB getOfflineRecordOfIdentity: userId type: RecordTypeHistory];
  [_dsync syncWithUserId: userId
               tableName: @"History"
              dictionary: rv
                  shadow: [OfflineDB shadowIsBookmark: NO ofIdentity: userId]
           shouldReplace:^BOOL(id oldValue, id newValue) {
             return YES;
           } completion:^(NSDictionary *diff, NSError *error) {
             [self reloadHistory];
           }];
}

-(void)reloadBookmarks {
  
  DynamoService *dynamoService = [DynamoService new];
  LoginManager *loginManager = [LoginManager shared];
  NSString *userId = loginManager.awsIdentityId != nil ? loginManager.awsIdentityId : loginManager.offlineIdentity;
  NSDictionary *localBookmarkRecord = [self.offlineDB getOfflineRecordOfIdentity: userId type: RecordTypeBookmark];
  
  self.localBookmark = localBookmarkRecord;
  dispatch_async(dispatch_get_main_queue(), ^{
    [_tableView reloadData];
  });
  
  if ([LoginManager shared].awsIdentityId) {
    [dynamoService pullType: RecordTypeBookmark user: loginManager.awsIdentityId completion:^(NSDictionary *item, NSError *error) {
      
      dispatch_async(dispatch_get_main_queue(), ^{
        
        self.remoteBookmark = item;
        [_tableView reloadSections: [NSIndexSet indexSetWithIndex: 1] withRowAnimation: UITableViewRowAnimationNone];
      });
    }];
  }
}

-(void)reloadHistory {
  
  DynamoService *dynamoService = [DynamoService new];
  LoginManager *loginManager = [LoginManager shared];
  NSString *userId = loginManager.awsIdentityId != nil ? loginManager.awsIdentityId : loginManager.offlineIdentity;
  NSDictionary *localHistory = [self.offlineDB getOfflineRecordOfIdentity: userId type: RecordTypeHistory];
  
  self.localHistoryItems = localHistory;
  
  dispatch_async(dispatch_get_main_queue(), ^{
    [_tableView reloadData];
  });
  
  if ([LoginManager shared].awsIdentityId) {
    
    [dynamoService pullType: RecordTypeHistory user: loginManager.awsIdentityId completion:^(NSDictionary *item, NSError *error) {
      
      dispatch_async(dispatch_get_main_queue(), ^{
        
        self.remoteHistoryItems = item;
        [_tableView reloadSections: [NSIndexSet indexSetWithIndex: 3] withRowAnimation: UITableViewRowAnimationNone];
      });
    }];
  }
}

// MARK: DynamoSyncDelegate

-(void)dynamoPushSuccessWithType:(RecordType)type data:(NSDictionary *)data newCommitId:(NSString *)commitId {
  
  [self.offlineDB pushSuccessThenSaveLocalRecord: data type: type newCommitId: commitId];
}

-(id)emptyShadowIsBookmark:(BOOL)isBookmark ofIdentity:(NSString *)identity {
  
  [OfflineDB setShadow: @{} isBookmark: isBookmark ofIdentity: identity];
  return [OfflineDB shadowIsBookmark: isBookmark ofIdentity: identity];
}

// MARK: TextFieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
	
	[textField resignFirstResponder];
	return true;
}

// MARK: TableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  
  if (tableView == _userTable && indexPath.section == 1) {
    
    NSDictionary *user = self.userList[indexPath.row];
    
    DetailVC *detailVC = [self.storyboard instantiateViewControllerWithIdentifier: NSStringFromClass([DetailVC class])];
    UINavigationController *navi = self.navigationController;
    detailVC.t = [NSString stringWithFormat: @"identityId: %@", user[@"_identityId"]];
    detailVC.c = [NSString stringWithFormat:@"username: %@", user[@"_username"]];
    [navi showViewController: detailVC sender: nil];
  }
}

// MARK: TableViewDataSource
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
    return [(NSArray *)self.localHistoryItems[@"_dicts"] count];
  } else if (section == 3){
    return [(NSArray *)self.remoteHistoryItems[@"_dicts"] count];
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
    return [NSString stringWithFormat:@"LB c:%lu- %@, rh: %@", (unsigned long)[(NSArray *)self.localBookmark[@"_dicts"] count],
            [self.localBookmark[@"_commitId"] substringWithRange: NSMakeRange(((NSString *)self.localBookmark[@"_commitId"]).length - 10, 10)], [self.localBookmark[@"_remoteHash"] substringWithRange: NSMakeRange(((NSString *)self.localBookmark[@"_remoteHash"]).length - 10, 10)]];
  } else if (section == 1) {
    return [NSString stringWithFormat:@"RB c:%lu- %@, rh: %@", (unsigned long)[(NSArray *)self.remoteBookmark[@"_dicts"] count], [self.remoteBookmark[@"_commitId"] substringWithRange: NSMakeRange(((NSString *)self.remoteBookmark[@"_commitId"]).length - 10, 10)],
      [self.remoteBookmark[@"_remoteHash"] substringWithRange: NSMakeRange(((NSString *)self.remoteBookmark[@"_remoteHash"]).length - 10, 10)]];
    
  } else if (section == 2) {
    return [NSString stringWithFormat:@"LR count %lu- %@", (unsigned long)[(NSArray *)self.localHistoryItems[@"_dicts"] count], [self.localHistoryItems[@"_commitId"] substringWithRange: NSMakeRange(((NSString *)self.localHistoryItems[@"_commitId"]).length - 10, 10)]];
  } else if (section == 3) {
    return [NSString stringWithFormat:@"RR count %lu- %@", (unsigned long)[(NSArray *)self.remoteHistoryItems[@"_dicts"] count], [self.remoteHistoryItems[@"_commitId"] substringWithRange: NSMakeRange(((NSString *)self.remoteHistoryItems[@"_commitId"]).length - 10, 10)]];
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
    
    if (indexPath.section == 0) {
      
      [tableView beginUpdates];
      self.localBookmark = [self.offlineDB deleteOffline: [DSWrapper arrayFromDict: self.localBookmark[@"_dicts"]][indexPath.row] type: RecordTypeBookmark ofIdentity: self.localBookmark[@"_userId"]];
      [tableView deleteRowsAtIndexPaths: @[indexPath] withRowAnimation: UITableViewRowAnimationLeft];
      [tableView reloadSectionIndexTitles];
      [tableView endUpdates];
      
    } else if (indexPath.section == 2) {
      
      [tableView beginUpdates];
      self.localHistoryItems = [self.offlineDB deleteOffline: [DSWrapper arrayFromDict: self.localHistoryItems[@"_dicts"]][indexPath.row] type: RecordTypeHistory ofIdentity: self.localHistoryItems[@"_userId"]];
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
    cell.textLabel.font = [UIFont systemFontOfSize: 10];
    cell.detailTextLabel.font = [UIFont systemFontOfSize: 8];
    
    switch (indexPath.section) {
      case 0:
        cell.textLabel.text = self.currentUser;
        cell.detailTextLabel.text = [LoginManager shared].awsIdentityId;
        return cell;
        break;
      default: {
        
        NSDictionary *user = self.userList[indexPath.row];
        cell.textLabel.text = user[@"_identityId"];
        cell.detailTextLabel.text = [NSString stringWithFormat: @"identityId: %@", user[@"_username"]];
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
    cell.textLabel.text = [NSString stringWithFormat: @"%@", bk[@"comicName"]];
    cell.detailTextLabel.text = [NSString stringWithFormat: @"%@, %@", bk[@"author"], bk[@"url"]];
    
  } else if (indexPath.section == 1) {
    
    NSArray *comics = [DSWrapper arrayFromDict: self.remoteBookmark[@"_dicts"]];
    NSDictionary *bk = comics[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat: @"%@", bk[@"comicName"]];
    cell.detailTextLabel.text = [NSString stringWithFormat: @"%@, %@", bk[@"author"], bk[@"url"]];
    
  } else if (indexPath.section == 2)  {
    
    NSArray *bks = [DSWrapper arrayFromDict: self.localHistoryItems[@"_dicts"]];
    NSDictionary *bk = bks[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat: @"%@", bk[@"comicName"]];
    cell.detailTextLabel.text = [NSString stringWithFormat: @"%@, %@", bk[@"author"], bk[@"url"]];
    
  } else if (indexPath.section == 3)  {
    
    NSArray *comics = [DSWrapper arrayFromDict: self.remoteHistoryItems[@"_dicts"]];
    NSDictionary *bk = comics[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat: @"%@", bk[@"comicName"]];
    cell.detailTextLabel.text = [NSString stringWithFormat: @"%@, %@", bk[@"author"], bk[@"url"]];
  }
  return cell;
}



@end
