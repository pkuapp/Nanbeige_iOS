//
//  NanbeigeChangeMainOrderViewController.h
//  Nanbeige
//
//  Created by Wang Zhongyu on 12-7-16.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CPChangeMainOrderViewController : UITableViewController

@property (retain, nonatomic) NSArray * functionArray;
@property (retain, nonatomic) NSArray * functionOrder;

@property (retain, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *changeButton;
- (IBAction)onChangeButtonPressed:(id)sender;
- (IBAction)onCancelButtonPressed:(id)sender;

@end
