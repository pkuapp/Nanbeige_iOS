//
//  CPAssignmentViewController.h
//  CP
//
//  Created by Wang Zhongyu on 12-7-17.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CouchCocoa/CouchUITableSource.h>
#import "CPAssignmentNoImageCell.h"

@interface CPAssignmentViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, CPAssignmentCellDelegate, UIAlertViewDelegate> {
	CouchLiveQuery* _query;
	CouchLiveQuery* _completeQuery;
}
@property (strong, nonatomic) NSMutableArray *assignments;
@property (strong, nonatomic) NSMutableArray *completeAssignments;
@property (strong, nonatomic) NSMutableDictionary *nibsRegistered;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) CouchDatabase *database;

@property (strong, nonatomic) NSNumber *courseIdFilter;
@property (assign, nonatomic) BOOL bInitShowComplete;

@property (weak, nonatomic) IBOutlet UISegmentedControl *completeSegmentedControl;
- (IBAction)onAssignmentCompleteChanged:(id)sender;

@end
