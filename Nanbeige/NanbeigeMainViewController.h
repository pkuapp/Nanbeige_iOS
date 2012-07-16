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
#import "NanbeigeItsViewController.h"
#import "Environment.h"
#import "ModalAlert.h"
#import "AppUser.h"

@interface NanbeigeMainViewController : UITableViewController

@property (retain, nonatomic) NSArray * functionArray;
@property (retain, nonatomic) NSArray * functionOrder;
@property (retain, nonatomic) NSMutableDictionary *nibsRegistered;
@property (assign, nonatomic) NSObject<AppCoreDataProtocol,AppUserDelegateProtocol,ReachabilityProtocol,PABezelHUDDelegate> *delegate;

@property (retain, nonatomic) NanbeigeItsViewController *nivc;
@property (assign) NanbeigeIPGateHelper *connector;

-(IBAction)editFunctionOrder:(id)sender;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *editFunctionButton;
- (IBAction)calendarButtonPressed:(id)sender;
+ (NSString *)nibNameFromIdentifier:(NSString *)identifier;

@end
