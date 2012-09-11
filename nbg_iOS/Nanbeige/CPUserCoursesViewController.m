//
//  CPSelectedCoursesViewController.m
//  CP
//
//  Created by ZongZiWang on 12-8-8.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import "CPUserCoursesViewController.h"
#import "CPCourseViewController.h"
#import "Environment.h"
#import "Coffeepot.h"
#import "Models+addon.h"
#import "Course.h"
#import "Lesson.h"

@interface CPUserCoursesViewController () <UIActionSheetDelegate> {
	Course *courseSelected;
	CouchDatabase *localDatabase;
	Semester *currentSemester;
}

@end

@implementation CPUserCoursesViewController
@synthesize tableView = _tableView;

#pragma mark - Setter and Getter methods

- (NSMutableArray *)courses
{
	if (_courses == nil) {
		_courses = [[NSMutableArray alloc] init];
	}
	return _courses;
}

- (NSMutableArray *)coursesAudit
{
	if (_coursesAudit == nil) {
		_coursesAudit = [[NSMutableArray alloc] init];
	}
	return _coursesAudit;
}

- (NSMutableArray *)coursesSelect
{
	if (_coursesSelect == nil) {
		_coursesSelect = [[NSMutableArray alloc] init];
	}
	return _coursesSelect;
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
	self.tableView.backgroundColor = tableBgColorPlain;
		
	if (_refreshHeaderView == nil) {
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
		view.delegate = self;
		[view setBackgroundColor:tableBgColorPlain];
		[self.tableView addSubview:view];
		_refreshHeaderView = view;
	}
	//  update the last update date
	[_refreshHeaderView refreshLastUpdatedDate];
	
	localDatabase = [(CPAppDelegate *)([[UIApplication sharedApplication] delegate]) localDatabase];
	currentSemester = [self semesterForDate:[NSDate date] needGrabber:YES];
	
	[self refreshData];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	self.tabBarController.title = TITLE_SELECTED_COURSE;
	
	UIBarButtonItem *semesterButton = [UIBarButtonItem styledBlueBarButtonItemWithTitle:@"切换学期" target:self selector:@selector(onChangeSemester:)];
	self.tabBarController.navigationItem.rightBarButtonItem = semesterButton;

	if ((![self.courses count] && [[[Course userCourseListDocument] propertyForKey:@"value"] count]) || [[[NSUserDefaults standardUserDefaults] objectForKey:@"user_courses_edited"] boolValue]) {
		[self refreshDisplay];
	}
	
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	CouchDocument *courseListDocument = [Course userCourseListDocument];
	if (![courseListDocument propertyForKey:@"value"]) {
		[self reloadTableViewDataSource];
	}
}

