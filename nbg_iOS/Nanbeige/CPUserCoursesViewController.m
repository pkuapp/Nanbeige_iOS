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

@interface CPUserCoursesViewController ()  {
	Course *courseSelected;
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
	
	self.courses = [[Course userCourseListDocument] propertyForKey:@"value"];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	self.tabBarController.navigationItem.rightBarButtonItem = nil;
	self.tabBarController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:TITLE_SELECTED_COURSE style:UIBarButtonItemStyleBordered target:nil action:nil];
	self.tabBarController.title = TITLE_SELECTED_COURSE;
}

- (void)viewDidUnload
{
	[self setTableView:nil];
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
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.courses.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	if (nil == cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
	}
	CouchDatabase *localDatabase = [(CPAppDelegate *)([[UIApplication sharedApplication] delegate]) localDatabase];
	CouchDocument *courseDocument = [localDatabase documentWithID:[self.courses objectAtIndex:indexPath.row]];
	Course *course = [Course modelForDocument:courseDocument];
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
		
		CouchDatabase *localDatabase = [(CPAppDelegate *)([[UIApplication sharedApplication] delegate]) localDatabase];
		
		if ([collection isKindOfClass:[NSArray class]]) {
			
			NSMutableArray *courses = [[NSMutableArray alloc] init];
			for (NSDictionary *courseDict in collection) {
				
				Course *course = [Course courseWithID:[courseDict objectForKey:@"id"]];
				
				NSLog(@"%@", course.document.documentID);
				
				course.doc_type = @"course";
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
						if (![deleteOp wait]) NSLog(@"%@", deleteOp.error);
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
					lesson.week = [lessonDict objectForKey:@"week"];
					
					RESTOperation *saveOp = [lesson save];
					if ([saveOp wait])
						[lessons addObject:lesson.document.documentID];
					else NSLog(@"%@", saveOp.error);
					
				}
				course.lessons = lessons;
				
				RESTOperation *saveOp = [course save];
				if ([saveOp wait]) [courses addObject:course.document.documentID];
				else [self showAlert:[saveOp.error description]];
				
			}
			
			NSMutableDictionary *courseListDict = [@{ @"doc_type" : @"courselist", @"value" : courses } mutableCopy];
			CouchDocument *courseListDocument = [Course userCourseListDocument];
			if ([courseListDocument propertyForKey:@"_rev"]) [courseListDict setObject:[courseListDocument propertyForKey:@"_rev"] forKey:@"_rev"];
			RESTOperation *putOp = [courseListDocument putProperties:courseListDict];
			if (![putOp wait]) [self showAlert:[putOp.error description]];
			
			[self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:0.5];
			
		} else {
			[self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:0.5];
			[self showAlert:@"返回结果不是NSArray"];
		}
		
	} error:^(CPRequest *request, NSError *error) {
		[self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:0.5];
		[self showAlert:[error description]];//NSLog(%"%@", [error description]);
	}];
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
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	courseSelected = [Course userCourseAtIndex:indexPath.row courseList:self.courses];
	[self performSegueWithIdentifier:@"CourseSegue" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"CourseSegue"]) {
		[segue.destinationViewController setCourse:courseSelected];
	}
}

@end
