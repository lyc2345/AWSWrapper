//
//  RemoteLoginTest.m
//  AWSWrapper
//
//  Created by Stan Liu on 29/07/2017.
//  Copyright © 2017 lyc2345. All rights reserved.
//

#import "LoginTestBase.h"
#import "DispatchQueue.h"
@import Specta;
@import AWSWrapper;

static LoginTestBase *testcase;
static OfflineCognito *cognito;
static DispatchQueue *dispatchQueue;

static NSString *sampleUsername = @"sss";
static NSString *samplePassword = @"88888888";

SpecBegin(ARemoteLoginTests)

describe(@"Tests1", ^{
  
  beforeAll(^{
    
    waitUntil(^(DoneCallback done) {
      
      testcase = [LoginTestBase new];
      dispatchQueue = [DispatchQueue new];
      cognito = [OfflineCognito shared];
      done();
    });
  });
  
  it(@"Remote login", ^{
    
    waitUntil(^(DoneCallback done) {
      
      testcase.username = @"uuu";
      testcase.password = samplePassword;
      
      [dispatchQueue performGroupedDelay: 4 block: ^{
        
        [testcase login: ^(id result, NSError *error) {
          
          expect(result).notTo.beNil;
          expect(error).to.beNil;
        }];
      }];
      
      [dispatchQueue performGroupedDelay: 2 block: ^{
        
        BOOL isQualified = [cognito verifyUsername: sampleUsername
                                          password: samplePassword];
        
        XCTAssertTrue(isQualified);
        done();
      }];
      
//      [dispatchQueue performGroupedDelay: 2 block: ^{
//        
//        [testcase logout: ^(id result, NSError *error) {
//          
//          expect(result).notTo.beNil;
//          expect(error).to.beNil;
//        }];
//      }];
//      
//      [dispatchQueue performGroupedDelay: 4 block: ^{
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
//      [dispatchQueue performGroupedDelay: 2 block: ^{
//        
//        BOOL isQualified = [cognito verifyUsername: sampleUsername
//                                          password: samplePassword];
//        
//        XCTAssertTrue(isQualified);
//        done();
//      }];
//      
//      [dispatchQueue performGroupedDelay: 2 block: ^{
//        
//        [testcase logout: ^(id result, NSError *error) {
//          
//          expect(result).notTo.beNil;
//          expect(error).to.beNil;
//        }];
//      }];
      
    });
  });
  

});

SpecEnd
