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
@synthesize deadlinePicker;
@synthesize modeSegmentedControl;
@synthesize datePicker;
@synthesize modeLabel;
@synthesize assignment;
@synthesize pickerData;

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
	if ([[assignment objectForKey:@"due_type"] isEqualToString:TYPE_ON_LESSON]) {
		[modeSegmentedControl setSelectedSegmentIndex:0];
//		[deadlinePicker selectRow:[[assignment objectForKey:kASSIGNMENTDDLWEEKS] intValue] inComponent:0 animated:YES];
	} else {
		[modeSegmentedControl setSelectedSegmentIndex:1];
		if ([assignment objectForKey:@"due_date"]) {
			[datePicker setDate:[assignment objectForKey:@"due_date"]];
		}
	}
	[self onModeChange:modeSegmentedControl];
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
	
	if ([modeSegmentedControl selectedSegmentIndex] == ON_LESSON) {
		[assignment setObject:TYPE_ON_LESSON forKey:@"due_type"];
		[assignment setObject:[self.pickerData objectAtIndex:[deadlinePicker selectedRowInComponent:0]] forKey:@"due_lesson"];
	} else if ([modeSegmentedControl selectedSegmentIndex] == ON_DATE) {
		[assignment setObject:TYPE_ON_DATE forKey:@"due_type"];
		[assignment setObject:datePicker.date forKey:@"due_date"];
	}
	[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onModeChange:(UISegmentedControl *)sender {
	if (sender.selectedSegmentIndex == 0) {
		modeLabel.text = @"截止于所选这周的课堂上";
		datePicker.hidden = YES;
		deadlinePicker.hidden = NO;
	} else if (sender.selectedSegmentIndex == 1) {
		modeLabel.text = @"截止于所选时刻";
		datePicker.hidden = NO;
		deadlinePicker.hidden = YES;
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
	return [pickerData count];
}

#pragma mark Picker Delegate Methods

- (NSString *)pickerView:(UIPickerView *)pickerView
			 titleForRow:(NSInteger)row
			forComponent:(NSInteger)component
{
	NSString *due_display = [NSString stringWithFormat:@"第%@周 周%@ 课上", [[pickerData objectAtIndex:row] objectForKey:@"week"], [[pickerData objectAtIndex:row] objectForKey:@"day"]];
	return due_display;
}

@end
