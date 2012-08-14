//
//  CPTimeTable.m
//  CP
//
//  Created by ZongZiWang on 12-8-8.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import "CPTimeTable.h"
#import "Environment.h"
#import "Coffeepot.h"
#import "Models+addon.h"

@interface CPTimeTable () <UITableViewDataSource, UITableViewDelegate> {
	int rowHeight;
	NSMutableArray *separators;
	NSArray *todayCourses;
}

@end

@implementation CPTimeTable
@synthesize timeTable = _timeTable;
@synthesize date = _date;
@synthesize university = _university;
@synthesize courses = _courses;

#pragma mark - View Lifecycle

- (id)initWithDate:(NSDate *)date
{
	if ((self = [self initWithReuseIdentifier:[date description]])) {
	
		_date = date;
		
		int separatorNumber = [self lessonsCount];
		separators = [[NSMutableArray alloc] initWithCapacity:separatorNumber];
		for (int i = 0; i < separatorNumber; i++) {
			UIView *separator = [[UIView alloc] init];
			separator.backgroundColor = separatorColor1;
			separator.frame = CGRectMake(0, [self separatorAtIndex:i] * rowHeight - TIMETABLESEPARATORHEIGHT, TIMETABLEWIDTH, TIMETABLESEPARATORHEIGHT);
			separator.tag = [self separatorAtIndex:i];
			[separators addObject:separator];
			[_timeTable addSubview:separator];
		}
		
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		formatter.dateFormat = @"w";
		NSInteger week = [[formatter stringFromDate:_date] integerValue] - [[formatter stringFromDate:[NSDate date]] integerValue] + 1;
		formatter.dateFormat = @"e";
		NSInteger weekday = ([[formatter stringFromDate:_date] integerValue] + 5) % 7 + 1;
		
		todayCourses = [self coursesAtWeekday:weekday Week:week];
		
		for (int index = 0; index < todayCourses.count; index++) {
			NSDictionary *course = [todayCourses objectAtIndex:index];
			NSInteger start = [[course objectForKey:kAPISTART] integerValue];
			NSInteger end = [[course objectForKey:kAPIEND] integerValue];
			NSString *name = [course objectForKey:kAPINAME];
			NSString *location = [course objectForKey:kAPILOCATION];
			for (UIView *separator in separators) {
				if (separator.superview && separator.tag >= start && separator.tag < end) {
					[separator removeFromSuperview];
				}
			}
			
			UIView *courseStartSeparator = [[UIView alloc] init];
			courseStartSeparator.backgroundColor = separatorColor1;
			courseStartSeparator.frame = CGRectMake(0, (start - 1) * rowHeight - TIMETABLESEPARATORHEIGHT, TIMETABLEWIDTH, TIMETABLESEPARATORHEIGHT);
			[_timeTable addSubview:courseStartSeparator];
			courseStartSeparator = [[UIView alloc] init];
			courseStartSeparator.backgroundColor = separatorColor2;
			courseStartSeparator.frame = CGRectMake(0, (start - 1) * rowHeight, TIMETABLEWIDTH, TIMETABLESEPARATORHEIGHT);
			[_timeTable addSubview:courseStartSeparator];
			
			UIView *courseEndSeparator = [[UIView alloc] init];
			courseEndSeparator.backgroundColor = separatorColor1;
			courseEndSeparator.frame = CGRectMake(0, end * rowHeight - TIMETABLESEPARATORHEIGHT, TIMETABLEWIDTH, TIMETABLESEPARATORHEIGHT);
			[_timeTable addSubview:courseEndSeparator];
			
			UILabel *nameLabel = [[UILabel alloc] init];
			nameLabel.frame = CGRectMake(TIMETABLELEFTPADDING, (start - 1) * rowHeight, TIMETABLEWIDTH - TIMETABLELEFTPADDING * 2, rowHeight);
			nameLabel.text = name;
			nameLabel.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.0];
			nameLabel.font = [UIFont boldSystemFontOfSize:17];
			[_timeTable addSubview:nameLabel];
			
			UILabel *locationLabel = [[UILabel alloc] init];
			locationLabel.frame = CGRectMake(TIMETABLELEFTPADDING, start * rowHeight, TIMETABLEWIDTH - TIMETABLELEFTPADDING * 2, rowHeight);
			locationLabel.text = location;
			locationLabel.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.0];
			locationLabel.font = [UIFont systemFontOfSize:13];
			[_timeTable addSubview:locationLabel];
		}
	}
	return self;
}

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
	if ((self = [super initWithReuseIdentifier:reuseIdentifier])) {
		
		CouchDatabase *localDatabase = [(CPAppDelegate *)([[UIApplication sharedApplication] delegate]) localDatabase];
		CouchDocument *doc = [localDatabase documentWithID:[NSString stringWithFormat:@"university%@", [[User sharedAppUser] university_id]]];
		_university = [doc properties];
		
		doc = [localDatabase documentWithID:@"courses"];
		_courses = [[doc properties] objectForKey:@"value"];
		
		for (UIView *subview in [self subviews]) {
			[subview removeFromSuperview];
		}
		_timeTable = [[UITableView alloc] initWithFrame:self.bounds];
		_timeTable.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_timeTable.backgroundColor = tableBgColor2;
		_timeTable.bounces = FALSE;
		_timeTable.separatorStyle = UITableViewCellSeparatorStyleNone;
		_timeTable.delegate = self;
		_timeTable.dataSource = self;
		[self addSubview:_timeTable];
		
		NSInteger rowNumber = [[[_university objectForKey:kAPILESSONS] objectForKey:kAPIDETAIL] count];
		if (rowNumber) rowHeight = TIMETABLEHEIGHT / rowNumber;
		else rowHeight = TIMETABLEHEIGHT / 12;
	}
	return self;
}

