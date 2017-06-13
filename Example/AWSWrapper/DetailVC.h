//
//  DetailVC.h
//  AWSWrapper
//
//  Created by Stan Liu on 12/06/2017.
//  Copyright © 2017 lyc2345. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailVC : UIViewController

@property NSString *t;
@property NSString *c;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;

@end
