//
//  ViewController.h
//  CogConf
//
//  Created by sudhakar on 4/2/14.
//  Copyright (c) 2014 sudhakar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController :  UIViewController <UITableViewDelegate, UITableViewDataSource>


- (IBAction)showMessage;
-(IBAction)confCodeBeginEditing:(UITextField *)textField;

@end
