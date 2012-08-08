//
//  NanbeigeTimeTable.m
//  Nanbeige
//
//  Created by ZongZiWang on 12-8-8.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import "NanbeigeTimeTable.h"
#import "Environment.h"

@interface NanbeigeTimeTable () <UITableViewDataSource, UITableViewDelegate> {
	BOOL bShowTime;
	int rowHeight;
}

@end

@implementation NanbeigeTimeTable
@synthesize timeTable = _timeTable;
@synthesize date = _date;
@synthesize university = _university;
@synthesize courses = _courses;

- (void)setDate:(NSDate *)date
{
	if (_date != date) {
		
		[_timeTable reloadData];
		
		int separatorNumber = [[[_university objectForKey:kAPILESSONS] objectForKey:kAPISEPARATORS] count];
		NSMutableArray *separators = [[NSMutableArray alloc] initWithCapacity:separatorNumber];
		for (int i = 0; i < separatorNumber; i++) {
			UIView *separator = [[UIView alloc] init];
			separator.backgroundColor = separatorColor1;
			separator.frame = CGRectMake(0, [[[[_university objectForKey:kAPILESSONS] objectForKey:kAPISEPARATORS] objectAtIndex:i] intValue] * rowHeight - TIMETABLESEPARATORHEIGHT / 2, TIMETABLEWIDTH, TIMETABLESEPARATORHEIGHT);
			[separators addObject:separator];
			[_timeTable addSubview:separator];
		}
		
	}
}

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
	if ((self = [super initWithReuseIdentifier:reuseIdentifier])) {
		_university = [[NSUserDefaults standardUserDefaults] objectForKey:kTEMPUNIVERSITY];
		_courses = [[NSUserDefaults standardUserDefaults] objectForKey:kTEMPCOURSES];
		
		_timeTable = [[UITableView alloc] initWithFrame:self.bounds];
		_timeTable.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_timeTable.backgroundColor = tableBgColor2;
		_timeTable.bounces = FALSE;
		_timeTable.separatorStyle = UITableViewCellSeparatorStyleNone;
		_timeTable.delegate = self;
		_timeTable.dataSource = self;
		[self addSubview:_timeTable];
		
		rowHeight = TIMETABLEHEIGHT / [[[[_university objectForKey:kAPILESSONS] objectForKey:kAPICOUNT] objectForKey:kAPITOTAL] integerValue];
		
		bShowTime = NO;
	}
	return self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [[[[_university objectForKey:kAPILESSONS] objectForKey:kAPICOUNT] objectForKey:kAPITOTAL] integerValue];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return rowHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *identifier = @"identifier";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	if (nil == cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
	}
	
	cell.textLabel.text = [NSString stringWithFormat:@"%@", [[[[_university objectForKey:kAPILESSONS] objectForKey:kAPIDETAIL] objectAtIndex:indexPath.row] objectForKey:kAPINUMBER]];
	if (bShowTime) {
		cell.detailTextLabel.text = [NSString stringWithFormat:@"%@-%@", [[[[_university objectForKey:kAPILESSONS] objectForKey:kAPIDETAIL] objectAtIndex:indexPath.row] objectForKey:kAPISTART], [[[[_university objectForKey:kAPILESSONS] objectForKey:kAPIDETAIL] objectAtIndex:indexPath.row] objectForKey:kAPIEND]];
	} else {
		cell.detailTextLabel.text = nil;
	}
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	bShowTime = !bShowTime;
	[tableView reloadData];
}

@end
