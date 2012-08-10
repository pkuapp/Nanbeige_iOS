//
//  NanbeigeAssignmentViewController.h
//  Nanbeige
//
//  Created by Wang Zhongyu on 12-7-17.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CPAssignmentNoImageCell.h"

@interface CPAssignmentViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, CPAssignmentCellDelegate, UIAlertViewDelegate>
@property (strong, nonatomic) NSMutableArray *assignments;
@property (strong, nonatomic) NSMutableArray *completeAssignments;
@property (strong, nonatomic) NSMutableDictionary *nibsRegistered;
@property (strong, nonatomic) NSMutableDictionary *completeNibsRegistered;
@property (weak, nonatomic) IBOutlet UITableView *assignmentsTableView;
@property (weak, nonatomic) IBOutlet UITableView *completeAssignmentsTableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *completeSegmentedControl;
- (IBAction)onAssignmentCompleteChanged:(id)sender;

@end
