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
	NSMutableArray *separators;
}

@property (nonatomic) int rowHeight;

@end

@implementation CPTimeTable

- (University *)university
{
	if (_university == nil) {
		_university = [University universityWithID:[User sharedAppUser].university_id];
	}
	return _university;
}

- (UITableView *)timeTable
{
	if (_timeTable == nil) {
		for (UIView *subview in [self subviews]) [subview removeFromSuperview];
		_timeTable = [[UITableView alloc] initWithFrame:self.bounds];
		_timeTable.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_timeTable.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg-TableView"]];
		_timeTable.bounces = FALSE;
		_timeTable.separatorStyle = UITableViewCellSeparatorStyleNone;
		_timeTable.delegate = self;
		_timeTable.dataSource = self;
		[self addSubview:_timeTable];
	}
	return _timeTable;
}

- (int)rowHeight
{
	if (_rowHeight == 0) {
		int rowNumber = [self.university.lessons_detail count];
		if (rowNumber) _rowHeight = TIMETABLEHEIGHT / rowNumber;
		else _rowHeight = TIMETABLEHEIGHT / 12;
	}
	return _rowHeight;
}

#pragma mark - View Lifecycle

- (id)initWithDate:(NSDate *)date
{
	if ((self = [self initWithReuseIdentifier:[date description]])) {
		_date = date;
		[self refreshDisplay];
	}
	return self;
}

- (void)refreshDisplay
{
	for (UIView *subview in [self.timeTable subviews]) [subview removeFromSuperview];
	
	int separatorNumber = [self lessonsCount];
	separators = [[NSMutableArray alloc] initWithCapacity:separatorNumber];
	for (int i = 0; i < separatorNumber; i++) {
		UIView *separator = [self addSeparatorAtOffsetY:[self separatorAtIndex:i] * self.rowHeight - TIMETABLESEPARATORHEIGHT WithColor:separatorColorNoCourseFooter];
		separator.tag = [self separatorAtIndex:i];
		[separators addObject:separator];
	}
	
	for (int index = 0; index < self.todayCourses.count; index++) {
		NSDictionary *course = [self.todayCourses objectAtIndex:index];
		NSInteger start = [[course objectForKey:kAPISTART] integerValue];
		NSInteger end = [[course objectForKey:kAPIEND] integerValue];
		NSString *name = [course objectForKey:kAPINAME];
		NSString *location = [course objectForKey:kAPILOCATION];
		for (UIView *separator in separators) {
			if (separator.superview && separator.tag >= start && separator.tag < end) {
				separator.backgroundColor = separatorColorCourseMiddle;
			}
		}
		
		[self addSeparatorAtOffsetY:(start - 1) * self.rowHeight WithColor:separatorColorCourseHeader1];
		[self addSeparatorAtOffsetY:(start - 1) * self.rowHeight + TIMETABLESEPARATORHEIGHT WithColor:separatorColorCourseHeader2];
		[self addSeparatorAtOffsetY:end * self.rowHeight - 3 * TIMETABLESEPARATORHEIGHT WithColor:separatorColorCourseFooter1];
		[self addSeparatorAtOffsetY:end * self.rowHeight - 2 * TIMETABLESEPARATORHEIGHT WithColor:separatorColorCourseFooter2];
		[self addSeparatorAtOffsetY:end * self.rowHeight - TIMETABLESEPARATORHEIGHT WithColor:separatorColorNoCourseFooter];
		
		if (index >= self.todayCourses.count - 1 || [[[self.todayCourses objectAtIndex:index + 1] objectForKey:@"start"] integerValue] > end + 1) {
			[self addSeparatorAtOffsetY:end * self.rowHeight WithColor:separatorColorCourseShadow1];
			[self addSeparatorAtOffsetY:end * self.rowHeight + TIMETABLESEPARATORHEIGHT WithColor:separatorColorCourseShadow2];
			[self addSeparatorAtOffsetY:end * self.rowHeight + 2 * TIMETABLESEPARATORHEIGHT WithColor:separatorColorCourseShadow3];
			[self addSeparatorAtOffsetY:end * self.rowHeight + 3 * TIMETABLESEPARATORHEIGHT WithColor:separatorColorCourseShadow4];
		}
		
		UIButton *courseButton = [[UIButton alloc] init];
		courseButton.frame = CGRectMake(TIMETABLELEFTPADDING, (start - 1) * self.rowHeight, TIMETABLEWIDTH - TIMETABLELEFTPADDING - TIMETABLERIGHTPADDING, self.rowHeight * (end - start + 1));
		[courseButton setTitle:[course objectForKey:@"courseDocumentID"] forState:UIControlStateHighlighted];
		[courseButton setTitleColor:[UIColor clearColor] forState:UIControlStateHighlighted];
		[courseButton addTarget:self.delegate action:@selector(didDisplayCourse:) forControlEvents:UIControlStateHighlighted];
		[self.timeTable addSubview:courseButton];
		
		UILabel *nameLabel = [[UILabel alloc] init];
		nameLabel.frame = CGRectMake(TIMETABLELEFTPADDING, (start - 1) * self.rowHeight, TIMETABLEWIDTH - TIMETABLELEFTPADDING - TIMETABLERIGHTPADDING, self.rowHeight);
		nameLabel.text = name;
		nameLabel.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.0];
		nameLabel.font = [UIFont boldSystemFontOfSize:17];
		[self.timeTable addSubview:nameLabel];
		
		UILabel *locationLabel = [[UILabel alloc] init];
		locationLabel.frame = CGRectMake(TIMETABLELEFTPADDING, start * self.rowHeight, TIMETABLEWIDTH - TIMETABLELEFTPADDING - TIMETABLERIGHTPADDING, self.rowHeight);
		locationLabel.text = location;
		locationLabel.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.0];
		locationLabel.font = [UIFont systemFontOfSize:13];
		[self.timeTable addSubview:locationLabel];
	}
	[self.timeTable reloadData];
}

