//
//  CPCoursesAllViewController.m
//  nbg_iOS
//
//  Created by ZongZiWang on 12-8-30.
//  Copyright (c) 2012年 wuhaotian. All rights reserved.
//

#import "CPCoursesAllViewController.h"
#import "CPCourseViewController.h"
#import "Environment.h"
#import "Coffeepot.h"
#import "Models+addon.h"
#import "Course.h"
#import "Lesson.h"

@interface CPCoursesAllViewController ()  {
	Course *courseSelected;
}

@end

@implementation CPCoursesAllViewController
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
	
	self.courses = [[Course courseListDocument] propertyForKey:@"value"];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	self.tabBarController.navigationItem.rightBarButtonItem = nil;
	self.tabBarController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:TITLE_SELECTED_COURSE style:UIBarButtonItemStyleBordered target:nil action:nil];
	self.tabBarController.title = TITLE_ALL_COURSE;
	
	CouchDocument *courseListDocument = [Course courseListDocument];
	if (![courseListDocument propertyForKey:@"value"]) {
		[self reloadTableViewDataSource];
	}
	
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
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
//	CouchDatabase *localDatabase = [(CPAppDelegate *)([[UIApplication sharedApplication] delegate]) localDatabase];
//	CouchDocument *courseDocument = [localDatabase documentWithID:[self.courses objectAtIndex:indexPath.row]];
//	Course *course = [Course modelForDocument:courseDocument];
//	cell.textLabel.text = course.name;
//	cell.detailTextLabel.text = course.orig_id;
	cell.textLabel.text = [[self.courses objectAtIndex:indexPath.row] objectForKey:@"name"];
	
    return cell;
}

#pragma mark - Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
	
	//  should be calling your tableviews data source model to reload
	//  put here just for demo
	_reloading = YES;
	
#warning 认为学期就是5
	
	[[Coffeepot shared] requestWithMethodPath:[NSString stringWithFormat:@"course/all/?semester_id=%@", @5] params:nil requestMethod:@"GET" success:^(CPRequest *_req, id collection) {
		
		CouchDatabase *localDatabase = [(CPAppDelegate *)([[UIApplication sharedApplication] delegate]) localDatabase];
		
		if (!self) return ;
		
		if ([collection isKindOfClass:[NSArray class]]) {
			
			NSMutableArray *courses = collection;//[[NSMutableArray alloc] init];
//			for (NSDictionary *courseDict in collection) {
//				
//				Course *course = [Course courseWithID:[courseDict objectForKey:@"id"]];
//				
//				course.doc_type = @"course";
//				course.id = [courseDict objectForKey:@"id"];
//				course.name = [courseDict objectForKey:@"name"];
//				
//				RESTOperation *courseSaveOp = [course save];
//				if (courseSaveOp && ![courseSaveOp wait])
//					[self showAlert:[courseSaveOp.error description]];
//				else
//					[courses addObject:course.document.documentID];
//				
//			}
			
			self.courses = courses;
			NSMutableDictionary *courseListDict = [@{ @"doc_type" : @"courselist", @"value" : courses } mutableCopy];
			CouchDocument *courseListDocument = [Course courseListDocument];
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
	
	[(CPAppDelegate *)[UIApplication sharedApplication].delegate showProgressHud:@"获取课程列表中..."];
	
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
	courseSelected = [Course courseAtIndex:indexPath.row courseList:self.courses];
	[self performSegueWithIdentifier:@"CourseSegue" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"CourseSegue"]) {
		[segue.destinationViewController setCourse:courseSelected];
	}
}

@end
