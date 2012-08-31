//
//  CPCreateAssignmentViewController.m
//  CP
//
//  Created by Wang Zhongyu on 12-7-21.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import <MobileCoreServices/UTCoreTypes.h>
#import "CPAssignmentCreateViewController.h"
#import "CPAssignmentDeadlineViewController.h"
#import "CPAssignmentCourseViewController.h"
#import "Environment.h"
#import "Models+addon.h"

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
	[self.quickDialogTableView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg-TableView"]]];
}

- (void)setAssignment:(Assignment *)assignment
{
	_assignment = assignment;
	if (self.bCreate) {
		_assignment.finished = [NSNumber numberWithBool:NO];
		if (self.coursesData.count) {
			if (self.courseIdFilter) {
				Course *course = [Course courseWithID:self.courseIdFilter];
				_assignment.course_id = course.id;
				_assignment.course_name = course.name;
			} else {
				Course *course = [Course userCourseAtIndex:0 courseList:self.coursesData];
				_assignment.course_id = course.id;
				_assignment.course_name = course.name;
			}
		}

		if (self.coursesData.count && self.weeksData.count) {
			_assignment.due_type = TYPE_ON_LESSON;
			_assignment.due_lesson = [self.weeksData objectAtIndex:0];
			_assignment.due_display = [CPAssignmentDeadlineViewController displayFromWeekDay:_assignment.due_lesson];
		} else {
			_assignment.due_type = TYPE_ON_DATE;
			_assignment.due_date = [NSDate date];
			_assignment.due_display = [CPAssignmentDeadlineViewController displayFromDate:_assignment.due_date];
		}
	}
}

- (CouchDatabase *)localDatabase
{
	if (_localDatabase == nil) {
		_localDatabase = [(CPAppDelegate *)([[UIApplication sharedApplication] delegate]) localDatabase];
	}
	return _localDatabase;
}

- (Course *)course
{
	if (_coursesData.count && (_course == nil || bCourseChanged)) {
		NSNumber *course_id = self.assignment.course_id;
		_course = [Course courseWithID:course_id];
		bCourseChanged = NO;
		bCourseUpdated = YES;
	}
	return _course;
}

- (NSArray *)weeksData
{
	if (_coursesData.count && (_weeksData == nil || bCourseUpdated || bCourseChanged)) {
		NSMutableArray *tempArray = [@[] mutableCopy];
		for (NSString *lessonDocumentID in self.course.lessons) {
			Lesson *lesson = [Lesson modelForDocument:[self.localDatabase documentWithID:lessonDocumentID]];
			NSNumber *day = lesson.day;
			NSNumber *start = lesson.start;
			NSNumber *end = lesson.end;
			for (NSNumber *week in [Weekset weeksetWithID:lesson.weekset_id].weeks) {
				[tempArray addObject:@{ @"day" : day, @"week" : week , @"start" : start, @"end" : end }];
			}
		}
		_weeksData = [tempArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
			int week1 = [[obj1 objectForKey:@"week"] intValue];
			int day1 = [[obj1 objectForKey:@"day"] intValue];
			int week2 = [[obj2 objectForKey:@"week"] intValue];
			int day2 = [[obj2 objectForKey:@"day"] intValue];
			int start1 = [[obj1 objectForKey:@"start"] intValue];
			int start2 = [[obj2 objectForKey:@"start"] intValue];
			int end1 = [[obj1 objectForKey:@"end"] intValue];
			int end2 = [[obj2 objectForKey:@"end"] intValue];
			if (week1 < week2) return NSOrderedAscending;
			if (week1 > week2) return NSOrderedDescending;
			if (day1 < day2) return NSOrderedAscending;
			if (day1 > day2) return NSOrderedDescending;
			if (start1 < start2) return NSOrderedAscending;
			if (start1 > start2) return NSOrderedDescending;
			if (end1 < end2) return NSOrderedAscending;
			if (end1 > end2) return NSOrderedDescending;
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
	
	self.imageView.superview.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg-TableView"]];
	
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
	
	if ([self.assignment.has_image boolValue]) {
		self.imageView.image = [NSKeyedUnarchiver unarchiveObjectWithData:self.assignment.image_data];
	}
	QEntryElement *contentElement = [[[self.root.sections objectAtIndex:0] elements] objectAtIndex:0];
	contentElement.textValue = self.assignment.content;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	if (!self.coursesData.count) self.coursesData = [[Course userCourseListDocument] propertyForKey:@"value"];
	[self refreshDisplay];
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
		acvc.coursesData = self.coursesData;
	}
}

- (void)refreshDisplay
{
	// Once Course Changed
	if (bCourseChanged && self.coursesData.count && [self.assignment.due_type isEqualToString:TYPE_ON_LESSON]) {
		if (self.weeksData.count) {
			self.assignment.due_lesson = [self.weeksData objectAtIndex:0];
			self.assignment.due_display = [CPAssignmentDeadlineViewController displayFromWeekDay:self.assignment.due_lesson];
		} else {
			self.assignment.due_type = TYPE_ON_DATE;
			self.assignment.due_date = [NSDate date];
			self.assignment.due_display = [CPAssignmentDeadlineViewController displayFromDate:self.assignment.due_date];
		}
	}
	
	QEntryElement *contentElement = [[[self.root.sections objectAtIndex:0] elements] objectAtIndex:0];
	NSString *content = contentElement.textValue;
	NSString *due_display = self.assignment.due_display;
	NSString *course_name = self.assignment.course_name;
	
#ifdef DISPLAY_COURSE
	if (!course_name) course_name = @">_<还木有课程";
#endif
	
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

	NSString *content = [assignmentInfo objectForKey:@"content"];
	if (!content.length) content = @"施主有点懒，什么都没留下";
	self.assignment.content = content;
	
	if (self.imageView.image) {
		self.assignment.has_image = [NSNumber numberWithBool:YES];
		self.assignment.image_data = [NSKeyedArchiver archivedDataWithRootObject:self.imageView.image];
	} else {
		self.assignment.has_image = [NSNumber numberWithBool:NO];
		self.assignment.image_data = nil;
	}
	
	self.assignment.doc_type = @"assignment";
	
	RESTOperation *op = [self.assignment save];
	if (op && ![op wait]) {
		NSLog(@"AssignmentCreate:onConfirm %@", op.error);
	} else {
		[[NSUserDefaults standardUserDefaults] setObject:@1 forKey:[NSString stringWithFormat:@"course%@_edited", self.course.id]];
		[[NSUserDefaults standardUserDefaults] synchronize];
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
			footerView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg-TableView"]];
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
