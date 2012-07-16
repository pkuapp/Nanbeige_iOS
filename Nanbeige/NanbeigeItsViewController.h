//
//  NanbeigeItsViewController.h
//  Nanbeige
//
//  Created by Wang Zhongyu on 12-7-9.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "AppCoreDataProtocol.h"
#import "AppUserDelegateProtocol.h"
#import "PABezelHUDDelegate.h"
#import "ReachabilityProtocol.h"
#import "Reachability.h"
#import "NanbeigeIPGateHelper.h"
#import "Environment.h"
#import "ModalAlert.h"
#import "NanbeigeAppDelegate.h"
#import "ASIHTTPRequest.h"
#import "SystemHelper.h"
#import "RegexKitLite.h"
#import "NanbeigeDetailGateInfoViewController.h"

#define _keyAutoDisconnect @"AutoDisconnect"
#define _keyAlwaysGlobal @"AlwaysGlobal"
#define _keyAccountState @"IPGateAccount"
#define _keyIPGateBalance @"余额"
#define _keyIPGateType @"Type"
#define _keyIPGateTimeLeft @"timeLeft"
#define _keyIPGateTimeConsumed @"Time"
#define _keyIPGateUpdatedTime @"IPGateUpdatedTime"

@interface NanbeigeItsViewController : UITableViewController<NanbeigeIPGateConnectDelegate,MBProgressHUDDelegate> { 
    BOOL _autoDisconnect;
    BOOL _alwaysGlobal;
    BOOL _hasSilentCallback;
}
@property (retain, nonatomic) NSString* Username;
@property (retain, nonatomic) NSString* Password;

@property (retain, nonatomic) NSMutableDictionary* gateStateDictionary;
@property (retain, nonatomic) NSUserDefaults *defaults;
@property (assign) NanbeigeIPGateHelper* connector;
@property (assign, nonatomic) NSInteger numStatus;

@property (retain, nonatomic) UILabel *labelStatus;
@property (retain, nonatomic) UILabel *labelWarning;
@property (retain, nonatomic) MBProgressHUD *progressHub;
@property (nonatomic, assign) NSObject<AppCoreDataProtocol,AppUserDelegateProtocol,ReachabilityProtocol,PABezelHUDDelegate> *delegate;

@property (retain, nonatomic) IBOutlet UITableViewCell *connectFree;
@property (retain, nonatomic) IBOutlet UITableViewCell *connectGlobal;
@property (retain, nonatomic) IBOutlet UITableViewCell *disconnectAll;
@property (retain, nonatomic) IBOutlet UIButton *detailGateInfo;

- (IBAction)detailGateInfoPressed:(id)sender;
- (IBAction)backToMainButtonPressed:(id)sender;

@end
