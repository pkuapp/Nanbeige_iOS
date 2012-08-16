//
//  CPMainViewController.h
//  CP
//
//  Created by Wang Zhongyu on 12-7-9.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"





#import "CPIPGateHelper.h"
#import "Environment.h"

#import "CPItsViewController.h"
#import "CPAssignmentViewController.h"
#import "CPRoomsViewController.h"
#import "CPLine2Button2Cell.h"
#import "CPLine3Button2Cell.h"

@interface CPMainViewController : UITableViewController <CPItsWidgetDelegateProtocol, CPLine2Button2DelegateProtocol, CPIPGateConnectDelegate, MBProgressHUDDelegate>

@property (retain, nonatomic) NSMutableArray * functionArray;
@property (retain, nonatomic) NSArray * functionOrder;
@property (retain, nonatomic) NSMutableDictionary *nibsRegistered;
@property (retain, nonatomic) MBProgressHUD *progressHub;
@property (assign, nonatomic) NSObject *delegate;
@property (weak, nonatomic) CPLine3Button2Cell *itsCell;
@property (retain, nonatomic) CPItsViewController *nivc;
//@property (strong, nonatomic) CPIPGateHelper *connector;
@property (retain, nonatomic) NSMutableDictionary* gateStateDictionary;
@property (retain, nonatomic) NSUserDefaults *defaults;
@property (assign, nonatomic) NSInteger numStatus;
@property (retain, nonatomic) NSString* Username;
@property (retain, nonatomic) NSString* Password;

@property (strong, nonatomic) CPAssignmentViewController *navc;
@property (strong, nonatomic) CPRoomsViewController *nrvc;

@end
