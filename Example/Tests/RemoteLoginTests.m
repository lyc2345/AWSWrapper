//
//  RemoteLoginTest.m
//  AWSWrapper
//
//  Created by Stan Liu on 29/07/2017.
//  Copyright © 2017 lyc2345. All rights reserved.
//

#import "LoginTestBase.h"
#import "DispatchQueue.h"
#import "OfflineCognitoTestBase.h"
#import "Specta/Specta.h"
#import "Expecta/Expecta.h"
@import AWSWrapper;



static NSString *sampleUsername = @"sss";
static NSString *samplePassword = @"88888888";

@interface RemoteLoginTests : XCTestCase

@property LoginTestBase *loginBase;
@property OfflineCognito *cognito;
@property DispatchQueue *dispatchQueue;

@end

@implementation RemoteLoginTests

-(void)setUp {
  [super setUp];
  
  _loginBase = [LoginTestBase new];
  _dispatchQueue = [DispatchQueue new];
  _cognito = [OfflineCognito shared];
  
  [self initialSetup];
}

-(void)initialSetup {
  
  if (_loginBase.isAWSLogin) {
    [_loginBase logout: ^(id result, NSError *error) {
      
      XCTAssertNil(error);
    }];
  }
}

-(void)tearDown {
  [super tearDown];
}

-(void)testRemoteLogin {
  
  _loginBase.username = sampleUsername;
  _loginBase.password = samplePassword;
  
  [_loginBase login: ^(id result, NSError *error) {
    
    //      expect(result).to.beNil;
    //      expect(error).to.beNil;
    XCTAssertNotNil(result);
    XCTAssertNil(error);
    
    BOOL isQualified = [_cognito verifyUsername: sampleUsername
                                       password: samplePassword];
    
    XCTAssertTrue(isQualified);
    
  }];
}


@end

/*
SpecBegin(RemoteLoginTests)

describe(@"Tests1", ^{
  
  beforeAll(^{
    
    waitUntil(^(DoneCallback done) {
      
      testcase = [LoginTestBase new];
      dispatchQueue = [DispatchQueue new];
      cognito = [OfflineCognito shared];
      
      if (testcase.isAWSLogin) {
        [testcase logout: ^(id result, NSError *error) {
          
          if (testcase.isLogin) {
            [testcase logoutOfflineCompletion:^{
              done();
            }];
          }
        }];
      }
      if (testcase.isLogin) {
        [testcase logoutOfflineCompletion:^{
          done();
        }];
      }
    });
  });
  
  it(@"Remote login", ^{
    
    waitUntil(^(DoneCallback done) {
      
      //testcase.username = @"uuu";
      testcase.username = sampleUsername;
      testcase.password = samplePassword;
      
      [dispatchQueue performGroupedDelay: 0 block: ^{
        
        [testcase login: ^(id result, NSError *error) {
          
          expect(result).notTo.beNil;
          expect(error).to.beNil;
          
          BOOL isQualified = [cognito verifyUsername: sampleUsername
                                            password: samplePassword];
          
          XCTAssertTrue(isQualified);
          done();
          
        }];
      }];
    });
  });
  

});

SpecEnd

*/
//      [dispatchQueue performGroupedDelay: 0.3 block: ^{
//
//        [testcase logout: ^(id result, NSError *error) {
//
//          expect(result).notTo.beNil;
//          expect(error).to.beNil;
//        }];
//      }];
//
//      [dispatchQueue performGroupedDelay: 0.5 block: ^{
//
//        testcase.username = sampleUsername;
//        testcase.password = samplePassword;
//
//        [testcase login: ^(id result, NSError *error) {
//
//          expect(result).notTo.beNil;
//          expect(error).to.beNil;
//        }];
//      }];
//
//      [dispatchQueue performGroupedDelay: 0.3 block: ^{
//
//        BOOL isQualified = [cognito verifyUsername: sampleUsername
//                                          password: samplePassword];
//
//        XCTAssertTrue(isQualified);
//        done();
//      }];
//
//      [dispatchQueue performGroupedDelay: 0.3 block: ^{
//
//        [testcase logout: ^(id result, NSError *error) {
//
//          expect(result).notTo.beNil;
//          expect(error).to.beNil;
//        }];
//      }];


