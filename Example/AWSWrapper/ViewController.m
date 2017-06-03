//
//  ViewController.m
//  AWSWrapper
//
//  Created by Stan Liu on 02/06/2017.
//  Copyright © 2017 lyc2345. All rights reserved.
//

#import "ViewController.h"
@import AWSWrapper.AWSWrapper;

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
 
  [super viewDidLoad];
  
  [AWSWrapper doAThing];
  
}
@end
