//
//  CPAssignmentCourseViewController.m
//  nbg_iOS
//
//  Created by ZongZiWang on 12-8-13.
//  Copyright (c) 2012年 wuhaotian. All rights reserved.
//

#import "CPAssignmentCourseViewController.h"
#import "Models+addon.h"

@interface CPAssignmentCourseViewController ()

@end

@implementation CPAssignmentCourseViewController

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
		self.root = [[QRootElement alloc] initWithJSONFile:@"assignmentCourse"];
		self.resizeWhenKeyboardPresented = YES;
	}
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	
	self.navigationItem.leftBarButtonItem = [UIBarButtonItem styledBackBarButtonItemWithTitle:@" 返回 " target:self selector:@selector(onBack:)];
	
	NSMutableArray *courses = [@[] mutableCopy];
	for (int i = 0; i < self.coursesData.count; i++) {
		Course *course = [Course userCourseAtIndex:i courseList:self.coursesData];
		[courses addObject:@{ @"name" : course.name }];
	}
	[self.root bindToObject:@{ @"courses" :  courses}];
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

- (void)onBack:(id)sender
{
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)onCourseSelect:(id)sender
{
	NSUInteger index = [[[sender parentSection] elements] indexOfObject:sender];
	Course *course = [Course userCourseAtIndex:index courseList:self.coursesData];
	self.assignment.course_id = course.id;
	self.assignment.course_name = course.name;
	[self.navigationController popViewControllerAnimated:YES];
}

@end
