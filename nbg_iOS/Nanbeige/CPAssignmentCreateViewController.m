//
//  CPCreateAssignmentViewController.m
//  CP
//
//  Created by Wang Zhongyu on 12-7-21.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import "CPAssignmentCreateViewController.h"
#import "CPAssignmentDeadlineViewController.h"
#import "Environment.h"
#import "CPPickerLabel.h"
#import <MobileCoreServices/UTCoreTypes.h>

@interface CPAssignmentCreateViewController () {
	NSArray *nibNames;
}

@end

@implementation CPAssignmentCreateViewController
@synthesize imageView;
@synthesize assignmentTableView;
@synthesize coursesPicker;
@synthesize assignmentIndex;
@synthesize initWithCamera;
@synthesize bComplete;
@synthesize assignments;
@synthesize assignment = _assignment;
@synthesize weeksData;
@synthesize coursesData;
@synthesize coursesToolbar;
@synthesize lastChosenMediaType, image, imageFrame, imagePickerUsed;

#pragma mark - Setter and Getter Methods

-(NSMutableDictionary *)assignment
{
	if (_assignment == nil) {
		if (assignmentIndex == -1)
			_assignment = [[NSMutableDictionary alloc] init];
		else {
			_assignment = [[assignments objectAtIndex:assignmentIndex] mutableCopy];
		}
	}
	return _assignment;
}

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
	
	self.navigationController.navigationBar.tintColor = navBarBgColor1;
	self.navigationController.navigationBar.titleTextAttributes = @{ UITextAttributeTextColor : [UIColor blackColor], UITextAttributeTextShadowColor: [UIColor whiteColor] , UITextAttributeFont : [UIFont boldSystemFontOfSize:20], UITextAttributeTextShadowOffset : [NSValue valueWithUIOffset:UIOffsetMake(0, 0)]};
	
	nibNames = [[NSArray alloc] initWithObjects:@"AssignmentDescriptionIdentifier", @"AssignmentImageIdentifier", @"AssignmentTimeIdentifier", @"AssignmentCourseIdentifier", nil];
//	assignments = [[[NSUserDefaults standardUserDefaults] objectForKey:kASSIGNMENTS] mutableCopy];
	if (assignments == nil) assignments = [[NSMutableArray alloc] init];
	if (assignmentIndex != -1) {
		self.title = @"修改作业计划";
		if (bComplete) {
//			assignments = [[[NSUserDefaults standardUserDefaults] objectForKey:kCOMPLETEASSIGNMENTS] mutableCopy];
		}
	}
	weeksData = ASSIGNMENTDDLWEAKS;
	
	if ([[self.assignment objectForKey:@"has_image"] boolValue]) {
		self.imageView.image = [NSKeyedUnarchiver unarchiveObjectWithData:[self.assignment objectForKey:@"image"]];
	}
	
}

- (void)viewDidUnload
{
	[self setAssignmentTableView:nil];
	[self setImageView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[self.assignmentTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationFade];
	if (initWithCamera) {
		initWithCamera = NO;
		[self getMediaFromSource:UIImagePickerControllerSourceTypeCamera];
	}
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	[super prepareForSegue:segue sender:sender];
	if ([segue.identifier isEqualToString:@"DeadlineSegue"]) {
		CPAssignmentDeadlineViewController *nadvc = segue.destinationViewController;
		nadvc.assignment = self.assignment;
	}
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

- (IBAction)onCancel:(id)sender {
	[self dismissModalViewControllerAnimated:YES];
}

- (IBAction)onConfirm:(id)sender {
	
	[self.assignment setObject:[[[self.assignmentTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]].contentView.subviews objectAtIndex:0] text] forKey:@"content"];
	NSString *deadlineString = [[[[self.assignmentTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]].contentView subviews] objectAtIndex:1] text];
	[self.assignment setObject:deadlineString forKey:@"due"];
	NSString *course = [[[[self.assignmentTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]].contentView subviews] objectAtIndex:1] text];
