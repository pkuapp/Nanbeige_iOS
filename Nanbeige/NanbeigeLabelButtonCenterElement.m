//
//  NanbeigeLabelButtonCenterElement.m
//  Nanbeige
//
//  Created by ZongZiWang on 12-8-1.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import "NanbeigeLabelButtonCenterElement.h"

@implementation NanbeigeLabelButtonCenterElement

- (UITableViewCell *)getCellForTableView:(QuickDialogTableView *)tableView controller:(QuickDialogController *)controller {
    QTableViewCell *cell = (QTableViewCell *) [super getCellForTableView:tableView controller:controller];
    
	for (UIView *subView in cell.contentView.subviews) {
		if (![subView isEqual:cell.textLabel]) [subView removeFromSuperview];
	}
    cell.accessoryType = UITableViewCellAccessoryNone;
	cell.textLabel.textAlignment = UITextAlignmentCenter;
	
	return cell;
}

@end
