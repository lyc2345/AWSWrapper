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

@interface ViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *identityLabel;

@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;

@property (weak, nonatomic) IBOutlet UITextField *nameTF;

@property (weak, nonatomic) IBOutlet UITextView *console;
@property (weak, nonatomic) IBOutlet UITextView *userHistoryConsole;
@property (weak, nonatomic) IBOutlet UILabel *checkLoginLabel;

@property (strong, nonatomic) NSArray *textfields;

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
	
	self.textfields = @[self.nameTF];
	
	for (UITextField *tf in self.textfields) {
		tf.text = @"a";
	}
	
	[self refreshLoginStatusThroughNotification];
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

-(void)print:(NSArray *)bookmarks {
	
	NSMutableString *log = [NSMutableString string];
	
	[bookmarks enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		
		NSDictionary *dict = bookmarks[idx];
		[log appendString: @"{ \n"];
		[log appendString: [NSString stringWithFormat: @"  \"comicName\": \"%@\",", dict[@"comicName"]]];
		[log appendString: [NSString stringWithFormat: @"  \"author\": \"%@\",", dict[@"author"]]];
		[log appendString: [NSString stringWithFormat: @"  \"url\": \"%@\",", dict[@"url"]]];
		[log appendString: @"\n }, \n"];
	}];
	
	NSLog(@"bookmarks: %@", log);
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
	
	NSDictionary *userBookmark = [[BookmarkManager new] getOfflineRecordOfIdentity: [LoginManager shared].awsIdentityId type: RecordTypeBookmark];
	self.console.text = [NSString stringWithFormat:@"%@", userBookmark];
	
	
	NSArray *userList = [[NSUserDefaults standardUserDefaults] arrayForKey: @"__USER_LIST"];
	NSString *currentUser = [[NSUserDefaults standardUserDefaults] stringForKey: @"__CURRENT_USER"];
	self.userHistoryConsole.text = [NSString stringWithFormat:@"current: %@,\n list: %@", currentUser, userList];
	
	[self refreshLoginStatusThroughNotification];
}


- (IBAction)save:(id)sender {
	
	// Save local
 NSDictionary *bookmark = @{@"comicName": self.nameTF.text, @"author": self.nameTF.text, @"url": self.nameTF.text};
	
	if ([LoginManager shared].isLogin) {
		
		[[BookmarkManager new] addOffline: bookmark type: RecordTypeBookmark ofIdentity: [LoginManager shared].awsIdentityId];
	}
	Bookmark *bk = [Bookmark new];
	bk._id = [LoginManager shared].awsIdentityId;
	bk._userId = [LoginManager shared].awsIdentityId;
	NSDictionary *record = [[BookmarkManager new] getOfflineRecordOfIdentity: [LoginManager shared].awsIdentityId type: RecordTypeBookmark];
	
	bk._dicts = record[@"_dicts"];
	bk._remoteHash = record[@"_remoteHash"];
	bk._commitId = record[@"_commitId"];
	
	[[BookmarkManager new] mergePushWithRecord: bk type: RecordTypeBookmark completion:^(NSError *error) {
		
		if (error) {
			NSLog(@"error: %@", error);
			return;
		}
	}];
}

- (IBAction)delete:(id)sender {
	
	NSDictionary *bookmarkToBeDeleted = @{@"comicName": self.nameTF.text, @"author": self.nameTF.text, @"url": self.nameTF.text};

	if ([LoginManager shared].isLogin) {
		
		[[BookmarkManager new] deleteOffline: bookmarkToBeDeleted type: RecordTypeBookmark ofIdentity: [LoginManager shared].awsIdentityId];
	}
}

- (IBAction)saveRecentlyVisit:(id)sender {
	
	// Save local
 NSDictionary *recentlyVisit = @{@"comicName": self.nameTF.text, @"author": self.nameTF.text, @"url": self.nameTF.text};
	
	if ([LoginManager shared].isLogin) {
		
		[[BookmarkManager new] addOffline: recentlyVisit type: RecordTypeRecentlyVisit ofIdentity: [LoginManager shared].awsIdentityId];
		
	}
	RecentVisit *rv = [RecentVisit new];
	rv._id = [LoginManager shared].awsIdentityId;
	rv._userId = [LoginManager shared].awsIdentityId;
	NSDictionary *record = [[BookmarkManager new] getOfflineRecordOfIdentity: [LoginManager shared].awsIdentityId type: RecordTypeRecentlyVisit];
	
	rv._dicts = record[@"_dicts"];
	rv._remoteHash = record[@"_remoteHash"];
	rv._commitId = record[@"_commitId"];
	
	[[BookmarkManager new] mergePushWithRecord: rv type: RecordTypeRecentlyVisit completion:^(NSError *error) {
		
		if (error) {
			NSLog(@"error: %@", error);
			return;
		}
	}];
}


- (IBAction)clear:(id)sender {

	for (UITextField *tf in self.textfields) {

			[tf setText: @""];
	}
}

- (IBAction)syncRemote:(id)sender {
	
	[[SyncManager shared] startLoginFlow];
}

- (IBAction)browseDataOfUser:(id)sender {
	
	DynamoDBVC *dbVC = [self.storyboard instantiateViewControllerWithIdentifier: @"DynamoDBVC"];
	[self.navigationController pushViewController: dbVC animated: true];
}

- (IBAction)logRecentData:(id)sender {
	
	[[BookmarkManager new] pull: [RecentVisit class] withUser: [LoginManager shared].awsIdentityId completion:^(NSArray *items, NSError *error) {
		
		NSLog(@"recent data: %@", items);
		dispatch_async(dispatch_get_main_queue(), ^{
			self.console.text = [NSString stringWithFormat:@"%@", items];
		});
	}];
}

- (IBAction)logBookmark:(id)sender {
	
	[[BookmarkManager new] pull: [Bookmark class] withUser: [LoginManager shared].awsIdentityId completion:^(NSArray *items, NSError *error) {
		
		NSLog(@"recent data: %@", items);
		dispatch_async(dispatch_get_main_queue(), ^{
				self.console.text = [NSString stringWithFormat:@"%@", items];
		});
		
	}];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
	
	[textField resignFirstResponder];
	return true;
}

@end
