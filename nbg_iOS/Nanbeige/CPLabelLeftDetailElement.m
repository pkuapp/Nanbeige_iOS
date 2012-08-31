//
//  CPLabelLeftDetailElement.m
//  CP
//
//  Created by ZongZiWang on 12-8-1.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import "CPLabelLeftDetailElement.h"
#import "Environment.h"

@implementation CPLabelLeftDetailElement

- (UITableViewCell *)getCellForTableView:(QuickDialogTableView *)tableView controller:(QuickDialogController *)controller {
	
	UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"reuseIdentifier"];
	
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
	
    cell.imageView.image = self.image;
	cell.textLabel.text = self.title;
	cell.detailTextLabel.text = [self.value description];
	
    cell.selectionStyle = self.sections!= nil || self.controllerAction!=nil ? UITableViewCellSelectionStyleBlue: UITableViewCellSelectionStyleNone;
//	cell.accessoryType = self.sections!= nil || self.controllerAction!=nil ? (self.accessoryType != (int) nil ? self.accessoryType : UITableViewCellAccessoryDisclosureIndicator) : UITableViewCellAccessoryNone;
	
    return cell;
}

@end
