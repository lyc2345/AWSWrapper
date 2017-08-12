//
//  MultipleShadowTests.m
//  AWSWrapper
//
//  Created by Stan Liu on 11/08/2017.
//  Copyright © 2017 lyc2345. All rights reserved.
//

#import "LoginTestBase.h"
#import "Specta/Specta.h"
#import "Expecta/Expecta.h"
#import "OfflineDBTestBase.h"
#import "DispatchQueue.h"
#import "OfflineCognitoTestBase.h"

@import AWSWrapper;

static LoginTestBase *testcase;
static OfflineCognitoTestBase *cognito;
static DispatchQueue *dispatchQueue;

static NSString *username1 = @"ggggg";
static NSString *identityId1 = @"ggggg1111";
static NSString *username2 = @"ttttt";
static NSString *identityId2 = @"ttttt2222";

static NSString *password = @"88888888";

SpecBegin(MultipleShadowTests)

describe(@"test", ^{
  
  beforeAll(^{
    
    waitUntil(^(DoneCallback done) {
      
      testcase = [LoginTestBase new];
      dispatchQueue = [DispatchQueue new];
      cognito = [OfflineCognitoTestBase shared];
      
      [cognito storeUsername: username1
                    password: password
                  identityId: identityId1];
      
      [cognito storeUsername: username2
                    password: password
                  identityId: identityId2];
      
      [OfflineDBTestBase setShadow: nil
                        isBookmark: YES ofIdentity: identityId1];
      
      [OfflineDBTestBase setShadow: nil
                        isBookmark: YES ofIdentity: identityId2];
      
      done();
    });
  });
  
  it(@"login", ^{
    
    waitUntil(^(DoneCallback done) {
      
      // User 1 login
      [dispatchQueue performGroupedDelay: 1 block: ^{
        
        NSDictionary *toBeSaveShadow = @{
                                         @"A": @{@"author": @"A", @"url": @"A"},
                                         @"B": @{@"author": @"B", @"url": @"B"}
                                         };
        
        [testcase loginOfflineWithUser: username1
                              password: password
                            completion: ^(NSError *error) {
                              
                              expect(error).to.beNil;
                              [OfflineDBTestBase setShadow: toBeSaveShadow
                                                isBookmark: YES ofIdentity: testcase.offlineIdentity];
                              
                              NSDictionary *shadow = [OfflineDBTestBase shadowIsBookmark: YES ofIdentity: testcase.offlineIdentity];
                              expect(shadow).to.equal(toBeSaveShadow);
                            }];
      }];
      
      // User 1 logout
      [dispatchQueue performGroupedDelay: 1 block: ^{
        
        [testcase logoutOfflineCompletion: ^{
          
        }];
      }];
      
      // *************************************************************************
      
      // User 2 login
      [dispatchQueue performGroupedDelay: 1 block: ^{
        
        NSDictionary *toBeSaveShadow = @{
                                         @"X": @{@"author": @"X", @"url": @"X"},
                                         @"Y": @{@"author": @"Y", @"url": @"Y"}
                                         };
        
        [testcase loginOfflineWithUser: username2
                              password: password
                            completion: ^(NSError *error) {
                              
                              expect(error).to.beNil;
                              [OfflineDBTestBase setShadow: toBeSaveShadow
                                                isBookmark: YES ofIdentity: testcase.offlineIdentity];
                              
                              NSDictionary *shadow = [OfflineDBTestBase shadowIsBookmark: YES ofIdentity: testcase.offlineIdentity];
                              expect(shadow).to.equal(toBeSaveShadow);
                            }];
      }];
      
      // User 2 logout
      [dispatchQueue performGroupedDelay: 1 block: ^{
        
        [testcase logoutOfflineCompletion: ^{
          
        }];
      }];
      
      // *************************************************************************
      
      // User 1 login
      [dispatchQueue performGroupedDelay: 1 block: ^{
        
        NSDictionary *toBeSaveShadow = @{
                                         @"A": @{@"author": @"A", @"url": @"A"},
                                         @"B": @{@"author": @"B", @"url": @"B"},
                                         @"C": @{@"author": @"C", @"url": @"C"},
                                         @"D": @{@"author": @"D", @"url": @"D"},
                                         };
        
        [testcase loginOfflineWithUser: username1
                              password: password
                            completion: ^(NSError *error) {
                              
                              expect(error).to.beNil;
                              [OfflineDBTestBase setShadow: toBeSaveShadow
                                                isBookmark: YES ofIdentity: testcase.offlineIdentity];
                              
                              NSDictionary *shadow = [OfflineDBTestBase shadowIsBookmark: YES ofIdentity: testcase.offlineIdentity];
                              expect(shadow).to.equal(toBeSaveShadow);
                            }];
      }];
      
      // User 1 logout
      [dispatchQueue performGroupedDelay: 1 block: ^{
        
        [testcase logoutOfflineCompletion: ^{
          
        }];
      }];
      
      // *************************************************************************
      
      // User 2 login
      [dispatchQueue performGroupedDelay: 1 block: ^{
        
        NSDictionary *toBeSaveShadow = @{
                                         @"X": @{@"author": @"X", @"url": @"X"},
                                         @"Y": @{@"author": @"Y", @"url": @"Y"},
                                         @"Q": @{@"author": @"Q", @"url": @"Q"},
                                         @"K": @{@"author": @"K", @"url": @"K"},
                                         @"Z": @{@"author": @"Z", @"url": @"Z"}
                                         };
        
        [testcase loginOfflineWithUser: username2
                              password: password
                            completion: ^(NSError *error) {
                              
                              expect(error).to.beNil;
                              [OfflineDBTestBase setShadow: toBeSaveShadow
                                                isBookmark: YES ofIdentity: testcase.offlineIdentity];
                              
                              NSDictionary *shadow = [OfflineDBTestBase shadowIsBookmark: YES ofIdentity: testcase.offlineIdentity];
                              expect(shadow).to.equal(toBeSaveShadow);
                            }];
      }];
      
      // User 2 logout
      [dispatchQueue performGroupedDelay: 1 block: ^{
        
        [testcase logoutOfflineCompletion: ^{
          
        }];
      }];
      
      // *************************************************************************
      
      // User 1 login
      [dispatchQueue performGroupedDelay: 1 block: ^{
        
        NSDictionary *toBeSaveShadow = @{
                                         @"A": @{@"author": @"A", @"url": @"A"},
                                         @"C": @{@"author": @"C", @"url": @"C1"},
                                         @"E": @{@"author": @"E", @"url": @"E"},
                                         @"G": @{@"author": @"G", @"url": @"G"}
                                         };
        
        [testcase loginOfflineWithUser: username1
                              password: password
                            completion: ^(NSError *error) {
                              
                              expect(error).to.beNil;
                              [OfflineDBTestBase setShadow: toBeSaveShadow
                                                isBookmark: YES ofIdentity: testcase.offlineIdentity];
                              
                              NSDictionary *shadow = [OfflineDBTestBase shadowIsBookmark: YES ofIdentity: testcase.offlineIdentity];
                              expect(shadow).to.equal(toBeSaveShadow);
                            }];
      }];
      
      // User 1 logout
      [dispatchQueue performGroupedDelay: 1 block: ^{
        
        [testcase logoutOfflineCompletion: ^{
          
        }];
      }];
      
      // *************************************************************************
      
      // User 2 login
      [dispatchQueue performGroupedDelay: 1 block: ^{
        
        NSDictionary *toBeSaveShadow = @{
                                         @"KKK": @{@"author": @"KKK", @"url": @"KKK"},
                                         @"X": @{@"author": @"X", @"url": @"X1"},
                                         @"Q": @{@"author": @"Q", @"url": @"Q"},
                                         @"Z": @{@"author": @"Z", @"url": @"Z"}
                                         };
        
        [testcase loginOfflineWithUser: username2
                              password: password
                            completion: ^(NSError *error) {
                              
                              expect(error).to.beNil;
                              [OfflineDBTestBase setShadow: toBeSaveShadow
                                                isBookmark: YES ofIdentity: testcase.offlineIdentity];
                              
                              NSDictionary *shadow = [OfflineDBTestBase shadowIsBookmark: YES ofIdentity: testcase.offlineIdentity];
                              expect(shadow).to.equal(toBeSaveShadow);
                            }];
      }];
      
      // User 2 logout
      [dispatchQueue performGroupedDelay: 1 block: ^{
        
        [testcase logoutOfflineCompletion: ^{
          
        }];
      }];
      
      // *************************************************************************
      
      
      // Exam result
      
      // User 2 login
      [dispatchQueue performGroupedDelay: 1 block: ^{
        
        [testcase loginOfflineWithUser: username2
                              password: password
                            completion: ^(NSError *error) {
                              
                              expect(error).to.beNil;
                              
                              NSDictionary *shadow = [OfflineDBTestBase shadowIsBookmark: YES ofIdentity: testcase.offlineIdentity];
                              
                              NSDictionary *expectedShadow = @{
                                                               @"KKK": @{@"author": @"KKK", @"url": @"KKK"},
                                                               @"X": @{@"author": @"X", @"url": @"X1"},
                                                               @"Q": @{@"author": @"Q", @"url": @"Q"},
                                                               @"Z": @{@"author": @"Z", @"url": @"Z"}
                                                               };
                              
                              expect(shadow).to.equal(expectedShadow);
                            }];
      }];
      
      // User 2 logout
      [dispatchQueue performGroupedDelay: 1 block: ^{
        
        [testcase logoutOfflineCompletion: ^{
          
        }];
      }];
      
      // *************************************************************************
      
      // User 1 login
      [dispatchQueue performGroupedDelay: 1 block: ^{
        
        [testcase loginOfflineWithUser: username1
                              password: password
                            completion: ^(NSError *error) {
                              
                              expect(error).to.beNil;
                              
                              NSDictionary *shadow = [OfflineDBTestBase shadowIsBookmark: YES ofIdentity: testcase.offlineIdentity];
                              
                              NSDictionary *expectedShadow = @{
                                                               @"A": @{@"author": @"A", @"url": @"A"},
                                                               @"C": @{@"author": @"C", @"url": @"C1"},
                                                               @"E": @{@"author": @"E", @"url": @"E"},
                                                               @"G": @{@"author": @"G", @"url": @"G"}
                                                               };
                              
                              expect(shadow).to.equal(expectedShadow);
                            }];
      }];
      
      // User 1 logout
      [dispatchQueue performGroupedDelay: 1 block: ^{
        
        [testcase logoutOfflineCompletion: ^{
          
          done();
        }];
      }];
      
      // *************************************************************************
      
    });
    
    
  });
  
});

SpecEnd

