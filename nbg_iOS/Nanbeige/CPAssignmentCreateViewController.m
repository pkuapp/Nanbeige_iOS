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
#import <MobileCoreServices/UTCoreTypes.h>

@interface CPAssignmentCreateViewController () {
	BOOL bCourseChanged;
	BOOL bCourseUpdated;
}

@end

@implementation CPAssignmentCreateViewController

#pragma mark - Setter and Getter Methods

- (void)setQuickDialogTableView:(QuickDialogTableView *)aQuickDialogTableView {
    [super setQuickDialogTableView:aQuickDialogTableView];
    self.quickDialogTableView.backgroundView = nil;
    self.quickDialogTableView.backgroundColor = tableBgColor1;
    self.quickDialogTableView.bounces = NO;
	self.quickDialogTableView.deselectRowWhenViewAppears = YES;
}

-(NSMutableDictionary *)assignment
{
	if (_assignment == nil) {
		_assignment = [[NSMutableDictionary alloc] init];
	}
	return _assignment;
}

-(NSDictionary *)course
{
	if (_course == nil || bCourseChanged) {
		NSNumber *course_id = [self.assignment valueForKey:@"course_id"];
		if (course_id == nil) course_id = [[self.coursesData objectAtIndex:0] objectForKey:@"id"];
		CouchDatabase *localDatabase = [(CPAppDelegate *)([[UIApplication sharedApplication] delegate]) localDatabase];
		CouchDocument *doc = [localDatabase documentWithID:[NSString stringWithFormat:@"course_%@", course_id]];
		_course = doc.properties;
		bCourseChanged = NO;
		bCourseUpdated = YES;
	}
	return _course;
}

- (NSArray *)weeksData
{
	if (_weeksData == nil || bCourseUpdated) {
		NSMutableArray *tempArray = [@[] mutableCopy];
		for (NSDictionary *lesson in [self.course objectForKey:@"lessons"]) {
			NSNumber *day = [lesson objectForKey:@"day"];
			for (NSNumber *week in [lesson objectForKey:@"week"]) {
				[tempArray addObject:@{ @"day" : day, @"week" : week }];
			}
		}
		_weeksData = [tempArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
			int week1 = [[obj1 objectForKey:@"week"] intValue];
			int day1 = [[obj1 objectForKey:@"day"] intValue];
			int week2 = [[obj2 objectForKey:@"week"] intValue];
			int day2 = [[obj2 objectForKey:@"day"] intValue];
			if (week1 < week2) return NSOrderedAscending;
			if (week1 > week2) return NSOrderedDescending;
			if (day1 < day2) return NSOrderedAscending;
			if (day1 > day2) return NSOrderedDescending;
			return NSOrderedSame;
		}];
		bCourseUpdated = NO;
	}
	return _weeksData;
}

#pragma mark - View Lifecycle

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self) {
		self.root = [[QRootElement alloc] initWithJSONFile:@"assignmentCreate"];
	}
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	
	self.navigationController.navigationBar.tintColor = navBarBgColor1;
	self.imageView.superview.backgroundColor = tableBgColor1;
	
	if (!_bCreate) self.title = @"修改作业计划";
	
	UIBarButtonItem *confirmButton = [[UIBarButtonItem alloc] initWithTitle:@"确认" style:UIBarButtonItemStyleBordered target:self action:@selector(onConfirm:)];
	UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleBordered target:self action:@selector(onCancel:)];
	self.navigationItem.rightBarButtonItem = confirmButton;
	self.navigationItem.leftBarButtonItem = cancelButton;
	
	bCourseChanged = NO;
	bCourseUpdated = NO;
	
	if ([[self.assignment objectForKey:@"has_image"] boolValue]) {
		self.imageView.image = [NSKeyedUnarchiver unarchiveObjectWithData:[self.assignment objectForKey:@"image_data"]];
	}
	if (![self.assignment objectForKey:@"due_type"]) {
		[self.assignment setObject:TYPE_ON_LESSON forKey:@"due_type"];
		[self.assignment setObject:[self.weeksData objectAtIndex:0] forKey:@"due_lesson"];
	}
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self refreshDataSource];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
//	[self.assignmentTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationFade];
	if (_bInitWithCamera) {
		_bInitWithCamera = NO;
		[self getMediaFromSource:UIImagePickerControllerSourceTypeCamera];
	}
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	[super prepareForSegue:segue sender:sender];
	if ([segue.identifier isEqualToString:@"AssignmentDeadlineSegue"]) {
		CPAssignmentDeadlineViewController *nadvc = segue.destinationViewController;
		nadvc.assignment = self.assignment;
		nadvc.pickerData = self.weeksData;
	}
}