- (void)viewDidUnload
{
	[self setTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	[(CPAppDelegate *)[UIApplication sharedApplication].delegate hideProgressHud];
}

- (void)refreshData
{
	if ([self.courses count] == 0 || [[[NSUserDefaults standardUserDefaults] objectForKey:@"user_courses_edited"] boolValue])
		self.courses = [[Course userCourseListDocument] propertyForKey:@"value"];
	self.coursesAudit = self.coursesSelect = nil;
	for (NSString *courseDocumentID in self.courses) {
		Course *course = [Course modelForDocument:[localDatabase documentWithID:courseDocumentID]];
		if ([course.status isEqualToString:@"select"] && [currentSemester.id isEqualToNumber:course.semester_id]) [self.coursesSelect addObject:course];
		if ([course.status isEqualToString:@"audit"] && [currentSemester.id isEqualToNumber:course.semester_id]) [self.coursesAudit addObject:course];
	}
	[[NSUserDefaults standardUserDefaults] setObject:@0 forKey:@"user_courses_edited"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)refreshDisplay
{
	[self refreshData];
	[self.tableView reloadData];
//	[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
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

-(void)showAlert:(NSString*)message{
	UIAlertView* alertView =[[UIAlertView alloc] initWithTitle:nil
													   message:message
													  delegate:nil
											 cancelButtonTitle:sCONFIRM
											 otherButtonTitles:nil];
	[alertView show];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (section == 0) return self.coursesSelect.count;
	return self.coursesAudit.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if (section == 0) return @"已选课程";
	else return @"旁听课程";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	if (nil == cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
	}
	Course *course;
	if (indexPath.section == 0) course = [self.coursesSelect objectAtIndex:indexPath.row];
	else course = [self.coursesAudit objectAtIndex:indexPath.row];
	cell.textLabel.text = course.name;
    cell.detailTextLabel.text = course.orig_id;
	
    return cell;
}

#pragma mark - Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
	
	//  should be calling your tableviews data source model to reload
	//  put here just for demo
	_reloading = YES;
	
	[[Coffeepot shared] requestWithMethodPath:@"course/" params:nil requestMethod:@"GET" success:^(CPRequest *_req, id collection) {
				
		if (!self) return ;
		
		if ([collection isKindOfClass:[NSArray class]]) {
			
			NSMutableArray *courses = [[NSMutableArray alloc] init];
			for (NSDictionary *courseDict in collection) {
				
				Course *course = [Course courseWithID:[courseDict objectForKey:@"id"]];
				
				course.doc_type = @"course";
				course.status = [courseDict objectForKey:@"status"];
				course.id = [courseDict objectForKey:@"id"];
				course.name = [courseDict objectForKey:@"name"];
				course.credit = [courseDict objectForKey:@"credit"];
				course.orig_id = [courseDict objectForKey:@"orig_id"];
				course.semester_id = [courseDict objectForKey:@"semester_id"];
				course.ta = [courseDict objectForKey:@"ta"];
				course.teacher = [courseDict objectForKey:@"teacher"];
				
				if (course.lessons) {
					for (NSString *lessonDocumentID in course.lessons) {
						CouchDocument *lessonDocument = [localDatabase documentWithID:lessonDocumentID];
						RESTOperation *deleteOp = [lessonDocument DELETE];
						if (![deleteOp wait])
							[self showAlert:[deleteOp.error description]];
					}
				}
				
				NSMutableArray *lessons = [[NSMutableArray alloc] init];
				for (NSDictionary *lessonDict in [courseDict objectForKey:@"lessons"]) {
					
					Lesson *lesson = [[Lesson alloc] initWithNewDocumentInDatabase:localDatabase];
					
					lesson.doc_type = @"lesson";
					lesson.course = course;
					lesson.start = [lessonDict objectForKey:@"start"];
					lesson.end = [lessonDict objectForKey:@"end"];
					lesson.day = [lessonDict objectForKey:@"day"];
					lesson.location = [lessonDict objectForKey:@"location"];
					lesson.weekset_id = [lessonDict objectForKey:@"weekset_id"];
					
					RESTOperation *lessonSaveOp = [lesson save];
					if (lessonSaveOp && ![lessonSaveOp wait])
						[self showAlert:[lessonSaveOp.error description]];
					else
						[lessons addObject:lesson.document.documentID];
					
				}
				course.lessons = lessons;
				
				RESTOperation *courseSaveOp = [course save];
				if (courseSaveOp && ![courseSaveOp wait])
					[self showAlert:[courseSaveOp.error description]];
				else
					[courses addObject:course.document.documentID];
				
			}
			
			self.courses = courses;
			[self refreshData];
			
			NSMutableDictionary *courseListDict = [@{ @"doc_type" : @"usercourselist", @"value" : courses } mutableCopy];
			CouchDocument *courseListDocument = [Course userCourseListDocument];
			if ([courseListDocument propertyForKey:@"_rev"]) [courseListDict setObject:[courseListDocument propertyForKey:@"_rev"] forKey:@"_rev"];
			RESTOperation *putOp = [courseListDocument putProperties:courseListDict];
			if (![putOp wait])
				[self showAlert:[putOp.error description]];
			
			[(CPAppDelegate *)[UIApplication sharedApplication].delegate hideProgressHud];
			[self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:0.5];
			
		} else {
			[(CPAppDelegate *)[UIApplication sharedApplication].delegate hideProgressHud];
			[self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:0.5];
			[self showAlert:@"返回结果不是NSArray"];
		}
		
	} error:^(CPRequest *request, NSError *error) {
		[(CPAppDelegate *)[UIApplication sharedApplication].delegate hideProgressHud];
		[self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:0.5];
		[self showAlert:[error description]];//NSLog(@"%@", [error description]);
	}];
	
	[(CPAppDelegate *)[UIApplication sharedApplication].delegate showProgressHud:@"更新课程列表中..."];
	
}

- (void)doneLoadingTableViewData{
	
	[self.tableView reloadData];
	//  model should call this when its done loading
	_reloading = NO;
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
	
}

#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
	
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
	
}

#pragma mark - EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
	
	[self reloadTableViewDataSource];
	
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	
	return _reloading; // should return if data source model is reloading
	
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	
	return [NSDate date]; // should return date data source was last changed
	
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == 0) courseSelected = [self.coursesSelect objectAtIndex:indexPath.row];
	else courseSelected = [self.coursesAudit objectAtIndex:indexPath.row];
	[self performSegueWithIdentifier:@"CourseSegue" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"CourseSegue"]) {
		[segue.destinationViewController setCourse:courseSelected];
	}
}

