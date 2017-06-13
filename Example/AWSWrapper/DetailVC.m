//
//  DetailVC.m
//  AWSWrapper
//
//  Created by Stan Liu on 12/06/2017.
//  Copyright © 2017 lyc2345. All rights reserved.
//

#import "DetailVC.h"

@interface DetailVC ()

@end

@implementation DetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
  
  self.titleLabel.text = self.t;
  self.detailLabel.text = self.c;
}
@end
