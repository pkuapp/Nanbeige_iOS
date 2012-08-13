//
//  CPAssignmentDeadlineViewController.m
//  CP
//
//  Created by Wang Zhongyu on 12-7-22.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import "CPAssignmentDeadlineViewController.h"
#import "Environment.h"

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
	
	if ([[self.assignment objectForKey:@"due_type"] isEqualToString:TYPE_ON_LESSON]) {
		[self.modeSegmentedControl setSelectedSegmentIndex:0];
		[self.deadlinePicker selectRow:[self.weeksData indexOfObject:[self.assignment objectForKey:@"due_lesson"]] inComponent:0 animated:YES];
	} else {
		[self.modeSegmentedControl setSelectedSegmentIndex:1];
		NSDate *date = dateFromString([self.assignment objectForKey:@"due_date"], @"yyyy-MM-dd HH:mm:ss");
		if (!date) date = [NSDate date];
		[self.datePicker setDate:date];
	}
	if (!self.coursesData.count) {
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

- (IBAction)onConfirm:(id)sender {
	
	if ([self.modeSegmentedControl selectedSegmentIndex] == ON_LESSON) {
		NSDictionary *due_lesson = [self.weeksData objectAtIndex:[self.deadlinePicker selectedRowInComponent:0]];
		[self.assignment setObject:TYPE_ON_LESSON forKey:@"due_type"];
		[self.assignment setObject:due_lesson forKey:@"due_lesson"];
		[self.assignment removeObjectForKey:@"due_date"];
	} else if ([self.modeSegmentedControl selectedSegmentIndex] == ON_DATE) {
		[self.assignment setObject:TYPE_ON_DATE forKey:@"due_type"];
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
		[self.assignment setObject:[dateFormatter stringFromDate:self.datePicker.date] forKey:@"due_date"];
		[self.assignment removeObjectForKey:@"due_lesson"];
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
	NSString *due_display = [NSString stringWithFormat:@"第%@周 周%@ 课上", [[self.weeksData objectAtIndex:row] objectForKey:@"week"], [[self.weeksData objectAtIndex:row] objectForKey:@"day"]];
	return due_display;
}

@end