#warning 进行id和课程名的数据库转换
	[self.assignment setObject:@0 forKey:@"course_id"];
	
	if (imageView.image.size.width && imageView.image.size.height) {
		[self.assignment setObject:[NSNumber numberWithBool:YES] forKey:@"has_image"];
		NSData *imageData = [NSKeyedArchiver archivedDataWithRootObject:imageView.image];
		[self.assignment setObject:imageData forKey:@"image"];
	} else {
		[self.assignment setObject:[NSNumber numberWithBool:NO] forKey:@"has_image"];
	}
	
	if (assignmentIndex == -1) {
		[self.assignment setObject:[NSNumber numberWithBool:NO] forKey:@"finished"];
		[assignments addObject:self.assignment];
//		[[NSUserDefaults standardUserDefaults] setObject:assignments forKey:kASSIGNMENTS];
	} else {
		[assignments replaceObjectAtIndex:assignmentIndex withObject:self.assignment];
		if (bComplete) {
//			[[NSUserDefaults standardUserDefaults] setObject:assignments forKey:kCOMPLETEASSIGNMENTS];
		} else {
//			[[NSUserDefaults standardUserDefaults] setObject:assignments forKey:kASSIGNMENTS];
		}
	}
	
	[self.assignment setObject:@"assignment" forKey:@"doc_type"];
	CouchDatabase *database = [(CPAppDelegate *)([[UIApplication sharedApplication] delegate]) database];
	CouchDocument *doc = [database untitledDocument];
	RESTOperation *op = [doc putProperties:self.assignment];
	if (![op wait]) {
		NSLog(@"%@", op.error);
	}
	
	[self dismissModalViewControllerAnimated:YES];
}

- (IBAction)onConfirmCoursesBeforeResignFirstResponder:(id)sender {
	[[[[self.assignmentTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]].contentView subviews] objectAtIndex:1] setText:[[coursesData objectAtIndex:[coursesPicker selectedRowInComponent:0]] objectForKey:kAPINAME]];
	[[[[self.assignmentTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]].contentView subviews] objectAtIndex:1] resignFirstResponder];
}
- (void)onConfirmCoursesAfterResignFirstResponder:(id)sender {
	[[[[self.assignmentTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]].contentView subviews] objectAtIndex:1] setText:[[coursesData objectAtIndex:[coursesPicker selectedRowInComponent:0]] objectForKey:kAPINAME]];
}

#pragma mark - Picker Data Source Methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component
{
	return [coursesData count];
}

#pragma mark Picker Delegate Methods

- (NSString *)pickerView:(UIPickerView *)pickerView
			 titleForRow:(NSInteger)row
			forComponent:(NSInteger)component
{
	return [[coursesData objectAtIndex:row] objectForKey:kAPINAME];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	switch (section) {
		case 0:
			return  2;
			break;
		case 1:
			return 2;
			break;
			
		default:
			break;
	}
	return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	
	NSUInteger row = [indexPath row];
	NSUInteger section = [indexPath section];
	NSString *identifier = [nibNames objectAtIndex:section * 2 + row];
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	if (nil == cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
	}
	
	if ([identifier isEqualToString:@"AssignmentDescriptionIdentifier"]) {
		UITextView *tv = [cell.contentView.subviews objectAtIndex:0];
		tv.text = [self.assignment valueForKey:@"content"];
		if (tv.text == nil) tv.text = @"";
	} else if ([identifier isEqualToString:@"AssignmentImageIdentifier"]) {
		
	} else if ([identifier isEqualToString:@"AssignmentTimeIdentifier"]) {
		if ([[self.assignment objectForKey:kASSIGNMENTDDLMODE] isEqualToNumber:[NSNumber numberWithInt:ONDATE]]) {
			NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
			formatter.dateFormat = @"M月d日 E hh:mm";
			[[[cell.contentView subviews] objectAtIndex:1] setText:[formatter stringFromDate:[self.assignment objectForKey:kASSIGNMENTDDLDATE]]];
		} else {
			[self.assignment setObject:[NSNumber numberWithInt:ONCLASS] forKey:kASSIGNMENTDDLMODE];
			if ([self.assignment objectForKey:kASSIGNMENTDDLWEEKS] == nil) {
#warning 根据课程属性及最近一次选择偏好，决定默认本周、下周、2周后
				[self.assignment setObject:[NSNumber numberWithInt:2] forKey:kASSIGNMENTDDLWEEKS];
			}
			[[[cell.contentView subviews] objectAtIndex:1] setText:[[weeksData objectAtIndex:[[self.assignment objectForKey:kASSIGNMENTDDLWEEKS] intValue]] stringByAppendingString:@"课上"]];
		}
	} else if ([identifier isEqualToString:@"AssignmentCourseIdentifier"]) {
		if ([self.assignment valueForKey:@"course_id"]) {
			[[[cell.contentView subviews] objectAtIndex:1] setText:[self.assignment valueForKey:@"course_id"]];
		} else {
#warning 选择课程列表中的课程
			[[[cell.contentView subviews] objectAtIndex:1] setText:[[coursesData objectAtIndex:0] objectForKey:kAPINAME]];
		}
		[[[cell.contentView subviews] objectAtIndex:1] setInputView:self.coursesPicker];
		[[[cell.contentView subviews] objectAtIndex:1] setInputAccessoryView:self.coursesToolbar];
		[[[cell.contentView subviews] objectAtIndex:1] setDelegate:self];
	}
	
    return cell;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }   
 }
 */

