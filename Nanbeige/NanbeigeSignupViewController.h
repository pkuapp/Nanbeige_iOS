//
//  NanbeigeSignupViewController.h
//  Nanbeige
//
//  Created by Wang Zhongyu on 12-7-15.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NanbeigeSignupViewController : UITableViewController <UITextFieldDelegate>
- (IBAction)onCancelButtonPressed:(id)sender;
@property (retain, nonatomic) UITextField *usernameTextField;
@property (retain, nonatomic) UITextField *passwordTextField;
@property (retain, nonatomic) UITextField *validcodeTextField;
@property (retain, nonatomic) IBOutlet UITableViewCell *usernameCell;
@property (retain, nonatomic) IBOutlet UITableViewCell *passwordCell;
@property (retain, nonatomic) IBOutlet UITableViewCell *validcodeCell;

@end
