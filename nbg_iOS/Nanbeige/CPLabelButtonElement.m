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
    
	UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:cell.contentView.frame];
	NSInteger rowNumber = [[[self parentSection] elements] count];
	NSInteger row = [[[self parentSection] elements] indexOfObject:self];
	if (rowNumber == 1)
		bgImgView.image = [[UIImage imageNamed:@"cell-btn-full"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
	else if (row == 0)
		bgImgView.image = [[UIImage imageNamed:@"cell-btn-top"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
	else if (row == rowNumber - 1)
		bgImgView.image = [[UIImage imageNamed:@"cell-btn-bottom"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
	else
		bgImgView.image = [[UIImage imageNamed:@"cell-btn-middle"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
	cell.backgroundView = bgImgView;
	
	cell.accessoryType = UITableViewCellAccessoryNone;
	
	return cell;
}

@end