#pragma mark - ActionSheetDelegate Setup

- (void)actionSheet:(UIActionSheet *)actionSheet
clickedButtonAtIndex:(NSInteger)buttonIndex
{
	switch (buttonIndex) {
		case 0:
			NSLog(@"拍照");
			[self getMediaFromSource:UIImagePickerControllerSourceTypeCamera];
			break;
		case 1:
			NSLog(@"选取照片");
			[self getMediaFromSource:UIImagePickerControllerSourceTypePhotoLibrary];
			break;
		case 2:
			NSLog(@"选取最近一张照片");
			break;
			
		default:
			break;
	}
}

- (void) performActionSheet
{
	UIActionSheet *menu = [[UIActionSheet alloc] initWithTitle:@"添加照片" 
													  delegate:self 
											 cancelButtonTitle:sCANCEL 
										destructiveButtonTitle:nil 
											 otherButtonTitles:@"拍照", @"选取照片", @"选取最近一张照片", nil];
	[menu showInView:self.view];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
	NSUInteger row = [indexPath row];
	NSUInteger section = [indexPath section];
	switch (section) {
		case 0:
			switch (row) {
				case 0:
					[[[[self.assignmentTableView cellForRowAtIndexPath:indexPath].contentView subviews] objectAtIndex:0] becomeFirstResponder];
					break;
				case 1:
					[self performActionSheet];
					break;
				default:
					break;
			}
			break;
		case 1:
			switch (row) {
				case 0:
					[self performSegueWithIdentifier:@"DeadlineSegue" sender:self];
					break;
				case 1:
					[[[[self.assignmentTableView cellForRowAtIndexPath:indexPath].contentView subviews] objectAtIndex:1] becomeFirstResponder];
					break;
				default:
					break;
			}
			break;
		default:
			break;
	}
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UIImagePickerController delegate methods
- (void)imagePickerController:(UIImagePickerController *)picker 
didFinishPickingMediaWithInfo:(NSDictionary *)info {
	// get last chosen photo or video
    self.lastChosenMediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([lastChosenMediaType isEqual:(NSString *)kUTTypeImage]) {
	    self.image = [info objectForKey:UIImagePickerControllerEditedImage];
    }
	// end picker
    [picker dismissModalViewControllerAnimated:YES];   
	if ([lastChosenMediaType isEqual:(NSString *)kUTTypeImage]) {
		imageView.image = image;
        imageView.hidden = NO;
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	// end picker
	self.imagePickerUsed = NO;
    [picker dismissModalViewControllerAnimated:YES];
}

#pragma mark - Setup UIImagePickerController

- (void)getMediaFromSource:(UIImagePickerControllerSourceType)sourceType {
	// get Media from camera or photo library
    NSArray *mediaTypes = [UIImagePickerController
                           availableMediaTypesForSourceType:sourceType];
    if ([UIImagePickerController isSourceTypeAvailable:
         sourceType] && [mediaTypes count] > 0) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeImage, nil];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = sourceType;
        [self presentModalViewController:picker animated:YES];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] 
                              initWithTitle:@"Error accessing media" 
                              message:@"Device doesn’t support that media source." 
                              delegate:nil 
                              cancelButtonTitle:@"Drat!" 
                              otherButtonTitles:nil];
        [alert show];
    }
}

@end
