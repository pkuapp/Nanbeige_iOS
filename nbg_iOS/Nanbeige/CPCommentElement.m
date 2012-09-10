//
//  CPCommentElement.m
//  nbg_iOS
//
//  Created by ZongZiWang on 12-8-30.
//  Copyright (c) 2012年 wuhaotian. All rights reserved.
//

#import "CPCommentElement.h"

@implementation CPCommentElement

- (UITableViewCell *)getCellForTableView:(QuickDialogTableView *)tableView controller:(QuickDialogController *)controller {
    QTableViewCell *cell = (QTableViewCell *) [super getCellForTableView:tableView controller:controller];
	
	UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:cell.contentView.frame];
	UIImageView *selectedBgImgView = [[UIImageView alloc] initWithFrame:cell.contentView.frame];
	NSInteger rowNumber = [[[self parentSection] elements] count];
	NSInteger row = [[[self parentSection] elements] indexOfObject:self];
	if (rowNumber == 1) {
		bgImgView.image = [[UIImage imageNamed:@"cell-full"] resizableImageWithCapInsets:UIEdgeInsetsMake(11, 10, 10, 10)];
		selectedBgImgView.image = [[UIImage imageNamed:@"cell-pressed-full"] resizableImageWithCapInsets:UIEdgeInsetsMake(11, 10, 10, 10)];
	} else if (row == 0) {
		bgImgView.image = [[UIImage imageNamed:@"cell-top"] resizableImageWithCapInsets:UIEdgeInsetsMake(11, 10, 1, 10)];
		selectedBgImgView.image = [[UIImage imageNamed:@"cell-pressed-top"] resizableImageWithCapInsets:UIEdgeInsetsMake(11, 10, 1, 10)];
	} else if (row == rowNumber - 1) {
		bgImgView.image = [[UIImage imageNamed:@"cell-bottom"] resizableImageWithCapInsets:UIEdgeInsetsMake(1, 10, 10, 10)];
		selectedBgImgView.image = [[UIImage imageNamed:@"cell-pressed-bottom"] resizableImageWithCapInsets:UIEdgeInsetsMake(1, 10, 10, 10)];
	} else {
		bgImgView.image = [[UIImage imageNamed:@"cell-middle"] resizableImageWithCapInsets:UIEdgeInsetsMake(1, 10, 1, 10)];
		selectedBgImgView.image = [[UIImage imageNamed:@"cell-pressed-middle"] resizableImageWithCapInsets:UIEdgeInsetsMake(1, 10, 1, 10)];
	}
	cell.selectedBackgroundView = selectedBgImgView;
	cell.backgroundView = bgImgView;
	
	cell.textLabel.text = self.title;
	cell.textLabel.numberOfLines = 0;
	cell.detailTextLabel.text = self.value;
	cell.detailTextLabel.numberOfLines = 0;
	
	cell.textLabel.textColor = [UIColor colorWithWhite:0.2 alpha:1.0];
	cell.textLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.5];
	cell.textLabel.shadowOffset = CGSizeMake(0.0, 1.0);
	cell.textLabel.highlightedTextColor = cell.textLabel.textColor;
	cell.detailTextLabel.textColor = [UIColor colorWithWhite:0.2 alpha:1.0];
	cell.detailTextLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.5];
	cell.detailTextLabel.shadowOffset = CGSizeMake(0.0, 1.0);
	cell.detailTextLabel.highlightedTextColor = cell.detailTextLabel.textColor;
	
	return cell;
}

- (CGFloat)getRowHeightForTableView:(QuickDialogTableView *)tableView
{
	CGSize boundingSize = CGSizeMake(270, CGFLOAT_MAX);
	UIFont *labelFont = [UIFont systemFontOfSize:17];
	CGSize labelStringSize = [self.title sizeWithFont:labelFont
									constrainedToSize:boundingSize
										lineBreakMode:UILineBreakModeWordWrap];
	self.height = labelStringSize.height + 23;
    return self.height > 44 ? self.height : 44;
}

@end
