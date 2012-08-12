//
//  CPRoomRetractableSectionController.m
//  nbg_iOS
//
//  Created by ZongZiWang on 12-8-13.
//  Copyright (c) 2012年 wuhaotian. All rights reserved.
//

#import "CPRoomRetractableSectionController.h"
#import "Environment.h"

@interface CPRoomRetractableSectionController ()

@property (nonatomic, retain) NSArray* content;

@end

@implementation CPRoomRetractableSectionController

@synthesize content, title;

- (id)initWithArray:(NSArray *)array viewController:(UIViewController *)givenViewController {
    if ((self = [super initWithViewController:givenViewController])) {
        self.content = array;
    }
    return self;
}

#pragma mark -
#pragma mark Subclass

- (NSUInteger)contentNumberOfRow {
    return [self.content count];
}

- (NSString *)titleContentForRow:(NSUInteger)row {
    return [self.content objectAtIndex:row];
}

- (void)didSelectContentCellAtRow:(NSUInteger)row {
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow]
                                  animated:YES];
}

- (UITableViewCell *)titleCell
{
	UITableViewCell *cell = [super titleCell];
	cell.detailTextLabel.text = nil;
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
	UIView *separator = [[UIView alloc] init];
	separator.backgroundColor = separatorColor3;
	separator.frame = CGRectMake(0, cell.contentView.frame.size.height-TIMETABLESEPARATORHEIGHT, TIMETABLEWIDTH, TIMETABLESEPARATORHEIGHT);
	[cell.contentView addSubview:separator];
	separator = [[UIView alloc] init];
	separator.backgroundColor = separatorColor4;
	separator.frame = CGRectMake(0, 0, TIMETABLEWIDTH, TIMETABLESEPARATORHEIGHT);
	[cell.contentView addSubview:separator];
	
	return cell;
}

- (UITableViewCell *)contentCellForRow:(NSUInteger)row
{
	UITableViewCell *cell = [super contentCellForRow:row];
	cell.accessoryType = UITableViewCellAccessoryNone;
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	cell.textLabel.shadowColor = separatorColor5;
	cell.textLabel.shadowOffset = CGSizeMake(0, 1);
	cell.textLabel.textColor = [UIColor whiteColor];
	cell.textLabel.backgroundColor = [UIColor clearColor];
	cell.textLabel.font = [UIFont boldSystemFontOfSize:20];
	cell.contentView.backgroundColor = tableBgColor4;
	
	UIView *separator = [[UIView alloc] init];
	separator.backgroundColor = separatorColor5;
	separator.frame = CGRectMake(0, cell.contentView.frame.size.height-TIMETABLESEPARATORHEIGHT, TIMETABLEWIDTH, TIMETABLESEPARATORHEIGHT);
	[cell.contentView addSubview:separator];
	
	if (row > 0) {
		separator = [[UIView alloc] init];
		separator.backgroundColor = separatorColor6;
		separator.frame = CGRectMake(0, 0, TIMETABLEWIDTH, TIMETABLESEPARATORHEIGHT);
		[cell.contentView addSubview:separator];
	} else {
		separator = [[UIView alloc] init];
		separator.backgroundColor = [UIColor colorWithRed:145/255.0 green:145/255.0 blue:145/255.0 alpha:1.0];
		separator.frame = CGRectMake(0, 0, TIMETABLEWIDTH, TIMETABLESEPARATORHEIGHT);
		[cell.contentView addSubview:separator];
		separator = [[UIView alloc] init];
		separator.backgroundColor = [UIColor colorWithRed:133/255.0 green:133/255.0 blue:133/255.0 alpha:1.0];
		separator.frame = CGRectMake(0, TIMETABLESEPARATORHEIGHT, TIMETABLEWIDTH, TIMETABLESEPARATORHEIGHT);
		[cell.contentView addSubview:separator];
		separator = [[UIView alloc] init];
		separator.backgroundColor = [UIColor colorWithRed:143/255.0 green:143/255.0 blue:143/255.0 alpha:1.0];
		separator.frame = CGRectMake(0, TIMETABLESEPARATORHEIGHT * 2, TIMETABLEWIDTH, TIMETABLESEPARATORHEIGHT);
		[cell.contentView addSubview:separator];
		separator = [[UIView alloc] init];
		separator.backgroundColor = [UIColor colorWithRed:150/255.0 green:150/255.0 blue:150/255.0 alpha:1.0];
		separator.frame = CGRectMake(0, TIMETABLESEPARATORHEIGHT * 3, TIMETABLEWIDTH, TIMETABLESEPARATORHEIGHT);
		[cell.contentView addSubview:separator];
		
	}
	
	return cell;
}

- (void)dealloc {
    self.content = nil;
    self.title = nil;
}

@end
