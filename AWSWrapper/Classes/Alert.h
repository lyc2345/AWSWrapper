//
//  Alert.h
//  Others
//
//  Created by Stan Liu on 20/02/2017.
//  Copyright © 2017 Stan Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Alert : UIAlertController

-(instancetype)init;

-(void)showError:(NSError *)error confirmHandler:(void(^)(void))confirmHandler;
-(void)showAlertWithTitle:(NSString *)title message:(NSString *)message confirmHandler:(void(^)(void))confirmHandler;

@end