#pragma mark - Course Data Process

- (NSInteger)lessonsCount
{
	return [[[_university objectForKey:kAPILESSONS] objectForKey:kAPISEPARATORS] count];
}

- (NSInteger)separatorAtIndex:(NSInteger)index
{
	return [[[[_university objectForKey:kAPILESSONS] objectForKey:kAPISEPARATORS] objectAtIndex:index] integerValue];
}

- (NSArray *)coursesAtWeekday:(NSInteger)weekday
						 Week:(NSInteger)week
{
	NSMutableArray *result = [[NSMutableArray alloc] init];
	for (NSDictionary *course in _courses) {
		for (NSDictionary *lesson in [course objectForKey:kAPILESSONS]) {
			NSInteger lessonDay = [[lesson objectForKey:kAPIDAY] integerValue];
			NSArray *weeks = [lesson objectForKey:kAPIWEEK];
			if (lessonDay == weekday && [weeks containsObject:[NSNumber numberWithInteger:week]]) {
				[result addObject:
				     @{kAPISTART : [lesson objectForKey:kAPISTART],
						 kAPIEND : [lesson objectForKey:kAPIEND],
						kAPINAME : [course objectForKey:kAPINAME],
					kAPILOCATION : [lesson objectForKey:kAPILOCATION]}];
			}
		}
	}
	return result;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [[[_university objectForKey:kAPILESSONS] objectForKey:kAPIDETAIL] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return rowHeight;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = tableBgColor2;
	for (NSDictionary *course in todayCourses) {
		NSInteger start = [[course objectForKey:kAPISTART] integerValue];
		NSInteger end = [[course objectForKey:kAPIEND] integerValue];
		if (start - 1 <= indexPath.row && indexPath.row < end) {
			cell.backgroundColor = tableBgColor3;
			break ;
		}
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *identifier = @"identifier";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	if (nil == cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
	}
	
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	cell.textLabel.text = [NSString stringWithFormat:@"%@", [[[[_university objectForKey:kAPILESSONS] objectForKey:kAPIDETAIL] objectAtIndex:indexPath.row] objectForKey:kAPINUMBER]];
	if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSHOWTIME] boolValue]) {
		cell.detailTextLabel.text = [NSString stringWithFormat:@"%@-%@", [[[[_university objectForKey:kAPILESSONS] objectForKey:kAPIDETAIL] objectAtIndex:indexPath.row] objectForKey:kAPISTART], [[[[_university objectForKey:kAPILESSONS] objectForKey:kAPIDETAIL] objectAtIndex:indexPath.row] objectForKey:kAPIEND]];
		cell.detailTextLabel.textColor = timeColor1;
	} else {
		cell.detailTextLabel.text = nil;
	}
	
	return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:![[[NSUserDefaults standardUserDefaults] objectForKey:kSHOWTIME] boolValue]] forKey:kSHOWTIME];
	[tableView reloadData];
}

@end
