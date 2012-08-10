//
//  NanbeigeLoginItsViewController.h
//  Nanbeige
//
//  Created by Wang Zhongyu on 12-7-13.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Environment.h"
#import "NanbeigeItsViewController.h"

@interface NanbeigeLoginItsViewController : UITableViewController <UITextFieldDelegate>
- (IBAction)onCancelButtonPressed:(id)sender;
@property (retain, nonatomic) UITextField *usernameTextField;
@property (retain, nonatomic) UITextField *passwordTextField;
@property (retain, nonatomic) IBOutlet UITableViewCell *usernameCell;
@property (retain, nonatomic) IBOutlet UITableViewCell *passwordCell;

@end
