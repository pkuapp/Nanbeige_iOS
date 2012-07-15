//
//  NanbeigeSettingsViewController.h
//  Nanbeige
//
//  Created by Wang Zhongyu on 12-7-9.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WBEngine.h"
#import "Renren.h"

@interface NanbeigeSettingsViewController : UITableViewController <WBEngineDelegate, RenrenDelegate> {
	
    WBEngine *weiBoEngine;
	Renren *renren;
    UIActivityIndicatorView *indicatorView;
	
	UIButton *weiboLogOutBtnOAuth;
	UIButton *renrenLogOutBtnOAuth;
	UIButton *nanbeigeLogOutBtn;
}

@property (retain, nonatomic) WBEngine *weiBoEngine;
@property (retain, nonatomic) Renren *renren;

@property (retain, nonatomic) IBOutlet UITableViewCell *weiboCell;
@property (retain, nonatomic) IBOutlet UITableViewCell *renrenCell;
@property (retain, nonatomic) IBOutlet UITableViewCell *nanbeigeCell;
- (IBAction)logoutAll:(id)sender;

@end
