//
//  CPLabelButtonElement.m
//  CP
//
//  Created by ZongZiWang on 12-8-1.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import "CPLabelButtonElement.h"

@implementation CPLabelButtonElement

- (UITableViewCell *)getCellForTableView:(QuickDialogTableView *)tableView controller:(QuickDialogController *)controller {
    QTableViewCell *cell = (QTableViewCell *) [super getCellForTableView:tableView controller:controller];
    
	cell.accessoryType = UITableViewCellAccessoryNone;
	
	return cell;
}

@end
