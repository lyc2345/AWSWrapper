//
//  SyncManager.m
//  LoginManager
//
//  Created by Stan Liu on 06/04/2017.
//  Copyright © 2017 Stan Liu. All rights reserved.
//

#import "SyncManager.h"
#import "LoginManager.h"
#import "BookmarkManager.h"
#import "Bookmark.h"
#import "RecentVisit.h"

#import "AFNetworking.h"


@implementation SyncManager

+(SyncManager *)shared {
	
	static SyncManager *manager;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		
		manager = [[SyncManager alloc] init];
	});
	
	return manager;
}

- (instancetype)init
{
	self = [super init];
	if (self) {
		
		[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(networkChanged:) name: AFNetworkingReachabilityDidChangeNotification object: nil];
	}
	return self;
}

-(void)networkChanged:(NSNotification *)notify {
	
	NSLog(@"SyncManager detect network changed, status: %@", notify.userInfo);
	NSValue *networkStatus = notify.userInfo[@"AFNetworkingReachabilityNotificationStatusItem"];
	
	if (![AFNetworkReachabilityManager sharedManager].isReachable || networkStatus == 0) {
		return;
	}
	
	//[self startLoginFlow];
}

-(void)startLoginFlow {
	
	bool isAWSLogin = [LoginManager shared].isAWSLogin;
	bool isOfflineLogin = [LoginManager shared].isLogin;

	if (isAWSLogin && isOfflineLogin) {
		// scenario 1: both login
		// don't need to do anything.
		
	} else if (isOfflineLogin && !isAWSLogin) {
		// scenario 2: offline login, AWS not login
		[[LoginManager shared] login:^(id result, NSError *error) {
			
			if (error) {
				NSLog(@"SyncManager scenario 2 AWS login failure, cuase error: %@", error);
				return;
			}
			// AWS login success and continure to Data flow
			// [self startSyncDataFlow];
		}];
		
	} else if (!isOfflineLogin && isAWSLogin) {
		// scenario 3: offline not login, AWS login
		// do AWS logout
		
		[[LoginManager shared] logout:^(id result, NSError *error) {
			
			if (error) {
				NSLog(@"SyncManager scenario 3 AWS logout failure, cuase error: %@", error);
				return;
			}
			// AWS logout success
			return;
		}];
		
	} else {
		// scenario 4: both not login
		// don't need to do anything.
		return;
	}
	
	[self startSyncDataFlow];
}

-(void)startSyncDataFlow {

	NSString *userId = [LoginManager shared].awsIdentityId;
	[self bookmarkConditionallySyncFlowWithUserId: userId];
}

-(void)bookmarkConditionallySyncFlowWithUserId:(NSString *)userId {
	
	BookmarkManager *bookmarkManager = [BookmarkManager new];
	NSDictionary *localBookmarkRecord = [bookmarkManager getOfflineRecordOfIdentity: userId type: RecordTypeBookmark];

	Bookmark *clientBookmark = [Bookmark new];
	clientBookmark._id = userId;
	clientBookmark._userId = userId;
	clientBookmark._dicts = localBookmarkRecord[@"_dicts"];
	clientBookmark._commitId = localBookmarkRecord[@"_commitId"];
	clientBookmark._remoteHash = localBookmarkRecord[@"_remoteHash"];
	
	[bookmarkManager mergePushWithRecord: clientBookmark type: RecordTypeBookmark completion:^(NSError *error) {
		
		if (error) {
			NSLog(@"SyncManager mergePush error: %@", error);
			return;
		}
	}];
}



