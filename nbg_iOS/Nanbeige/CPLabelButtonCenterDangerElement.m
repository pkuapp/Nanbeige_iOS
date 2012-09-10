//
//  CPLabelButtonCenterDangerElement.m
//  nbg_iOS
//
//  Created by ZongZiWang on 12-8-31.
//  Copyright (c) 2012年 wuhaotian. All rights reserved.
//

#import "CPLabelButtonCenterDangerElement.h"

@implementation CPLabelButtonCenterDangerElement

- (UITableViewCell *)getCellForTableView:(QuickDialogTableView *)tableView controller:(QuickDialogController *)controller {
    QTableViewCell *cell = (QTableViewCell *) [super getCellForTableView:tableView controller:controller];
    
	UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:cell.contentView.frame];
	bgImgView.image = [[UIImage imageNamed:@"cell-btn-danger-full"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
	cell.backgroundView = bgImgView;
	UIImageView *selectedBgImgView = [[UIImageView alloc] initWithFrame:cell.contentView.frame];
	selectedBgImgView.image = [[UIImage imageNamed:@"cell-btn-pressed-danger-full"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
	cell.selectedBackgroundView = selectedBgImgView;
	
	cell.textLabel.textColor = [UIColor colorWithWhite:1.0 alpha:1.0];
	cell.textLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.4];
	cell.textLabel.shadowOffset = CGSizeMake(0.0, -1.0);
	cell.textLabel.highlightedTextColor = cell.textLabel.textColor;
	cell.detailTextLabel.textColor = [UIColor colorWithWhite:1.0 alpha:1.0];
	cell.detailTextLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.4];
	cell.detailTextLabel.shadowOffset = CGSizeMake(0.0, -1.0);
	cell.detailTextLabel.highlightedTextColor = cell.detailTextLabel.textColor;
	
	return cell;
}

@end
