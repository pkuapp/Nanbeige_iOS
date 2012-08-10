//
//  NanbeigeSignupViewController.h
//  Nanbeige
//
//  Created by Wang Zhongyu on 12-7-15.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CPTextfieldCell.h"

@interface CPEmailSignupViewController : UITableViewController <UITextFieldDelegate>
- (IBAction)onCancelButtonPressed:(id)sender;
@property (retain, nonatomic) UITextField *usernameTextField;
@property (retain, nonatomic) UITextField *passwordTextField;
@property (retain, nonatomic) UITextField *validcodeTextField;
@property (retain, nonatomic) IBOutlet CPTextFieldCell *usernameCell;
@property (retain, nonatomic) IBOutlet CPTextFieldCell *passwordCell;
@property (retain, nonatomic) IBOutlet CPTextFieldCell *validcodeCell;

@end
