//
//  CPCoursesViewController.m
//  CP
//
//  Created by ZongZiWang on 12-8-8.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import "CPCoursesTableViewController.h"
#import "CPTimeTable.h"
#import "Environment.h"
#import "Models+addon.h"

@interface CPCoursesTableViewController () <CPTimeTableDelegate> {
	BOOL bViewDidLoad;
	NSDate *today;
	Course *courseSelected;
}

@end

@implementation CPCoursesTableViewController

- (University *)university
{
	if (_university == nil) {
		_university = [University universityWithID:[User sharedAppUser].university_id];
	}
	return _university;
}

- (NSArray *)courses
{
	if (_courses == nil) {
		_courses = [[Course userCourseListDocument] propertyForKey:@"value"];
	}
	return _courses;
}

- (NSMutableDictionary *)weeksets
{
	if (_weeksets == nil) {
		_weeksets = [[NSMutableDictionary alloc] init];
	}
	return _weeksets;
}

- (SYPaginatorView *)paginatorView
{
	if (_paginatorView == nil) [self _initialize];
	return _paginatorView;
}

#pragma mark - NSObject

- (id)init {
	if ((self = [super init])) {
		[self _initialize];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if ((self = [super initWithCoder:aDecoder])) {
		[self _initialize];
	}
	return self;
}


- (void)dealloc {
	self.paginatorView.dataSource = nil;
	self.paginatorView.delegate = nil;
}


#pragma mark - UIViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
		[self _initialize];
	}
	return self;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	
	self.view.BackgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg-TableView"]];
	
    NSArray *vcarray = self.navigationController.viewControllers;
    NSString *back_title = [[vcarray objectAtIndex:vcarray.count-2] title];
	self.tabBarController.navigationItem.leftBarButtonItem = [UIBarButtonItem styledBackBarButtonItemWithTitle:back_title target:self.tabBarController.navigationController selector:@selector(popViewControllerAnimated:)];
	
	self.paginatorView.frame = self.view.bounds;
	self.paginatorView.pageGapWidth = TIMETABLEPAGEGAPWIDTH;
	[self.view addSubview:self.paginatorView];
	
	today = [NSDate date];
	[self onTodayButtonPressed:nil];
	
	bViewDidLoad = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
//	NSDictionary *titleTextAttributes = @{ UITextAttributeTextColor : navBarTextColor1, UITextAttributeTextShadowOffset : [NSValue valueWithUIOffset:UIOffsetMake(0, 0)] , UITextAttributeFont : [UIFont boldSystemFontOfSize:17] };
//	[self.tabBarController.navigationController.navigationBar setTitleTextAttributes:titleTextAttributes];
	
	UIBarButtonItem *todayButton = [UIBarButtonItem styledBlueBarButtonItemWithTitle:@"今天" target:self selector:@selector(onTodayButtonPressed:)];
	self.tabBarController.navigationItem.rightBarButtonItem = todayButton;
	
	NSDate *day = [today dateByAddingTimeInterval:60*60*24*([self.paginatorView currentPageIndex] - TIMETABLEPAGEINDEX)];
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	formatter.dateFormat = @"E M月d日";
	NSString *dayDate = [formatter stringFromDate:day];
	NSInteger week = [Semester weekAtDate:day];
	if (!week) {
		self.tabBarController.title = [NSString stringWithFormat:@"放假^_^ %@", dayDate];
	} else {
		self.tabBarController.title = [NSString stringWithFormat:@"第%d周 %@", week, dayDate];
	}
	
	if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"courses_table_edited"] boolValue]) {
		self.courses = nil;
		[[NSUserDefaults standardUserDefaults] setObject:@0 forKey:@"courses_table_edited"];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
	
	CPTimeTable *currentPage = (CPTimeTable *)[self.paginatorView currentPage];
	[currentPage refreshDisplay];
	NSInteger pageIndex = [self.paginatorView currentPageIndex];
	if (pageIndex > 0) {
		CPTimeTable *view = (CPTimeTable *)[self.paginatorView pageForIndex:pageIndex - 1];
		[view refreshDisplay];
	}
	if (pageIndex + 1 < self.paginatorView.numberOfPages) {
		CPTimeTable *view = (CPTimeTable *)[self.paginatorView pageForIndex:pageIndex + 1];
		[view refreshDisplay];
	}
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	if (bViewDidLoad) {
		NSDate *day = [today dateByAddingTimeInterval:60*60*24*([self.paginatorView currentPageIndex] - TIMETABLEPAGEINDEX)];
		Semester *semester = [Semester semesterAtDate:day];
		if ([[University universityWithID:[User sharedAppUser].university_id].support_import_course boolValue] && ![[User sharedAppUser].course_imported containsObject:semester.id]) {
			[self.tabBarController performSegueWithIdentifier:@"CourseGrabberSegue" sender:self];
			bViewDidLoad = NO;
		} else if (![self.courses count]) {
			[self.tabBarController setSelectedIndex:1];
			bViewDidLoad = NO;
		}
	}
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
//	NSDictionary *titleTextAttributes = @{ UITextAttributeTextColor : navBarTextColor1, UITextAttributeTextShadowOffset : [NSValue valueWithUIOffset:UIOffsetMake(0, 0)] };
//	[self.tabBarController.navigationController.navigationBar setTitleTextAttributes:titleTextAttributes];
}

