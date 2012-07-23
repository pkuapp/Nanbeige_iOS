//
//  NanbeigeAssignmentDeadlineViewController.m
//  Nanbeige
//
//  Created by Wang Zhongyu on 12-7-22.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import "NanbeigeAssignmentDeadlineViewController.h"
#import "Environment.h"

@interface NanbeigeAssignmentDeadlineViewController ()

@end

@implementation NanbeigeAssignmentDeadlineViewController
@synthesize deadlinePicker;
@synthesize modeSegmentedControl;
@synthesize datePicker;
@synthesize modeLabel;
@synthesize assignment;
@synthesize pickerData;

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
	if ([[assignment objectForKey:kASSIGNMENTDDLMODE] isEqualToNumber:[NSNumber numberWithInt:ONCLASS]]) {
		[modeSegmentedControl setSelectedSegmentIndex:0];
		//[deadlinePicker selectRow:[[assignment objectForKey:kASSIGNMENTDDLWEEKS] intValue] inComponent:0 animated:YES];
	} else {
		[modeSegmentedControl setSelectedSegmentIndex:1];
		if ([assignment objectForKey:kASSIGNMENTDDLDATE]) {
			[datePicker setDate:[assignment objectForKey:kASSIGNMENTDDLDATE]];
		}
	}
	[self onModeChange:modeSegmentedControl];
	self.pickerData = ASSIGNMENTDDLWEAKS;
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
	return [pickerData objectAtIndex:row];
}

- (IBAction)onConfirm:(id)sender {
	
	if ([modeSegmentedControl selectedSegmentIndex] == 0) {
		[assignment setObject:[NSNumber numberWithInt:ONCLASS] forKey:kASSIGNMENTDDLMODE];
		NSInteger row = [deadlinePicker selectedRowInComponent:0];
		[assignment setObject:[NSNumber numberWithInt:row] forKey:kASSIGNMENTDDLWEEKS];
	} else if ([modeSegmentedControl selectedSegmentIndex] == 1) {
		[assignment setObject:[NSNumber numberWithInt:ONDATE] forKey:kASSIGNMENTDDLMODE];
		[assignment setObject:datePicker.date forKey:kASSIGNMENTDDLDATE];
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
@end
