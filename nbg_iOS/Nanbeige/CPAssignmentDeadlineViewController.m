//
//  CPAssignmentDeadlineViewController.m
//  CP
//
//  Created by Wang Zhongyu on 12-7-22.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import "CPAssignmentDeadlineViewController.h"
#import "Environment.h"
#import "Assignment.h"

@interface CPAssignmentDeadlineViewController ()

@end

@implementation CPAssignmentDeadlineViewController

#pragma mark - View Lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	
	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg-TableView"]];
	
	self.navigationItem.leftBarButtonItem = [UIBarButtonItem styledBackBarButtonItemWithTitle:@" 返回 " target:self selector:@selector(onBack:)];
	self.navigationItem.rightBarButtonItem = [UIBarButtonItem styledBlueBarButtonItemWithTitle:@"确认" target:self selector:@selector(onConfirm:)];
	
	if ([self.assignment.due_type isEqualToString:TYPE_ON_LESSON]) {
		[self.modeSegmentedControl setSelectedSegmentIndex:0];
		[self.deadlinePicker selectRow:[self.weeksData indexOfObject:self.assignment.due_lesson] inComponent:0 animated:YES];
	} else {
		[self.modeSegmentedControl setSelectedSegmentIndex:1];
		[self.datePicker setDate:self.assignment.due_date];
	}
	if (!self.weeksData.count) {
		[self.modeSegmentedControl setSelectedSegmentIndex:1];
		self.modeSegmentedControl.hidden = YES;
		self.title = @"选择截止时间";
	}
	
	[self onModeChange:self.modeSegmentedControl];
}

- (void)viewDidUnload
{
	[self setDatePicker:nil];
	[self setModeLabel:nil];
	[self setDeadlinePicker:nil];
	[self setModeSegmentedControl:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
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

- (void)onBack:(id)sender
{
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)onConfirm:(id)sender {
	if ([self.modeSegmentedControl selectedSegmentIndex] == ON_LESSON) {
		NSDictionary *due_lesson = [self.weeksData objectAtIndex:[self.deadlinePicker selectedRowInComponent:0]];
		self.assignment.due_type = TYPE_ON_LESSON;
		self.assignment.due_lesson = due_lesson;
		self.assignment.due_date = nil;
		self.assignment.due_display = [[self class] displayFromWeekDay:self.assignment.due_lesson];
	} else if ([self.modeSegmentedControl selectedSegmentIndex] == ON_DATE) {
		self.assignment.due_type = TYPE_ON_DATE;
		self.assignment.due_date = self.datePicker.date;
		self.assignment.due_lesson = nil;
		self.assignment.due_display = [[self class] displayFromDate:self.assignment.due_date];
	}
	[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onModeChange:(UISegmentedControl *)sender {
	if (sender.selectedSegmentIndex == 0) {
		self.modeLabel.text = @"截止于所选这周的课堂上";
		self.datePicker.hidden = YES;
		self.deadlinePicker.hidden = NO;
	} else if (sender.selectedSegmentIndex == 1) {
		self.modeLabel.text = @"截止于所选时刻";
		self.datePicker.hidden = NO;
		self.deadlinePicker.hidden = YES;
	}
}

#pragma mark - Picker Data Source Methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component
{
	return [self.weeksData count];
}

#pragma mark Picker Delegate Methods

- (NSString *)pickerView:(UIPickerView *)pickerView
			 titleForRow:(NSInteger)row
			forComponent:(NSInteger)component
{
	NSString *due_display = [[self class] displayFromWeekDay:[self.weeksData objectAtIndex:row]];
	return due_display;
}

+ (NSString *)displayFromWeekDay:(NSDictionary *)weekDay
{
	return [NSString stringWithFormat:@"第%@周 %@ 第%@-%@节课上", [weekDay objectForKey:@"week"], [@[@"周日", @"周一", @"周二", @"周三", @"周四", @"周五", @"周六"] objectAtIndex:([[weekDay objectForKey:@"day"] integerValue] % 7)], [weekDay objectForKey:@"start"], [weekDay objectForKey:@"end"]];
}

+ (NSString *)displayFromDate:(NSDate *)date
{
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	formatter.dateFormat = @"M月d日 E HH:mm";
	return [formatter stringFromDate:date];
}

@end
