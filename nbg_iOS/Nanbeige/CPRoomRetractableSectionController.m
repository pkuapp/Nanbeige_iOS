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
	
	[self addSeparatorAtView:cell.contentView OffsetY:0 WithColor:separatorColorTitleNoContentHeader1];
	[self addSeparatorAtView:cell.contentView OffsetY:TIMETABLESEPARATORHEIGHT WithColor:separatorColorTitleNoContentHeader2];
	if ([self numberOfRow] == 1)
	[self addSeparatorAtView:cell.contentView OffsetY:cell.contentView.frame.size.height - TIMETABLESEPARATORHEIGHT WithColor:separatorColorTitleNoContentFooter];
	else [self addSeparatorAtView:cell.contentView OffsetY:cell.contentView.frame.size.height - TIMETABLESEPARATORHEIGHT WithColor:separatorColorTitleHasContentFooter];
	
	return cell;
}

- (UITableViewCell *)contentCellForRow:(NSUInteger)row
{
	UITableViewCell *cell = [super contentCellForRow:row];
	cell.accessoryType = UITableViewCellAccessoryNone;
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	cell.textLabel.shadowColor = [UIColor whiteColor];
	cell.textLabel.shadowOffset = CGSizeMake(0, 1);
	cell.textLabel.textColor = [UIColor colorWithRed:120/255.0 green:116/255.0 blue:100/255.0 alpha:1.0];
	cell.textLabel.backgroundColor = [UIColor clearColor];
	cell.textLabel.font = [UIFont boldSystemFontOfSize:20];
	cell.contentView.backgroundColor = tableBgColorGrouped;
	
	if (row == 0) {
		[self addSeparatorAtView:cell.contentView OffsetY:0 WithColor:separatorColorContentHeader1];
		[self addSeparatorAtView:cell.contentView OffsetY:TIMETABLESEPARATORHEIGHT WithColor:separatorColorContentHeader2];
		[self addSeparatorAtView:cell.contentView OffsetY:2*TIMETABLESEPARATORHEIGHT WithColor:separatorColorContentHeader3];
	} else {
		[self addSeparatorAtView:cell.contentView OffsetY:0 WithColor:separatorColorContentMiddleHeader];
	}
	
	if (row == [self contentNumberOfRow] - 1) {
		[self addSeparatorAtView:cell.contentView OffsetY:cell.contentView.frame.size.height - 2 * TIMETABLESEPARATORHEIGHT WithColor:separatorColorContentFooter1];
		[self addSeparatorAtView:cell.contentView OffsetY:cell.contentView.frame.size.height - TIMETABLESEPARATORHEIGHT WithColor:separatorColorContentFooter2];
//		[self addSeparatorAtView:cell.contentView OffsetY:cell.contentView.frame.size.height WithColor:separatorColorTitleHasContentHeader];
	} else {
		[self addSeparatorAtView:cell.contentView OffsetY:cell.contentView.frame.size.height - TIMETABLESEPARATORHEIGHT WithColor:separatorColorContentMiddleFooter];
	}
	
	return cell;
}

- (UIView *)addSeparatorAtView:(UIView *)view
					   OffsetY:(CGFloat)y
						WithColor:(UIColor *)color
{
	UIView *separator = [[UIView alloc] init];
	separator.backgroundColor = color;
	separator.frame = CGRectMake(0, y, TIMETABLEWIDTH, TIMETABLESEPARATORHEIGHT);
	[view addSubview:separator];
	return separator;
}

- (void)dealloc {
    self.content = nil;
    self.title = nil;
}

@end
