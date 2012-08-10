//
//  NanbeigeItsViewController.h
//  Nanbeige
//
//  Created by Wang Zhongyu on 12-7-9.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"




#import "CPIPGateHelper.h"
#import "Environment.h"


#import "ASIHTTPRequest.h"
#import "SystemHelper.h"

#import "CPDetailGateInfoViewController.h"

#define _keyAutoDisconnect @"AutoDisconnect"
#define _keyAlwaysGlobal @"AlwaysGlobal"
#define _keyAccountState @"IPGateAccount"
#define _keyIPGateBalance @"余额"
#define _keyIPGateType @"Type"
#define _keyIPGateTimeLeft @"timeLeft"
#define _keyIPGateTimeConsumed @"Time"
#define _keyIPGateUpdatedTime @"IPGateUpdatedTime"
#define _keyIPGateConnectNumber @"连接数"
#define _keyIPGateConnectRange @"连接范围"
#define _keyIPGateSUCCESS @"SUCCESS"
#define _keyIPGateIP @"IP"
#define _keyIPGateConnectStatus @"连接状态"
#define _keyIPGateAccountName @"用户名"
#define _keyIPGateDebt @"欠费"

@interface NanbeigeItsViewController : UITableViewController<CPIPGateConnectDelegate,MBProgressHUDDelegate> {
    BOOL _autoDisconnect;
    BOOL _alwaysGlobal;
    BOOL _hasSilentCallback;
}
@property (retain, nonatomic) NSString* Username;
@property (retain, nonatomic) NSString* Password;

@property (retain, nonatomic) NSMutableDictionary* gateStateDictionary;
@property (retain, nonatomic) NSUserDefaults *defaults;
@property (assign) CPIPGateHelper * connector;
@property (assign, nonatomic) NSInteger numStatus;

@property (retain, nonatomic) UILabel *labelStatus;
@property (retain, nonatomic) UILabel *labelWarning;
@property (retain, nonatomic) MBProgressHUD *progressHub;
@property (nonatomic, assign) NSObject *delegate;
@property (weak, nonatomic) id mainViewController;

@property (retain, nonatomic) IBOutlet UITableViewCell *connectFree;
@property (retain, nonatomic) IBOutlet UITableViewCell *connectGlobal;
@property (retain, nonatomic) IBOutlet UITableViewCell *disconnectAll;
@property (retain, nonatomic) IBOutlet UIButton *detailGateInfo;

- (IBAction)detailGateInfoPressed:(id)sender;

@end
