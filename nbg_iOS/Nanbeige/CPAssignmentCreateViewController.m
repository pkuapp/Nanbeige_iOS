//
//  CPCreateAssignmentViewController.m
//  CP
//
//  Created by Wang Zhongyu on 12-7-21.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import "CPAssignmentCreateViewController.h"
#import "CPAssignmentDeadlineViewController.h"
#import "CPAssignmentCourseViewController.h"
#import "Environment.h"
#import <MobileCoreServices/UTCoreTypes.h>

#define DISPLAY_COURSE

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
    self.quickDialogTableView.bounces = YES;
	self.quickDialogTableView.deselectRowWhenViewAppears = YES;
}

-(NSMutableDictionary *)assignment
{
	if (_assignment == nil) {
		_assignment = [[NSMutableDictionary alloc] init];
		
		if (self.coursesData.count) [_assignment setObject:[[self.coursesData objectAtIndex:0] objectForKey:@"id"] forKey:@"course_id"];
		
		if (self.coursesData.count && self.weeksData.count) {
			[_assignment setObject:TYPE_ON_LESSON forKey:@"due_type"];
			[_assignment setObject:[self.weeksData objectAtIndex:0] forKey:@"due_lesson"];
		} else {
			[_assignment setObject:TYPE_ON_DATE forKey:@"due_type"];
			NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
			dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
			[_assignment setObject:[dateFormatter stringFromDate:[NSDate date]] forKey:@"due_date"];
		}
		
	}
	return _assignment;
}

-(NSDictionary *)course
{
	if (_coursesData.count && (_course == nil || bCourseChanged)) {
		NSNumber *course_id = [self.assignment valueForKey:@"course_id"];
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
	if (_coursesData.count && (_weeksData == nil || bCourseUpdated || bCourseChanged)) {
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
	self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStyleBordered target:nil action:nil];
	
	bCourseChanged = NO;
	bCourseUpdated = NO;
	
#ifndef DISPLAY_COURSE
	if (!self.coursesData.count) {
		// Hide cell for change course
		QSection *section = [self.root.sections objectAtIndex:1];
		[[section elements] removeLastObject];
	}
#endif
	
	if ([[self.assignment objectForKey:@"has_image"] boolValue]) {
		self.imageView.image = [NSKeyedUnarchiver unarchiveObjectWithData:[self.assignment objectForKey:@"image_data"]];
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
		CPAssignmentDeadlineViewController *advc = segue.destinationViewController;
		advc.assignment = self.assignment;
		advc.coursesData = self.coursesData;
		advc.weeksData = self.weeksData;
	} else if ([segue.identifier isEqualToString:@"AssignmentCourseSegue"]) {
		CPAssignmentCourseViewController *acvc = segue.destinationViewController;
		acvc.assignment = self.assignment;
		acvc.courseData = self.coursesData;
	}
}

- (void)refreshDataSource
{
	// Once Course Changed
	if (bCourseChanged && self.coursesData.count && self.weeksData.count && [[self.assignment objectForKey:@"due_type"] isEqualToString:TYPE_ON_LESSON])
		[self.assignment setObject:[_weeksData objectAtIndex:0] forKey:@"due_lesson"];
	
	NSString *due_display;
	NSString *content = [self.assignment valueForKey:@"content"];
	NSString *course_name = [self.course objectForKey:@"name"];
	
#ifdef DISPLAY_COURSE
	if (!course_name) course_name = @">_<还木有课程";
#endif
	
	if ([[self.assignment objectForKey:@"due_type"] isEqualToString:TYPE_ON_DATE]) {
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		formatter.dateFormat = @"M月d日 E HH:mm";
		NSDate *date = dateFromString([self.assignment objectForKey:@"due_date"], @"yyyy-MM-dd HH:mm:ss");
		if (!date) date = [NSDate date];
		due_display = [formatter stringFromDate:date];
	} else {
		due_display = [NSString stringWithFormat:@"第%@周 周%@ 课上", [[self.assignment objectForKey:@"due_lesson"] objectForKey:@"week"], [[self.assignment objectForKey:@"due_lesson"] objectForKey:@"day"]];
	}
	
	NSMutableDictionary *dict = [@{ @"due_display" : due_display } mutableCopy];
	if (content) [dict setObject:content forKey:@"content"];
	if (course_name) [dict setObject:course_name forKey:@"course_name"];
	
    [self.root bindToObject:dict];
	[self.quickDialogTableView reloadData];
	
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

	NSString *due_display = [assignmentInfo objectForKey:@"due_display"];
	NSString *content = [assignmentInfo objectForKey:@"content"];
	if (!content.length) content = @"施主有点懒，什么都没留下";
	
	[self.assignment setObject:content forKey:@"content"];
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
	
#ifdef DISPLAY_COURSE
	if (!self.coursesData.count) {
		UIStoryboard *sb = [UIStoryboard storyboardWithName:@"CPCoursesFlow" bundle:[NSBundle mainBundle]];
		[self.navigationController pushViewController:[sb instantiateInitialViewController] animated:YES];
		return ;
	}
#endif
	
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
		if (!self.imageView) {
			self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 20, 280, 280)];
			UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.quickDialogTableView.frame.size.height, 320, 320)];
			footerView.backgroundColor = tableBgColor1;
			[footerView addSubview:self.imageView];
			self.quickDialogTableView.tableFooterView = footerView;
		}
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