- (void)refreshDataSource
{
	
	NSString *content = [self.assignment valueForKey:@"content"];
	NSString *course_name = [self.course objectForKey:@"name"];
	NSString *due_display;
	if ([[self.assignment objectForKey:@"due_type"] isEqualToString:TYPE_ON_DATE]) {
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		formatter.dateFormat = @"M月d日 E hh:mm";
		due_display = [formatter stringFromDate:[self.assignment objectForKey:@"due_date"]];
	} else {
		due_display = [NSString stringWithFormat:@"第%@周 周%@ 课上", [[self.assignment objectForKey:@"due_lesson"] objectForKey:@"week"], [[self.assignment objectForKey:@"due_lesson"] objectForKey:@"day"]];
	}
	
	NSMutableDictionary *dict = [@{ @"course_name" : course_name, @"due_display" : due_display } mutableCopy];
	if (content) [dict setObject:content forKey:@"content"];
	
    [self.root bindToObject:dict];
	[self.quickDialogTableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 1)] withRowAnimation:UITableViewRowAnimationFade];
	
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

- (void)onCancel:(id)sender {
	[self dismissModalViewControllerAnimated:YES];
}

- (void)onConfirm:(id)sender {
	NSMutableDictionary *assignmentInfo = [[NSMutableDictionary alloc] init];
    [self.root fetchValueUsingBindingsIntoObject:assignmentInfo];
	NSString *content = [assignmentInfo objectForKey:@"content"];
	NSString *course_name = [assignmentInfo objectForKey:@"course_name"];
	NSString *due_display = [assignmentInfo objectForKey:@"due_display"];
	
	if (!content) content = @"";
//	NSString *content = [[[self.assignmentTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]].contentView.subviews objectAtIndex:0] text];
//	NSString *due_display = [[[[self.assignmentTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]].contentView subviews] objectAtIndex:1] text];
	
	[self.assignment setObject:content forKey:@"content"];
	//[self.assignment setObject:course_id forKey:@"course_id"];
	[self.assignment setObject:due_display forKey:@"due_display"];
	if (_bCreate) [self.assignment setObject:[NSNumber numberWithBool:NO] forKey:@"finished"];
	
	if (self.imageView.image.size.width && self.imageView.image.size.height) {
		[self.assignment setObject:[NSNumber numberWithBool:YES] forKey:@"has_image"];
		NSData *imageData = [NSKeyedArchiver archivedDataWithRootObject:self.imageView.image];
		[self.assignment setObject:imageData forKey:@"image_data"];
	} else
		[self.assignment setObject:[NSNumber numberWithBool:NO] forKey:@"has_image"];
	
	[self.assignment setObject:@"assignment" forKey:@"doc_type"];
	
	CouchDatabase *database = [(CPAppDelegate *)([[UIApplication sharedApplication] delegate]) database];
	CouchDocument *doc;
	if ([self.assignment objectForKey:@"_id"]) doc = [database documentWithID:[self.assignment objectForKey:@"_id"]];
	else doc = [database untitledDocument];
	RESTOperation *op = [doc putProperties:self.assignment];
	if (![op wait]) {
		NSLog(@"%@", op.error);
	} else {
		[self dismissModalViewControllerAnimated:YES];
	}
}

- (void)onEditDue:(id)sender
{
	[self performSegueWithIdentifier:@"AssignmentDeadlineSegue" sender:self];
}

- (void)onEditCourse:(id)sender
{
	[self performSegueWithIdentifier:@"AssignmentCourseSegue" sender:self];
	bCourseChanged = YES;
}

- (void)onImageSelect:(id)sender
{
	UIActionSheet *menu = [[UIActionSheet alloc] initWithTitle:@"添加照片"
													  delegate:self
											 cancelButtonTitle:sCANCEL
										destructiveButtonTitle:nil
											 otherButtonTitles:@"拍照", @"选取照片", @"选取最近一张照片", nil];
	[menu showInView:self.view];
}

