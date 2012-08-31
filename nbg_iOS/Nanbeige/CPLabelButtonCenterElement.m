//
//  CPLabelButtonCenterElement.m
//  CP
//
//  Created by ZongZiWang on 12-8-1.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import "CPLabelButtonCenterElement.h"

@implementation CPLabelButtonCenterElement

- (UITableViewCell *)getCellForTableView:(QuickDialogTableView *)tableView controller:(QuickDialogController *)controller {
    QTableViewCell *cell = (QTableViewCell *) [super getCellForTableView:tableView controller:controller];

	cell.textLabel.textAlignment = UITextAlignmentCenter;
	
	return cell;
}

@end