#pragma mark - Display

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
	    return YES;
	} else {
	    return (interfaceOrientation == UIInterfaceOrientationPortrait);
	}
}

#pragma mark - Button controllerAction

- (void)onTodayButtonPressed:(id)sender
{
	[self.paginatorView setCurrentPageIndex:TIMETABLEPAGEINDEX animated:YES];
	CPTimeTable *currentPage = (CPTimeTable *)[self.paginatorView currentPage];
	[currentPage refreshDisplay];
}

#pragma mark - Private

- (void)_initialize {
	_paginatorView = [[SYPaginatorView alloc] initWithFrame:CGRectZero];
	_paginatorView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_paginatorView.dataSource = self;
	_paginatorView.delegate = self;
}


#pragma mark - SYPaginatorDataSource

- (NSInteger)numberOfPagesForPaginatorView:(SYPaginatorView *)paginator {
	return TIMETABLEPAGENUMBER;
}


- (SYPageView *)paginatorView:(SYPaginatorView *)paginatorView viewForPageAtIndex:(NSInteger)pageIndex; {
	NSString *identifier = [[today dateByAddingTimeInterval:60*60*24*(pageIndex - TIMETABLEPAGEINDEX)] description];
	
	CPTimeTable *view = (CPTimeTable *)[paginatorView dequeueReusablePageWithIdentifier:identifier];
	NSDate *date = [today dateByAddingTimeInterval:60*60*24*(pageIndex - TIMETABLEPAGEINDEX)];
	if (!view) {
		view = [[CPTimeTable alloc] initWithDate:date];
	}
	
	view.university = self.university;
	view.delegate = self;
	
	return view;
}

- (NSArray *)coursesAtDate:(NSDate *)date
{
	Semester *semester = [Semester semesterAtDate:date];
	if (!semester) return nil;
	NSInteger week = [date timeIntervalSinceDate:semester.week_start] / 3600 / 24 / 7 + 1;
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	formatter.dateFormat = @"e";
	NSInteger weekday = ([[formatter stringFromDate:date] integerValue] + 5) % 7 + 1;
	return [self coursesAtWeekday:weekday Week:week Semester_id:semester.id];
}

