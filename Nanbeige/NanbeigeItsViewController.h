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

@interface NanbeigeItsViewController : UITableViewController<NanbeigeIPGateConnectDelegate,MBProgressHUDDelegate> { 
    BOOL _autoDisconnect;
    BOOL _alwaysGlobal;
    BOOL _hasSilentCallback;
}
@property (retain, nonatomic) NSString* Username;
@property (retain, nonatomic) NSString* Password;
@property (retain, nonatomic) NSMutableDictionary* gateStateDictionary;
@property (assign) NanbeigeIPGateHelper* connector;
@property (retain,nonatomic) UISwitch *swAutoDisconnect;
@property (retain,nonatomic) UISwitch *swAlwaysGlobal;
@property (retain, nonatomic) NSUserDefaults *defaults;
@property (assign, nonatomic) NSInteger numStatus;
@property (retain, nonatomic) UILabel *labelStatus;
@property (retain, nonatomic) UILabel *labelWarning;
@property (retain, nonatomic) MBProgressHUD *progressHub;
@property (nonatomic, assign) NSObject<AppCoreDataProtocol,AppUserDelegateProtocol,ReachabilityProtocol,PABezelHUDDelegate> *delegate;
@property (retain, nonatomic) IBOutlet UITableViewCell *connectFree;
@property (retain, nonatomic) IBOutlet UITableViewCell *connectGlobal;
@property (retain, nonatomic) IBOutlet UITableViewCell *disconnectAll;
- (IBAction)detailGateInfoPressed:(id)sender;
@property (retain, nonatomic) IBOutlet UIButton *detailGateInfo;
- (IBAction)backToMainButtonPressed:(id)sender;

@end
