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
	
    cell.imageView.image = self.image;
	cell.textLabel.text = self.title;
	cell.detailTextLabel.text = [self.value description];
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
    cell.selectionStyle = self.sections!= nil || self.controllerAction!=nil ? UITableViewCellSelectionStyleBlue: UITableViewCellSelectionStyleNone;
//	cell.accessoryType = self.sections!= nil || self.controllerAction!=nil ? (self.accessoryType != (int) nil ? self.accessoryType : UITableViewCellAccessoryDisclosureIndicator) : UITableViewCellAccessoryNone;
	
    return cell;
}

@end
