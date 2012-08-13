//
//  CPSelectedCoursesViewController.m
//  CP
//
//  Created by ZongZiWang on 12-8-8.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import "CPUserCoursesViewController.h"
#import "Environment.h"
#import "Coffeepot.h"
#import "Models+addon.h"

@interface CPUserCoursesViewController ()  {
//	CPCourseManager *courseManager;
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
	self.tabBarController.navigationController.navigationBar.titleTextAttributes = @{ UITextAttributeTextColor : [UIColor blackColor], UITextAttributeTextShadowColor: [UIColor whiteColor] , UITextAttributeFont : [UIFont boldSystemFontOfSize:20], UITextAttributeTextShadowOffset : [NSValue valueWithUIOffset:UIOffsetMake(0, 0.5)]};
	
	if (_refreshHeaderView == nil) {
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
		view.delegate = self;
		[view setBackgroundColor:tableBgColor1];
		[self.tableView addSubview:view];
		_refreshHeaderView = view;
	}
	//  update the last update date
	[_refreshHeaderView refreshLastUpdatedDate];
	
	CouchDatabase *localDatabase = [(CPAppDelegate *)([[UIApplication sharedApplication] delegate]) localDatabase];
	CouchDocument *doc = [localDatabase documentWithID:@"courses"];
	self.courses = [[doc properties] objectForKey:@"value"];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	self.tabBarController.navigationItem.rightBarButtonItem = nil;
	self.tabBarController.title = TITLE_SELECTED_COURSE;
	self.tableView.backgroundColor = tableBgColor3;
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
	cell.textLabel.text = [[self.courses objectAtIndex:indexPath.row] objectForKey:kAPINAME];
    cell.detailTextLabel.text = [[[self.courses objectAtIndex:indexPath.row] objectForKey:kAPICREDIT] stringValue];
	
    return cell;
}

#pragma mark - Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
	
	//  should be calling your tableviews data source model to reload
	//  put here just for demo
	_reloading = YES;
	
	[[Coffeepot shared] requestWithMethodPath:@"course/" params:nil requestMethod:@"GET" success:^(CPRequest *_req, id collection) {
		
		if ([collection isKindOfClass:[NSArray class]]) {
			
			for (NSDictionary *course in collection) {
				NSMutableDictionary *mutableCourse = [course mutableCopy];
				[mutableCourse setObject:@"course" forKey:@"doc_type"];
				
				CouchDatabase *localDatabase = [(CPAppDelegate *)([[UIApplication sharedApplication] delegate]) localDatabase];
				CouchDocument *doc = [localDatabase documentWithID:[NSString stringWithFormat:@"course_%@", [course objectForKey:@"id"]]];
				if ([doc propertyForKey:@"_rev"]) [mutableCourse setObject:[doc propertyForKey:@"_rev"] forKey:@"_rev"];
				RESTOperation *op = [doc putProperties:mutableCourse];
				[op onCompletion:^{
					if (op.error) NSLog(@"%@", op.error);
					else {
						[self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:0.5];
					}
				}];
			}
			
			self.courses = collection;
			NSMutableDictionary *mutableCourses = [@{ @"value" : collection } mutableCopy];
			[mutableCourses setObject:@"courses" forKey:@"doc_type"];
			
			CouchDatabase *localDatabase = [(CPAppDelegate *)([[UIApplication sharedApplication] delegate]) localDatabase];
			CouchDocument *doc = [localDatabase documentWithID:@"courses"];
			if ([doc propertyForKey:@"_rev"]) [mutableCourses setObject:[doc propertyForKey:@"_rev"] forKey:@"_rev"];
			RESTOperation *op = [doc putProperties:mutableCourses];
			[op onCompletion:^{
				if (op.error) NSLog(@"%@", op.error);
			}];

		}
		
	} error:^(CPRequest *_req, id collection, NSError *error) {
		if ([collection isKindOfClass:[NSDictionary class]] && [collection objectForKey:@"error"])
			[self showAlert:[collection objectForKey:@"error"]];//raise(-1);
		if ([collection isKindOfClass:[NSDictionary class]] && [collection objectForKey:@"error_code"])
			[self showAlert:[collection objectForKey:@"error_code"]];//raise(-1);
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
	[self showAlert:[[self.courses objectAtIndex:indexPath.row] description]];
}

@end
