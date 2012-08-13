//
//  CPAssignmentCourseViewController.m
//  nbg_iOS
//
//  Created by ZongZiWang on 12-8-13.
//  Copyright (c) 2012年 wuhaotian. All rights reserved.
//

#import "CPAssignmentCourseViewController.h"

@interface CPAssignmentCourseViewController ()

@end

@implementation CPAssignmentCourseViewController

#pragma mark - Setter and Getter Methods

- (void)setQuickDialogTableView:(QuickDialogTableView *)aQuickDialogTableView {
    [super setQuickDialogTableView:aQuickDialogTableView];
    self.quickDialogTableView.backgroundView = nil;
    self.quickDialogTableView.backgroundColor = tableBgColor1;
    self.quickDialogTableView.bounces = YES;
	self.quickDialogTableView.deselectRowWhenViewAppears = YES;
}

#pragma mark - View Lifecycle

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self) {
		self.root = [[QRootElement alloc] initWithJSONFile:@"assignmentCourse"];
	}
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	[self.root bindToObject:@{ @"courses" : self.courseData }];
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
	NSDictionary *course = [self.courseData objectAtIndex:index];
	[self.assignment setObject:[course objectForKey:@"id"] forKey:@"course_id"];
	[self.navigationController popViewControllerAnimated:YES];
}

@end
