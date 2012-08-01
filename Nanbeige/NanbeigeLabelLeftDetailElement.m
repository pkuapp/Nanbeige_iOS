//
//  NanbeigeLabelLeftDetailElement.m
//  Nanbeige
//
//  Created by ZongZiWang on 12-8-1.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import "NanbeigeLabelLeftDetailElement.h"
#import "Environment.h"

@implementation NanbeigeLabelLeftDetailElement

- (UITableViewCell *)getCellForTableView:(QuickDialogTableView *)tableView controller:(QuickDialogController *)controller {
    QTableViewCell *cell = (QTableViewCell *) [super getCellForTableView:tableView controller:controller withStyle:UITableViewCellStyleValue1];
	
	self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 11, 68, 21)];
	self.titleLabel.textAlignment = UITextAlignmentRight;
	self.titleLabel.font = [UIFont boldSystemFontOfSize:15];
	self.titleLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
	self.titleLabel.adjustsFontSizeToFitWidth = YES;
	self.titleLabel.text = cell.textLabel.text;
	self.titleLabel.textColor = labelLeftColor;
	cell.textLabel.text = nil;
	[cell.contentView addSubview:self.titleLabel];
	
	self.valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(96, 10, 200, 21)];
	self.valueLabel.textAlignment = UITextAlignmentLeft;
	self.valueLabel.font = [UIFont boldSystemFontOfSize:17];
	self.valueLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
	self.titleLabel.adjustsFontSizeToFitWidth = YES;
	self.valueLabel.text = cell.detailTextLabel.text;
	cell.detailTextLabel.text = nil;
	[cell.contentView addSubview:self.valueLabel];
    
	cell.accessoryType = UITableViewCellAccessoryNone;
    return cell;
}

@end
