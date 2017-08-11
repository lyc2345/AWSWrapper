//
//  AWSWrapper_MultipleUser.m
//  AWSWrapper_MultipleUser
//
//  Created by Stan Liu on 10/08/2017.
//  Copyright © 2017 lyc2345. All rights reserved.
//

#import "DynamoTestBase.h"
#import "DispatchQueue.h"
#import "Specta/Specta.h"
#import "Expecta/Expecta.h"
#import "LoginTestBase.h"
@import AWSWrapper;

@implementation OfflineDB (MultipleUsers)

-(NSArray *)bookmarkDB {
  return [[NSUserDefaults standardUserDefaults] arrayForKey: @"__TEST_BOOKMARKS"];
}

-(BOOL)setBookmarkDB:(NSArray *)records {
  [[NSUserDefaults standardUserDefaults] setObject: records forKey: @"__TEST_BOOKMARKS"];
  return [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSArray *)bookmarkShadowDB {
  return [[NSUserDefaults standardUserDefaults] arrayForKey: @"__TEST_BOOKMARKS_SHADOW"];
}

+(BOOL)setBookmarkShadow:(NSArray *)records {
  [[NSUserDefaults standardUserDefaults] setObject: records forKey: @"__TEST_BOOKMARKS_SHADOW"];
  return [[NSUserDefaults standardUserDefaults] synchronize];
}

@end

@implementation DynamoTestBase (MultipleUsers)

-(void)saveShadow:(NSDictionary *)dict
             type:(RecordType)type
         commitId:(NSString *)commitId
       identityId:(NSString *)identityId {
  
  [OfflineDB setShadow: dict isBookmark: YES ofIdentity: identityId];
}

-(NSDictionary *)loadShadowType:(RecordType)type
                       identity:(NSString *)identity {
  
  return [OfflineDB shadowIsBookmark: YES ofIdentity: identity];
}

// MARK: SyncDelegate
-(void)dynamoPushSuccessWithType:(RecordType)type
                            data:(NSDictionary *)data
                     newCommitId:(NSString *)commitId {
  
  NSString *userId = [self identityId];
  [self saveShadow: data[@"_dicts"] type: type commitId: commitId identityId: userId];
}

-(id)emptyShadowIsBookmark:(BOOL)isBookmark ofIdentity:(NSString *)identity {
  
  [self saveShadow: @{} type: 0 commitId: nil identityId: identity];
  NSDictionary *s = [self loadShadowType: 0 identity: identity];
  return s;
}

@end


// For DynamoSync
static DynamoTestBase *dynamo;

// For Queue
static DispatchQueue *dispatchQueue;

// For login
static LoginTestBase *loginBase;
static OfflineCognito *cognito;

static NSString *sampleUsername1 = @"sss";
static NSString *samplePassword1 = @"88888888";

static NSString *sampleUsername2 = @"uuu";
static NSString *samplePassword2 = @"88888888";

NSString *identityId1 = @"sss";
NSString *identityId2 = @"uuu";


dispatch_time_t waitTime = 4.0;

SpecBegin(MultipleUserLoginAndSync)


describe(@"test1", ^{
  
  beforeAll(^{
    
    waitUntil(^(DoneCallback done) {
      dynamo = [DynamoTestBase new];
      dispatchQueue = [DispatchQueue new];
      cognito = [OfflineCognito shared];
      loginBase = [LoginTestBase new];
      
      if (loginBase.isAWSLogin) {
        [loginBase logout: ^(id result, NSError *error) {
          done();
        }];
      }
      done();
    });
  });
  
  
  it(@"Test start", ^{
    
    __block NSDictionary *dataInitialShadow;
    
    __block NSString *_commitId1 = @"";
    __block NSString *_commitId2 = @"";
    
    waitUntil(^(DoneCallback done) {
      
      //MARK: sss, first
      // user login: sss
      [dispatchQueue performWaitBlock:^(dispatch_semaphore_t sema) {
        
        dispatch_semaphore_wait(sema, waitTime);
        loginBase.username = sampleUsername1;
        loginBase.password = samplePassword1;
        [loginBase login: ^(id result, NSError *error) {
          
          NSLog(@"Now is %@ logged in", loginBase.offlineIdentity);
          expect(result).notTo.beNil;
          expect(error).to.beNil;
          
          dispatch_semaphore_signal(sema);
        }];
        
        dispatch_semaphore_wait(sema, waitTime);
        // Check first user is logged in
        
        BOOL isQualified = [cognito verifyUsername: sampleUsername1
                                          password: samplePassword1];
        XCTAssertTrue(isQualified);
        dispatch_semaphore_signal(sema);
        // First Initial Remote data for use sss.
        dispatch_semaphore_wait(sema, waitTime);
        [dynamo initial: @{
                           @"A": @{@"author": @"A", @"url": @"A"},
                           @"B": @{@"author": @"B", @"url": @"B"}
                           }
             exeHandler:^(NSString *commitId, NSString *remoteHash, NSDictionary *shadow, NSError *error) {
               
               expect(error).to.beNil;
               expect(commitId).notTo.beNil;
               expect(remoteHash).notTo.beNil;
               _commitId1 = commitId;
               
             } completion:^(NSDictionary *newShadow, NSString *commitId, NSError *error) {
               
               expect(error).to.beNil;
               newShadow = dataInitialShadow;
               _commitId1 = commitId;
               dispatch_semaphore_signal(sema);
             }];
        
        dispatch_semaphore_wait(sema, waitTime);
        
        // Second to verify thie Initial Data compares with shadow.
        [dynamo pullToCheck: dataInitialShadow
                 exeHandler:^(BOOL isSame) {
                   
                   // If here failed, says initial push to remote is failed.
                   expect(isSame).to.beTruthy;
                   
                 } completion:^(NSError *error) {
                   
                   expect(error).to.beNil;
                   dispatch_semaphore_signal(sema);
                 }];
        
        dispatch_semaphore_wait(sema, waitTime);
        
        // sss 2: A, B, C, D
        NSDictionary *expectShadow = @{
                                       @"A": @{@"author": @"A", @"url": @"A"},
                                       @"B": @{@"author": @"B", @"url": @"B"}
                                       };
        NSDictionary *client = @{
                                 @"A": @{@"author": @"A", @"url": @"A"},
                                 @"B": @{@"author": @"B", @"url": @"B"},
                                 @"C": @{@"author": @"C", @"url": @"C"},
                                 @"D": @{@"author": @"D", @"url": @"D"}
                                 };
        [dynamo examineSpec: @"second commit: sss"
                   commitId: _commitId1
                 remoteHash: nil
                 clientDict: client
               expectShadow: nil
             examineHandler:^(NSDictionary *shadow) {
               
               expect(shadow).to.equal(expectShadow);
               
             } shouldReplace:^BOOL(id oldValue, id newValue) {
               
               return YES;
               
             } exeHandler:^(NSDictionary *diff, NSError *error) {
               
               expect(error).to.beNil;
               
             } completion:^(NSDictionary *newShadow, NSString *commitId, NSError *error) {
               
               NSDictionary *expectRemote = @{
                                              @"A": @{@"author": @"A", @"url": @"A"},
                                              @"B": @{@"author": @"B", @"url": @"B"},
                                              @"C": @{@"author": @"C", @"url": @"C"},
                                              @"D": @{@"author": @"D", @"url": @"D"}
                                              };
               
               expect(error).to.beNil;
               expect(commitId).to.equal(_commitId1);
               expect(newShadow).to.equal(expectRemote);
               dispatch_semaphore_signal(sema);
             }];
        
        dispatch_semaphore_wait(sema, waitTime);
        
        NSLog(@"Now is %@ logging out", loginBase.offlineIdentity);
        
        [loginBase logout: ^(id result, NSError *error) {
          
          expect(result).notTo.beNil;
          expect(error).to.beNil;
          dispatch_semaphore_signal(sema);
          done();
        }];
        
      }];
      
#if NO
      // **********************************
      
      
      //MARK: uuu, first
      // user login: uuu
      [dispatchQueue performWaitBlock:^(dispatch_semaphore_t sema) {
        loginBase.username = sampleUsername2;
        loginBase.password = samplePassword2;
        [loginBase login: ^(id result, NSError *error) {
          
          NSLog(@"Now is %@ logged in", loginBase.offlineIdentity);
          expect(result).notTo.beNil;
          expect(error).to.beNil;
          dispatch_semaphore_signal(sema);
        }];
      }];
      
      // Check first user is logged in
      [dispatchQueue performWaitBlock:^(dispatch_semaphore_t sema) {
        
        BOOL isQualified = [cognito verifyUsername: sampleUsername1
                                          password: samplePassword1];
        
        XCTAssertTrue(isQualified);
        dispatch_semaphore_signal(sema);
      }];
      
      // First Initial Remote data for use uuu.
      [dispatchQueue performWaitBlock:^(dispatch_semaphore_t sema) {
        
        [dynamo initial: @{
                           @"A": @{@"author": @"A", @"url": @"A"},
                           @"B": @{@"author": @"B", @"url": @"B"}
                           }
             exeHandler:^(NSString *commitId, NSString *remoteHash, NSDictionary *shadow, NSError *error) {
               
               expect(error).to.beNil;
               expect(commitId).notTo.beNil;
               expect(remoteHash).notTo.beNil;
               _commitId2 = commitId;
               
             } completion:^(NSDictionary *newShadow, NSString *commitId, NSError *error) {
               
               expect(error).to.beNil;
               newShadow = dataInitialShadow;
               dispatch_semaphore_signal(sema);
             }];
      }];
      
      // Second to verify thie Initial Data compares with shadow.
      [dispatchQueue performWaitBlock:^(dispatch_semaphore_t sema) {
        [dynamo pullToCheck: dataInitialShadow
                 exeHandler:^(BOOL isSame) {
                   
                   // If here failed, says initial push to remote is failed.
                   expect(isSame).to.beTruthy;
                   
                 } completion:^(NSError *error) {
                   
                   expect(error).to.beNil;
                   dispatch_semaphore_signal(sema);
                 }];
      }];
      
      // uuu 2: A, B, Y, Z
      [dispatchQueue performWaitBlock:^(dispatch_semaphore_t sema) {
        NSDictionary *expectShadow = @{
                                       @"A": @{@"author": @"A", @"url": @"A"},
                                       @"B": @{@"author": @"B", @"url": @"B"}
                                       };
        NSDictionary *client = @{
                                 @"A": @{@"author": @"A", @"url": @"A"},
                                 @"B": @{@"author": @"B", @"url": @"B"},
                                 @"Y": @{@"author": @"Y", @"url": @"Y"},
                                 @"Z": @{@"author": @"Z", @"url": @"Z"}
                                 };
        [dynamo examineSpec: @"second commit: uuu"
                   commitId: _commitId2
                 remoteHash: nil
                 clientDict: client
               expectShadow: nil
             examineHandler:^(NSDictionary *shadow) {
               
               expect(shadow).to.equal(expectShadow);
               
             } shouldReplace:^BOOL(id oldValue, id newValue) {
               
               return YES;
               
             } exeHandler:^(NSDictionary *diff, NSError *error) {
               
               expect(error).to.beNil;
               
             } completion:^(NSDictionary *newShadow, NSString *commitId, NSError *error) {
               
               NSDictionary *expectRemote = @{
                                              @"A": @{@"author": @"A", @"url": @"A"},
                                              @"B": @{@"author": @"B", @"url": @"B"},
                                              @"Y": @{@"author": @"Y", @"url": @"Y"},
                                              @"Z": @{@"author": @"Z", @"url": @"Z"}
                                              };
               
               expect(error).to.beNil;
               expect(newShadow).to.equal(expectRemote);
               dispatch_semaphore_signal(sema);
             }];
      }];
      
      [dispatchQueue performWaitBlock:^(dispatch_semaphore_t sema) {
        
        NSLog(@"Now is %@ logging out", loginBase.offlineIdentity);
        
        [loginBase logout: ^(id result, NSError *error) {
          
          expect(result).notTo.beNil;
          expect(error).to.beNil;
          dispatch_semaphore_signal(sema);
        }];
      }];
      
      // *************************************
      
      //MARK: sss, third
      // user login: sss
      [dispatchQueue performWaitBlock:^(dispatch_semaphore_t sema) {
        loginBase.username = sampleUsername1;
        loginBase.password = samplePassword1;
        [loginBase login: ^(id result, NSError *error) {
          
          NSLog(@"Now is %@ logged in", loginBase.offlineIdentity);
          expect(result).notTo.beNil;
          expect(error).to.beNil;
          dispatch_semaphore_signal(sema);
        }];
      }];
      
      [dispatchQueue performWaitBlock:^(dispatch_semaphore_t sema) {
        NSDictionary *expectShadow = @{
                                       @"A": @{@"author": @"A", @"url": @"A"},
                                       @"B": @{@"author": @"B", @"url": @"B"},
                                       @"C": @{@"author": @"C", @"url": @"C"},
                                       @"D": @{@"author": @"D", @"url": @"D"}
                                       };
        NSDictionary *client = @{
                                 @"B": @{@"author": @"B", @"url": @"B1"},
                                 @"C": @{@"author": @"C", @"url": @"C1"},
                                 @"D": @{@"author": @"D", @"url": @"D1"}
                                 };
        [dynamo examineSpec: @"third commit: sss"
                   commitId: _commitId1
                 remoteHash: nil
                 clientDict: client
               expectShadow: nil
             examineHandler:^(NSDictionary *shadow) {
               
               expect(shadow).to.equal(expectShadow);
               
             } shouldReplace:^BOOL(id oldValue, id newValue) {
               
               return YES;
               
             } exeHandler:^(NSDictionary *diff, NSError *error) {
               
               expect(error).to.beNil;
               
             } completion:^(NSDictionary *newShadow, NSString *commitId, NSError *error) {
               
               NSDictionary *expectRemote = @{
                                              @"B": @{@"author": @"B", @"url": @"B1"},
                                              @"C": @{@"author": @"C", @"url": @"C1"},
                                              @"D": @{@"author": @"D", @"url": @"D1"}
                                              };
               expect(error).to.beNil;
               expect(newShadow).to.equal(expectRemote);
               dispatch_semaphore_signal(sema);
             }];
      }];
      
      [dispatchQueue performWaitBlock:^(dispatch_semaphore_t sema) {
        
        NSLog(@"Now is %@ logging out", loginBase.offlineIdentity);
        [loginBase logout: ^(id result, NSError *error) {
          
          expect(result).notTo.beNil;
          expect(error).to.beNil;
          dispatch_semaphore_signal(sema);
        }];
      }];
      
      // ******************************************
      
      //MARK: uuu, third
      // user login: uuu
      [dispatchQueue performWaitBlock:^(dispatch_semaphore_t sema) {
        loginBase.username = sampleUsername2;
        loginBase.password = samplePassword2;
        [loginBase login: ^(id result, NSError *error) {
          
          NSLog(@"Now is %@ logged in", loginBase.offlineIdentity);
          expect(result).notTo.beNil;
          expect(error).to.beNil;
          dispatch_semaphore_signal(sema);
        }];
      }];
      
      // Start Scenario 2, part 1.
      [dispatchQueue performWaitBlock:^(dispatch_semaphore_t sema) {
        NSDictionary *expectShadow = @{
                                       @"A": @{@"author": @"A", @"url": @"A"},
                                       @"B": @{@"author": @"B", @"url": @"B"},
                                       @"Y": @{@"author": @"Y", @"url": @"Y"},
                                       @"Z": @{@"author": @"Z", @"url": @"Z"}
                                       };
        NSDictionary *client = @{
                                 @"B": @{@"author": @"B", @"url": @"B2"},
                                 @"Y": @{@"author": @"Y", @"url": @"Y1"},
                                 @"Z": @{@"author": @"Z", @"url": @"Z"}
                                 };
        
        [dynamo examineSpec: @"third commit: uuu"
                   commitId: _commitId2
                 remoteHash: nil
                 clientDict: client
               expectShadow: nil
             examineHandler:^(NSDictionary *shadow) {
               
               expect(shadow).notTo.equal(expectShadow);
               
             } shouldReplace:^BOOL(id oldValue, id newValue) {
               
               return YES;
               
             } exeHandler:^(NSDictionary *diff, NSError *error) {
               
               expect(error).to.beNil;
               
             } completion:^(NSDictionary *newShadow, NSString *commitId, NSError *error) {
               
               NSDictionary *expectRemote = @{
                                              @"B": @{@"author": @"B", @"url": @"B2"},
                                              @"Y": @{@"author": @"Y", @"url": @"Y1"},
                                              @"Z": @{@"author": @"Z", @"url": @"Z"}
                                              };
               expect(error).to.beNil;
               expect(newShadow).to.equal(expectRemote);
               dispatch_semaphore_signal(sema);
             }];
      }];
      
      [dispatchQueue performWaitBlock:^(dispatch_semaphore_t sema) {
        
        NSLog(@"Now is %@ logging out", loginBase.offlineIdentity);
        [loginBase logout: ^(id result, NSError *error) {
          
          expect(result).notTo.beNil;
          expect(error).to.beNil;
          dispatch_semaphore_signal(sema);
        }];
      }];
      
      // ************************************************
      
      //MARK: sss, fourth
      // user login: sss
      [dispatchQueue performWaitBlock:^(dispatch_semaphore_t sema) {
        loginBase.username = sampleUsername1;
        loginBase.password = samplePassword1;
        [loginBase login: ^(id result, NSError *error) {
          
          NSLog(@"Now is %@ logged in", loginBase.offlineIdentity);
          expect(result).notTo.beNil;
          expect(error).to.beNil;
          dispatch_semaphore_signal(sema);
        }];
      }];
      
      [dispatchQueue performWaitBlock:^(dispatch_semaphore_t sema) {
        NSDictionary *expectShadow = @{
                                       @"B": @{@"author": @"B", @"url": @"B1"},
                                       @"C": @{@"author": @"C", @"url": @"C1"},
                                       @"D": @{@"author": @"D", @"url": @"D1"}
                                       };
        NSDictionary *client = @{
                                 @"B": @{@"author": @"B", @"url": @"B3"},
                                 @"C": @{@"author": @"C", @"url": @"C1"},
                                 @"D": @{@"author": @"D", @"url": @"D"}
                                 };
        
        [dynamo examineSpec: @"fourth commit: sss"
                   commitId: _commitId1
                 remoteHash: nil
                 clientDict: client
               expectShadow: nil
             examineHandler:^(NSDictionary *shadow) {
               
               expect(shadow).notTo.equal(expectShadow);
               
             } shouldReplace:^BOOL(id oldValue, id newValue) {
               
               return YES;
               
             } exeHandler:^(NSDictionary *diff, NSError *error) {
               
               expect(error).to.beNil;
               
             } completion:^(NSDictionary *newShadow, NSString *commitId, NSError *error) {
               
               NSDictionary *expectRemote = @{
                                              @"B": @{@"author": @"B", @"url": @"B3"},
                                              @"C": @{@"author": @"C", @"url": @"C1"},
                                              @"D": @{@"author": @"D", @"url": @"D"}
                                              };
               expect(error).to.beNil;
               expect(newShadow).to.equal(expectRemote);
               dispatch_semaphore_signal(sema);
             }];
      }];
      
      [dispatchQueue performWaitBlock:^(dispatch_semaphore_t sema) {
        
        NSLog(@"Now is %@ logging out", loginBase.offlineIdentity);
        [loginBase logout: ^(id result, NSError *error) {
          
          expect(result).notTo.beNil;
          expect(error).to.beNil;
          dispatch_semaphore_signal(sema);
        }];
      }];
      
      // **********************************************
      
      //MARK: uuu, fourth
      // user login: uuu
      [dispatchQueue performWaitBlock:^(dispatch_semaphore_t sema) {
        loginBase.username = sampleUsername2;
        loginBase.password = samplePassword2;
        [loginBase login: ^(id result, NSError *error) {
          
          NSLog(@"Now is %@ logged in", loginBase.offlineIdentity);
          expect(result).notTo.beNil;
          expect(error).to.beNil;
          dispatch_semaphore_signal(sema);
        }];
      }];
      
      [dispatchQueue performWaitBlock:^(dispatch_semaphore_t sema) {
        NSDictionary *expectShadow = @{
                                       @"B": @{@"author": @"B", @"url": @"B2"},
                                       @"Y": @{@"author": @"Y", @"url": @"Y1"},
                                       @"Z": @{@"author": @"Z", @"url": @"Z"}
                                       };
        NSDictionary *client = @{
                                 @"B": @{@"author": @"B", @"url": @"B2"},
                                 @"Y": @{@"author": @"Y", @"url": @"Y1"},
                                 @"Z": @{@"author": @"Z", @"url": @"Z"},
                                 @"Q": @{@"author": @"Q", @"url": @"Q"}
                                 };
        
        [dynamo examineSpec: @"fourth commit: uuu"
                   commitId: _commitId2
                 remoteHash: nil
                 clientDict: client
               expectShadow: nil
             examineHandler:^(NSDictionary *shadow) {
               
               expect(shadow).notTo.equal(expectShadow);
               
             } shouldReplace:^BOOL(id oldValue, id newValue) {
               
               return YES;
               
             } exeHandler:^(NSDictionary *diff, NSError *error) {
               
               expect(error).to.beNil;
               
             } completion:^(NSDictionary *newShadow, NSString *commitId, NSError *error) {
               
               NSDictionary *expectRemote = @{
                                              @"B": @{@"author": @"B", @"url": @"B2"},
                                              @"Y": @{@"author": @"Y", @"url": @"Y1"},
                                              @"Z": @{@"author": @"Z", @"url": @"Z"},
                                              @"Q": @{@"author": @"Q", @"url": @"Q"}
                                              };
               expect(error).to.beNil;
               expect(newShadow).to.equal(expectRemote);
               dispatch_semaphore_signal(sema);
             }];
      }];
      
      [dispatchQueue performWaitBlock:^(dispatch_semaphore_t sema) {
        
        NSLog(@"Now is %@ logging out", loginBase.offlineIdentity);
        [loginBase logout: ^(id result, NSError *error) {
          
          expect(result).notTo.beNil;
          expect(error).to.beNil;
          dispatch_semaphore_signal(sema);
        }];
      }];
      
      
      // *******************************************
      
      // Final check for sss
      [dispatchQueue performWaitBlock:^(dispatch_semaphore_t sema) {
        loginBase.username = sampleUsername1;
        loginBase.password = samplePassword1;
        [loginBase login: ^(id result, NSError *error) {
          
          NSLog(@"Now is %@ logged in", loginBase.offlineIdentity);
          expect(result).notTo.beNil;
          expect(error).to.beNil;
          dispatch_semaphore_signal(sema);
        }];
      }];
      
      [dispatchQueue performWaitBlock:^(dispatch_semaphore_t sema) {
        [dynamo pullToCheck: @{
                               @"B": @{@"author": @"B", @"url": @"B3"},
                               @"C": @{@"author": @"C", @"url": @"C1"},
                               @"D": @{@"author": @"D", @"url": @"D"}
                               }
                 exeHandler:^(BOOL isSame) {
                   expect(isSame).to.beTruthy;
                 } completion:^(NSError *error) {
                   expect(error).to.beNil;
                   expect(error).notTo.beNil;
                   dispatch_semaphore_signal(sema);
                   done();
                 }];
      }];
      
      [dispatchQueue performWaitBlock:^(dispatch_semaphore_t sema) {
        
        NSLog(@"Now is %@ logging out", loginBase.offlineIdentity);
        [loginBase logout: ^(id result, NSError *error) {
          
          expect(result).notTo.beNil;
          expect(error).to.beNil;
          dispatch_semaphore_signal(sema);
        }];
      }];
      
      
      // Final check for uuu
      [dispatchQueue performWaitBlock:^(dispatch_semaphore_t sema) {
        loginBase.username = sampleUsername2;
        loginBase.password = samplePassword2;
        [loginBase login: ^(id result, NSError *error) {
          
          NSLog(@"Now is %@ logged in", loginBase.offlineIdentity);
          expect(result).notTo.beNil;
          expect(error).to.beNil;
          dispatch_semaphore_signal(sema);
        }];
      }];
      
      [dispatchQueue performWaitBlock:^(dispatch_semaphore_t sema) {
        [dynamo pullToCheck: @{
                               @"B": @{@"author": @"B", @"url": @"B2"},
                               @"Y": @{@"author": @"Y", @"url": @"Y1"},
                               @"Z": @{@"author": @"Z", @"url": @"Z"},
                               @"Q": @{@"author": @"Q", @"url": @"Q"}
                               }
                 exeHandler:^(BOOL isSame) {
                   expect(isSame).to.beTruthy;
                 } completion:^(NSError *error) {
                   expect(error).to.beNil;
                   expect(error).notTo.beNil;
                   dispatch_semaphore_signal(sema);
                   done();
                 }];
      }];
      
      [dispatchQueue performWaitBlock:^(dispatch_semaphore_t sema) {
        
        NSLog(@"Now is %@ logging out", loginBase.offlineIdentity);
        [loginBase logout: ^(id result, NSError *error) {
          
          expect(result).notTo.beNil;
          expect(error).to.beNil;
          dispatch_semaphore_signal(sema);
          done();
        }];
      }];
#endif
    });

  });
  
  afterAll(^{
    
    [dispatchQueue waitForGroup];
    dispatchQueue = nil;
    loginBase = nil;
    cognito = nil;
    
  });
  

  
});



SpecEnd