- (void)onChangeSemester:(id)sender
{
	NSString *prevSemseter = @"上一学期", *nextSemester = @"下一学期";
	UIActionSheet *menu = [[UIActionSheet alloc] initWithTitle:@"选择学期"
													  delegate:self
											 cancelButtonTitle:sCANCEL
										destructiveButtonTitle:nil
											 otherButtonTitles:prevSemseter, nextSemester, nil];
	[menu showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	NSString *clickedButtonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
	if ([clickedButtonTitle isEqualToString:@"上一学期"]) {
		Semester *prevSemester = [self prevSemester];
		if (prevSemester) currentSemester = prevSemester;
		else {
			[self showAlert:@"没有上一学期的数据！"];
		}
	} else if ([clickedButtonTitle isEqualToString:@"下一学期"]) {
		Semester *nextSemester = [self nextSemester];
		if (nextSemester) currentSemester = nextSemester;
		else {
			[self showAlert:@"没有下一学期的数据！"];
		}
	};
	
	[self refreshDisplay];
}

- (Semester *)prevSemester
{
	University *university = [University universityWithID:[User sharedAppUser].university_id];
	Semester *prevSemester;
	for (NSString *semesterDocumentID in university.semesters) {
		Semester *semester = [Semester modelForDocument:[localDatabase documentWithID:semesterDocumentID]];
		if ([currentSemester.week_end compare:semester.week_end] == NSOrderedDescending && [prevSemester.week_end compare:semester.week_end] != NSOrderedDescending) {
			prevSemester = semester;
		}
	}
	return prevSemester;
}

- (Semester *)nextSemester
{
	University *university = [University universityWithID:[User sharedAppUser].university_id];
	Semester *nextSemester;
	for (NSString *semesterDocumentID in university.semesters) {
		Semester *semester = [Semester modelForDocument:[localDatabase documentWithID:semesterDocumentID]];
		if ([currentSemester.week_start compare:semester.week_start] == NSOrderedAscending && [nextSemester.week_start compare:semester.week_start] != NSOrderedAscending) {
			nextSemester = semester;
		}
	}
	return nextSemester;
}

- (Semester *)semesterForDate:(NSDate *)date
				  needGrabber:(BOOL)isNeedGrabber
{
	University *university = [University universityWithID:[User sharedAppUser].university_id];
	
	Semester *semesterAfter;
	Semester *semesterBefore;
	Semester *semesterIn;
	for (NSString *semesterDocumentID in university.semesters) {
		Semester *semester = [Semester modelForDocument:[localDatabase documentWithID:semesterDocumentID]];
		if ([date compare:semester.week_start] != NSOrderedAscending && [date compare:semester.week_end] != NSOrderedDescending) {
			semesterIn = semester;
		}
		if ([date compare:semester.week_start] != NSOrderedDescending && [semesterAfter.week_start compare:semester.week_start] != NSOrderedAscending) {
			semesterAfter = semester;
		}
		if ([date compare:semester.week_end] != NSOrderedAscending && [semesterBefore.week_end compare:semester.week_end] != NSOrderedDescending) {
			semesterBefore = semester;
		}
	}
	Semester *semester;
	if (semesterIn) semester = semesterIn;
	else if (semesterAfter) semester = semesterAfter;
	else semester = semesterBefore;
	
	if (![[User sharedAppUser].course_imported containsObject:semester.id] && isNeedGrabber) [self.tabBarController performSegueWithIdentifier:@"CourseGrabberSegue" sender:self];
	return semester;
}

@end
