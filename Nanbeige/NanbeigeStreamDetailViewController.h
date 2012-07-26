//
//  NanbeigeStreamDetailViewController.h
//  Nanbeige
//
//  Created by Wang Zhongyu on 12-7-26.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NanbeigeSplitViewBarButtonItemPresenter.h"

@interface NanbeigeStreamDetailViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, NanbeigeSplitViewBarButtonItemPresenter> 

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (strong, nonatomic) UIBarButtonItem *splitViewBarButtonItem;
@property (strong, nonatomic) NSDictionary *course;
- (IBAction)renrenPost:(id)sender;
- (IBAction)weiboPost:(id)sender;

@end