-(void)recentlyVisitSyncFlowWithUserId:(NSString *)userId {
	/*
	BookmarkManager *bkManager = [BookmarkManager new];
	[bkManager loadRecentlyVisitInAWSOFfUser: userId completion:^(NSArray *items, NSError *error) {
		
		if (!error) {
			
			NSLog(@"remote recently visit items: %@", items);
			
			RecentVisit *remoteRecentlyVisitRecord = items.firstObject;
			double remotecommitId = [remoteRecentlyVisitRecord._commitId doubleValue];
			
			NSDictionary *localRecentlyVisitRecord = [bkManager loadOfflineRecentlyVisitOfIdentity: userId];
			
			double localcommitId = [localRecentlyVisitRecord[@"_commitId"] doubleValue];
			
			// do diff
			// compare timestamp
			if (!localcommitId || remotecommitId > localcommitId) {
				
				// case: 1
				// local has no record, see remote is the first priority
				// save remote to local
				
				// case: 2
				// remote update is newer than local
				// pull
				NSArray *remoteRecentlyVisitList = remoteRecentlyVisitRecord._dicts;
				// diff client_shadow and remote_shadow
				// this case alwasys see remote at the first place.
				// save local
				[bkManager saveOfflineRecentlyVisitList: remoteRecentlyVisitList OfIdentity: userId at: remoteRecentlyVisitRecord._commitId];
				
				NSLog(@"remote update is newer than local");
				
			} else if (remotecommitId < localcommitId) {
				
				// local update is newer than remote
				// diff
				NSArray *localRecentlyVisitList = localRecentlyVisitRecord[@"_dicts"];
				// push
				[bkManager saveRecentlyVisits: localRecentlyVisitList inAWSOfUser: userId time:localcommitId completion:^(NSError *error) {
					
					if (!error) {
						NSLog(@"Local sync remote success, see local list as first place");
					}
				}];
				NSLog(@"Recently Visit: remote update is newer than local");
				
			} else {
				
				// equal
				// do nothing
				NSLog(@"other situation, maybe remote is equal local");
			}

		}
	}];
	 */
}


-(void)bookmarkSyncFlowWithUser:(NSString *)user {
	/*
	BookmarkManager *bkManager = [BookmarkManager new];
	[bkManager loadBookmarkInAWSOFfUser: user completion:^(NSArray *items, NSError *error) {
		
		if (!error) {
			
			NSLog(@"remote bookmark items: %@", items);
			
			Bookmark *remoteBookmarkRecord = items.firstObject;
			double remotecommitId = [remoteBookmarkRecord._commitId doubleValue];
			
			NSDictionary *localBookmarkRecord = [bkManager loadOfflineBookmarkOfIdentity: [LoginManager shared].awsIdentityId];
			
			double localcommitId = [localBookmarkRecord[@"_commitId"] doubleValue];
			
			// do diff
			// compare timestamp
			if (!localcommitId || remotecommitId > localcommitId) {
				
				// case: 1
				// local has no record, see remote is the first priority
				// save remote to local
				
				// case: 2
				// remote update is newer than local
				// pull
				NSArray *remoteBookmarkList = remoteBookmarkRecord._lists;
				// diff client_shadow and remote_shadow
				// this case alwasys see remote at the first place.
				// save local
				[bkManager saveOfflineBookmarkList: remoteBookmarkList ofIdentity: user at: remoteBookmarkRecord._commitId];
				
				NSLog(@"remote update is newer than local");
				
			} else if (remotecommitId < localcommitId) {
				
				// local update is newer than remote
				// diff
				NSArray *localBookmarkList = localBookmarkRecord[@"_dicts"];
				// push
				[bkManager conditionallyWriteInAWSWithBookmarkList: localBookmarkList WithUser: [LoginManager shared].awsIdentityId expectedAt: remotecommitId completion:^(NSError *error) {
					
					if (!error) {
						NSLog(@"Local sync remote success, see local list as first place");
					}
					
				}];
				
				[bkManager saveBookmarks: localBookmarkList inAWSOfUser: [LoginManager shared].awsIdentityId time: localcommitId completion:^(NSError *error) {
					
					if (!error) {
						NSLog(@"Local sync remote success, see local list as first place");
					}
				}];
				
				NSLog(@"Bookmark: remote update is newer than local");
				
			} else {
				
				// equal
				// do nothing
				NSLog(@"other situation, maybe remote is equal local");
			}
		}
	}];*/
}

@end