- (NSArray *)coursesAtWeekday:(NSInteger)weekday
						 Week:(NSInteger)week
					 Semester_id:(NSNumber *)semester_id
{
	NSMutableArray *result = [[NSMutableArray alloc] init];
	CouchDatabase *localDatabase = [(CPAppDelegate *)([[UIApplication sharedApplication] delegate]) localDatabase];
	for (int i = 0; i < self.courses.count; i++) {
		Course *course = [Course userCourseAtIndex:i courseList:self.courses];
		if ([course.status isEqualToString:@"cancel"]) continue ;
		if (![course.semester_id isEqualToNumber:semester_id]) continue;
		for (NSString *lessonDocumentID in course.lessons) {
			Lesson *lesson = [Lesson modelForDocument:[localDatabase documentWithID:lessonDocumentID]];
			NSInteger lessonDay = [lesson.day integerValue];
			NSArray *weeks;
			if (lesson.weekset_id) {
				weeks = [self.weeksets objectForKey:lesson.weekset_id];
				if (weeks == nil) {
					weeks = [Weekset weeksetWithID:lesson.weekset_id].weeks;
					[self.weeksets setObject:weeks forKey:lesson.weekset_id];
				}
			} else weeks = [lesson.weeks componentsSeparatedByString:@","];
			if (lessonDay == weekday) {
				for (NSNumber *lessonWeek in weeks) {
					if ([lessonWeek integerValue] == week) {
						[result addObject:
						 @{@"start" : lesson.start,
						 @"end" : lesson.end,
						 @"name" : course.name,
						 @"location" : lesson.location,
						 @"courseDocumentID" : course.document.documentID}];
						break;
					}
				}
			}
		}
	}
	return [result sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
		if ([[obj1 objectForKey:@"start"] integerValue] < [[obj2 objectForKey:@"start"] integerValue]) return NSOrderedAscending;
		return NSOrderedDescending;
	}];
}

#pragma mark - SYPaginatorViewDelegate

- (void)paginatorView:(SYPaginatorView *)paginatorView didScrollToPageAtIndex:(NSInteger)pageIndex
{
	NSDate *day = [today dateByAddingTimeInterval:60*60*24*(pageIndex - TIMETABLEPAGEINDEX)];
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	formatter.dateFormat = @"E M月d日";
	NSString *dayDate = [formatter stringFromDate:day];
	
	NSInteger week = [Semester weekAtDate:day];
	if (!week) {
		self.tabBarController.title = [NSString stringWithFormat:@"放假^_^ %@", dayDate];
	} else {
		self.tabBarController.title = [NSString stringWithFormat:@"第%d周 %@", week, dayDate];
//		Semester *semester = [Semester semesterAtDate:day];
//		if ([[University universityWithID:[User sharedAppUser].university_id].support_import_course boolValue] && ![[User sharedAppUser].course_imported containsObject:semester.id]) {
//			[self.tabBarController performSegueWithIdentifier:@"CourseGrabberSegue" sender:self];
//			return ;
//		} else if (![self.courses count]) {
//			[self.tabBarController setSelectedIndex:1];
//			return ;
//		}
	}
	
	if (pageIndex > 0) {
		CPTimeTable *view = (CPTimeTable *)[paginatorView pageForIndex:pageIndex - 1];
		[view refreshDisplay];
	}
	if (pageIndex + 1 < paginatorView.numberOfPages) {
		CPTimeTable *view = (CPTimeTable *)[paginatorView pageForIndex:pageIndex + 1];
		[view refreshDisplay];
	}
}

#pragma mark - CPTimeTableDelegate

- (void)didChangeIfShowTime:(BOOL)isShowTime
{
	NSInteger pageIndex = [self.paginatorView currentPageIndex];
	if (pageIndex > 0) {
		CPTimeTable *view = (CPTimeTable *)[self.paginatorView pageForIndex:pageIndex - 1];
		[view.timeTable reloadData];
	}
	if (pageIndex + 1 < self.paginatorView.numberOfPages) {
		CPTimeTable *view = (CPTimeTable *)[self.paginatorView pageForIndex:pageIndex + 1];
		[view.timeTable reloadData];
	}
}

- (void)didDisplayCourse:(id)sender
{
	CouchDatabase *localDatabase = [(CPAppDelegate *)([UIApplication sharedApplication].delegate) localDatabase];
	courseSelected = [Course modelForDocument:[localDatabase documentWithID:[sender currentTitle]]];
	[self performSegueWithIdentifier:@"CourseSegue" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"CourseSegue"]) {
		[segue.destinationViewController setCourse:courseSelected];
	}
}

@end
