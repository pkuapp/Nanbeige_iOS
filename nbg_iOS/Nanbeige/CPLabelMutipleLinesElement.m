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
    
	UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:cell.contentView.frame];
	NSInteger rowNumber = [[[self parentSection] elements] count];
	NSInteger row = [[[self parentSection] elements] indexOfObject:self];
	if (rowNumber == 1)
		bgImgView.image = [[UIImage imageNamed:@"cell-full"] resizableImageWithCapInsets:UIEdgeInsetsMake(11, 10, 10, 10)];
	else if (row == 0)
		bgImgView.image = [[UIImage imageNamed:@"cell-top"] resizableImageWithCapInsets:UIEdgeInsetsMake(11, 10, 1, 10)];
	else if (row == rowNumber - 1)
		bgImgView.image = [[UIImage imageNamed:@"cell-bottom"] resizableImageWithCapInsets:UIEdgeInsetsMake(1, 10, 10, 10)];
	else
		bgImgView.image = [[UIImage imageNamed:@"cell-middle"] resizableImageWithCapInsets:UIEdgeInsetsMake(1, 10, 1, 10)];
	cell.backgroundView = bgImgView;
	
	cell.textLabel.numberOfLines = 0;
	cell.accessoryType = UITableViewCellAccessoryNone;
	
	return cell;
}

@end
