//
//  NanbeigeDetailGateInfoViewController.h
//  Nanbeige
//
//  Created by Wang Zhongyu on 12-7-16.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CPDetailGateInfoViewController : UITableViewController

@property (retain, nonatomic) NSString *accountStatus;
@property (retain, nonatomic) NSString *accountPackage;
@property (retain, nonatomic) NSString *accountAccuTime;
@property (retain, nonatomic) NSString *accountRemainTime;
@property (retain, nonatomic) NSString *accountBalance;
@property (retain, nonatomic) IBOutlet UITableViewCell *packageCell;
@property (retain, nonatomic) IBOutlet UITableViewCell *accuTimeCell;
@property (retain, nonatomic) IBOutlet UITableViewCell *remainTimeCell;
@property (retain, nonatomic) IBOutlet UITableViewCell *balanceCell;

@end
