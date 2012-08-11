//
//  CPConnectViewController.h
//  CP
//
//  Created by Wang Zhongyu on 12-7-15.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "WBEngine.h"
//#import "Renren.h"

@interface CPSigninViewController : UITableViewController <UITextFieldDelegate, UITableViewDelegate>
@property (retain, nonatomic) IBOutlet UITextField *usernameTextField;
@property (retain, nonatomic) IBOutlet UITextField *passwordTextField;
//@property (retain, nonatomic) WBEngine *weiBoEngine;
//@property (retain, nonatomic) Renren *renren;
- (IBAction)signupButtonPressed:(id)sender;
- (IBAction)loginButtonPressed:(id)sender;
- (IBAction)renrenLogin:(id)sender;
- (IBAction)weiboLogin:(id)sender;

@end
