//
//  NanbeigeMainViewController.h
//  Nanbeige
//
//  Created by Wang Zhongyu on 12-7-9.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NanbeigeAppDelegate.h"
#import "AppUser.h"

@interface NanbeigeMainViewController : UITableViewController

@property (strong, nonatomic) NSMutableArray * functionArray;
@property (strong, nonatomic) NSMutableArray * functionOrder;
@property (strong, nonatomic) NSMutableDictionary *nibsRegistered;
@property (nonatomic, readonly) NanbeigeAppDelegate *delegate;

-(IBAction)editFunctionOrder:(id)sender;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *editFunctionButton;
+ (NSString *)nibNameFromIdentifier:(NSString *)identifier;

@end
