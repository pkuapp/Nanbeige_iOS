//
//  NanbeigeMainViewController.h
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
#import "AppUser.h"
#import "NanbeigeItsViewController.h"
#import "NanbeigeAssignmentViewController.h"
#import "NanbeigeLine2Button2Cell.h"
#import "NanbeigeLine3Button2Cell.h"

@interface NanbeigeMainViewController : UITableViewController <NanbeigeItsWidgetDelegateProtocol, NanbeigeLine2Button2DelegateProtocol, NanbeigeIPGateConnectDelegate, MBProgressHUDDelegate>

@property (retain, nonatomic) NSMutableArray * functionArray;
@property (retain, nonatomic) NSArray * functionOrder;
@property (retain, nonatomic) NSMutableDictionary *nibsRegistered;
@property (retain, nonatomic) MBProgressHUD *progressHub;
@property (assign, nonatomic) NSObject<AppCoreDataProtocol,AppUserDelegateProtocol,ReachabilityProtocol,PABezelHUDDelegate> *delegate;

@property (weak, nonatomic) NanbeigeLine3Button2Cell *itsCell;
@property (retain, nonatomic) NanbeigeItsViewController *nivc;
@property (strong, nonatomic) NanbeigeIPGateHelper *connector;
@property (retain, nonatomic) NSMutableDictionary* gateStateDictionary;
@property (retain, nonatomic) NSUserDefaults *defaults;
@property (assign, nonatomic) NSInteger numStatus;
@property (retain, nonatomic) NSString* Username;
@property (retain, nonatomic) NSString* Password;

@property (strong, nonatomic) NanbeigeAssignmentViewController *navc;

- (IBAction)calendarButtonPressed:(id)sender;
@end