//- (IBAction)onConfirmCoursesBeforeResignFirstResponder:(id)sender {
//	bCourseChanged = YES;
////	[self.assignment setObject:[[_coursesData objectAtIndex:[_coursesPicker selectedRowInComponent:0]] objectForKey:@"id"] forKey:@"course_id"];
//	//[self.assignmentTableView reloadData];
//	[[[[self.assignmentTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]].contentView subviews] objectAtIndex:1] resignFirstResponder];
//}
//
//#pragma mark - Picker Data Source Methods
//
//- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
//{
//	return 1;
//}
//- (NSInteger)pickerView:(UIPickerView *)pickerView
//numberOfRowsInComponent:(NSInteger)component
//{
//	return [_coursesData count];
//}
//
//#pragma mark Picker Delegate Methods
//
//- (NSString *)pickerView:(UIPickerView *)pickerView
//			 titleForRow:(NSInteger)row
//			forComponent:(NSInteger)component
//{
//	return [[_coursesData objectAtIndex:row] objectForKey:@"name"];
//}
//
//#pragma mark - Table view data source
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//	return 2;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//	switch (section) {
//		case 0:
//			return  2;
//			break;
//		case 1:
//			return 2;
//			break;
//			
//		default:
//			break;
//	}
//	return 2;
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//	
//	NSUInteger row = [indexPath row];
//	NSUInteger section = [indexPath section];
//	NSString *identifier = [nibNames objectAtIndex:section * 2 + row];
//	
//	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
//	if (nil == cell) {
//		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
//	}
//	
//	if ([identifier isEqualToString:@"AssignmentDescriptionIdentifier"]) {
//		UITextView *tv = [cell.contentView.subviews objectAtIndex:0];
//		tv.text = [self.assignment valueForKey:@"content"];
//		if (tv.text == nil) tv.text = @"";
//	} else if ([identifier isEqualToString:@"AssignmentImageIdentifier"]) {
//		
//	} else if ([identifier isEqualToString:@"AssignmentTimeIdentifier"]) {
//		if ([[self.assignment objectForKey:@"due_type"] isEqualToNumber:TYPE_ON_DATE]) {
//			NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//			formatter.dateFormat = @"M月d日 E hh:mm";
//			[[[cell.contentView subviews] objectAtIndex:1] setText:[formatter stringFromDate:[self.assignment objectForKey:@"due_date"]]];
//		} else {
//			[[[cell.contentView subviews] objectAtIndex:1] setText:[NSString stringWithFormat:@"第%@周 周%@ 课上", [[self.assignment objectForKey:@"due_lesson"] objectForKey:@"week"], [[self.assignment objectForKey:@"due_lesson"] objectForKey:@"day"]]];
//		}
//	} else if ([identifier isEqualToString:@"AssignmentCourseIdentifier"]) {
//		
//		[[[cell.contentView subviews] objectAtIndex:1] setText:[self.course objectForKey:@"name"]];
//		
//		[[[cell.contentView subviews] objectAtIndex:1] setInputView:self.coursesPicker];
//		[[[cell.contentView subviews] objectAtIndex:1] setInputAccessoryView:self.coursesToolbar];
//		[[[cell.contentView subviews] objectAtIndex:1] setDelegate:self];
//	}
//	
//    return cell;
//}

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

#pragma mark - Table view delegate

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    // Navigation logic may go here. Create and push another view controller.
//	NSUInteger row = [indexPath row];
//	NSUInteger section = [indexPath section];
//	switch (section) {
//		case 0:
//			switch (row) {
//				case 0:
//					[[[[self.assignmentTableView cellForRowAtIndexPath:indexPath].contentView subviews] objectAtIndex:0] becomeFirstResponder];
//					break;
//				case 1:
//					[self performActionSheet];
//					break;
//				default:
//					break;
//			}
//			break;
//		case 1:
//			switch (row) {
//				case 0:
//					break;
//				case 1:
//					break;
//				default:
//					break;
//			}
//			break;
//		default:
//			break;
//	}
//	[tableView deselectRowAtIndexPath:indexPath animated:YES];
//}

#pragma mark - UIImagePickerController delegate methods
- (void)imagePickerController:(UIImagePickerController *)picker 
didFinishPickingMediaWithInfo:(NSDictionary *)info {
	// get last chosen photo or video
    self.lastChosenMediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([self.lastChosenMediaType isEqual:(NSString *)kUTTypeImage]) {
	    self.image = [info objectForKey:UIImagePickerControllerEditedImage];
    }
	// end picker
    [picker dismissModalViewControllerAnimated:YES];   
	if ([self.lastChosenMediaType isEqual:(NSString *)kUTTypeImage]) {
		self.imageView.image = self.image;
        self.imageView.hidden = NO;
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
