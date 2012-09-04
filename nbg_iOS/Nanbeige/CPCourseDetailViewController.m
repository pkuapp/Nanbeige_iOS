//
//  CPCourseDetailViewController.m
//  nbg_iOS
//
//  Created by ZongZiWang on 12-8-16.
//  Copyright (c) 2012年 wuhaotian. All rights reserved.
//

#import "CPCourseDetailViewController.h"

@interface CPCourseDetailViewController ()

@end

@implementation CPCourseDetailViewController

#pragma mark - Setter and Getter Methods

- (void)setQuickDialogTableView:(QuickDialogTableView *)aQuickDialogTableView {
    [super setQuickDialogTableView:aQuickDialogTableView];
	[self.quickDialogTableView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg-TableView"]]];
}

#pragma mark - View Lifecycle

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self) {
		self.root = [[QRootElement alloc] initWithJSONFile:@"courseDetail"];
		self.resizeWhenKeyboardPresented = YES;
	}
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	[self refreshDisplay];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)refreshDisplay
{
	CouchDatabase *localDatabase = [(CPAppDelegate *)([UIApplication sharedApplication].delegate) localDatabase];
	NSString *time = @"", *place = @"", *teachers = @"", *tas = @"";
	for (NSString *lessonDocumentID in self.course.lessons) {
		Lesson *lesson = [Lesson modelForDocument:[localDatabase documentWithID:lessonDocumentID]];
		time = [time stringByAppendingFormat:@"%@ %@%@-%@节 ", [Weekset weeksetWithID:lesson.weekset_id].name, [@[@"周日", @"周一", @"周二", @"周三", @"周四", @"周五", @"周六"] objectAtIndex:([lesson.day integerValue] % 7)], lesson.start, lesson.end];
		place = [place stringByAppendingFormat:@"%@ ", lesson.location];
	}
	for (NSString *teacher in self.course.teacher) {
		teachers = [teachers stringByAppendingFormat:@"%@ ", teacher];
	}
	for (NSString *ta in self.course.ta) {
		tas = [tas stringByAppendingFormat:@"%@ ", ta];
	}
	
	University *university = [University universityWithID:[[User sharedAppUser] university_id]];
	
	NSDictionary *dict = @{
	@"basic" : [@[ @{ @"title" : @"全称", @"value" : self.course.name }, @{ @"title" : @"编号", @"value" : self.course.orig_id }, @{ @"title" : @"学分", @"value" : self.course.credit }, @{ @"title" : @"教师", @"value" : teachers }, ] mutableCopy],
	@"extension" : @[ @{ @"title" : @"时间", @"value" :  time}, @{ @"title" : @"地点", @"value" : place } ],
	@"exam" : @[ @{ @"title" : @"考试", @"value" : @"API未提供" } ]};
	
	if ([university.support_ta boolValue]) {
		[[dict objectForKey:@"basic"] addObject:@{ @"title" : @"助教", @"value" : tas }];
	}
		
	[self.root bindToObject:dict];
}

@end
