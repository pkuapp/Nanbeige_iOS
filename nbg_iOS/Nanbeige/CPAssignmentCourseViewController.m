//
//  CPAssignmentCourseViewController.m
//  nbg_iOS
//
//  Created by ZongZiWang on 12-8-13.
//  Copyright (c) 2012年 wuhaotian. All rights reserved.
//

#import "CPAssignmentCourseViewController.h"
#import "Models+addon.h"

@interface CPAssignmentCourseViewController () {
	NSMutableArray *courses;
}

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
	
    NSArray *vcarray = self.navigationController.viewControllers;
    NSString *back_title = [[vcarray objectAtIndex:vcarray.count-2] title];
	self.navigationItem.leftBarButtonItem = [UIBarButtonItem styledBackBarButtonItemWithTitle:back_title target:self.navigationController selector:@selector(popViewControllerAnimated:)];
	
	courses = [@[] mutableCopy];
	for (int i = 0; i < self.coursesData.count; i++) {
		Course *course = [Course userCourseAtIndex:i courseList:self.coursesData];
		[courses addObject:@{ @"name" : course.name , @"id" : course.id}];
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

- (void)onCourseSelect:(id)sender
{
	NSUInteger index = [[[sender parentSection] elements] indexOfObject:sender];
	self.assignment.course_id = [[courses objectAtIndex:index] objectForKey:@"id"];
	self.assignment.course_name = [[courses objectAtIndex:index] objectForKey:@"name"];
	[self.navigationController popViewControllerAnimated:YES];
}

@end