- (UIView *)addSeparatorAtOffsetY:(CGFloat)y
					WithColor:(UIColor *)color
{
	UIView *separator = [[UIView alloc] init];
	separator.backgroundColor = color;
	separator.frame = CGRectMake(0, y, TIMETABLEWIDTH, TIMETABLESEPARATORHEIGHT);
	[self.timeTable addSubview:separator];
	return separator;
}

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
	if ((self = [super initWithReuseIdentifier:reuseIdentifier])) {
		
	}
	return self;
}

#pragma mark - Course Data Process

- (NSInteger)lessonsCount
{
	return [self.university.lessons_separators count];
}

- (NSInteger)separatorAtIndex:(NSInteger)index
{
	return [[self.university.lessons_separators objectAtIndex:index] integerValue];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.university.lessons_detail count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return self.rowHeight;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg-TableView"]];
	for (NSDictionary *course in self.todayCourses) {
		NSInteger start = [[course objectForKey:kAPISTART] integerValue];
		NSInteger end = [[course objectForKey:kAPIEND] integerValue];
		if (start - 1 <= indexPath.row && indexPath.row < end) {
			cell.backgroundColor = tableBgColorPlain;
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
	cell.textLabel.text = [NSString stringWithFormat:@"%@", [[self.university.lessons_detail objectAtIndex:indexPath.row] objectForKey:@"number"]];
	if ([[[NSUserDefaults standardUserDefaults] objectForKey:kSHOWTIME] boolValue]) {
		cell.detailTextLabel.text = [NSString stringWithFormat:@"%@-%@", [[self.university.lessons_detail objectAtIndex:indexPath.row] objectForKey:@"start"], [[self.university.lessons_detail objectAtIndex:indexPath.row] objectForKey:@"end"]];
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
	BOOL prevIsShowTime = [[[NSUserDefaults standardUserDefaults] objectForKey:kSHOWTIME] boolValue];
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:!prevIsShowTime] forKey:kSHOWTIME];
	[[NSUserDefaults standardUserDefaults] synchronize];
	if ([self.delegate respondsToSelector:@selector(didChangeIfShowTime:)]) {
		[self.delegate didChangeIfShowTime:!prevIsShowTime];
	}
	[tableView reloadData];
}

@end
