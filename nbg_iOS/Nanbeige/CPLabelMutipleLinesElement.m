//
//  CPLabelMutipleLinesElement.m
//  nbg_iOS
//
//  Created by ZongZiWang on 12-8-16.
//  Copyright (c) 2012年 wuhaotian. All rights reserved.
//

#import "CPLabelMutipleLinesElement.h"

@implementation CPLabelMutipleLinesElement

- (UITableViewCell *)getCellForTableView:(QuickDialogTableView *)tableView controller:(QuickDialogController *)controller {
    QTableViewCell *cell = (QTableViewCell *) [super getCellForTableView:tableView controller:controller];
    
	cell.accessoryType = UITableViewCellAccessoryNone;
	
	return cell;
}

@end
