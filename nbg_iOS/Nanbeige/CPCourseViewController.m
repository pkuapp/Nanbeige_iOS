//
//  CPCourseViewController.m
//  nbg_iOS
//
//  Created by ZongZiWang on 12-8-16.
//  Copyright (c) 2012年 wuhaotian. All rights reserved.
//

#import "CPCourseViewController.h"
#import "Coffeepot.h"
#import "CPAssignmentViewController.h"
#import "CPPostEntryElement.h"

@interface CPCourseViewController () <UIScrollViewDelegate>

@end

@implementation CPCourseViewController

#pragma mark - Setter and Getter Methods

- (void)setQuickDialogTableView:(QuickDialogTableView *)aQuickDialogTableView {
    [super setQuickDialogTableView:aQuickDialogTableView];
	self.quickDialogTableView.bounces = YES;
    self.quickDialogTableView.backgroundView = nil;
    self.quickDialogTableView.backgroundColor = tableBgColorGrouped;
	self.quickDialogTableView.deselectRowWhenViewAppears = YES;
	self.qTableDelegate = [[CPQTableDelegate alloc] initForTableView:self.quickDialogTableView scrollViewDelegate:self];
	self.quickDialogTableView.delegate = self.qTableDelegate;
}

#pragma mark - View Lifecycle

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self) {
		self.root = [[QRootElement alloc] initWithJSONFile:@"course"];
	}
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	
	if (_refreshHeaderView == nil) {
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.quickDialogTableView.bounds.size.height, self.view.frame.size.width, self.quickDialogTableView.bounds.size.height)];
		view.delegate = self;
		[view setBackgroundColor:tableBgColorGrouped];
		[self.quickDialogTableView addSubview:view];
		_refreshHeaderView = view;
	}
	//  update the last update date
	[_refreshHeaderView refreshLastUpdatedDate];
	
	CouchDatabase *localDatabase = [(CPAppDelegate *)([[UIApplication sharedApplication] delegate]) localDatabase];
	CouchDocument *doc = [localDatabase documentWithID:[NSString stringWithFormat:@"comments%@", self.course.id]];
	self.comments = [@[] mutableCopy];
	for (NSDictionary *commentDict in [[doc properties] objectForKey:@"value"]) {
		[self.comments addObject:@{ @"title" : [NSString stringWithFormat:@"%@：%@", [commentDict objectForKey:@"writer"], [commentDict objectForKey:@"content"]] } ];
	}
	
	[self setupCourseDetail];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self refreshDisplay];
	[self.quickDialogTableView deselectRowAtIndexPath:[self.quickDialogTableView indexPathForSelectedRow] animated:YES];
}

- (void)viewDidUnload
{
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

- (void)onDeselectCourse:(id)sender
{
	[self showAlert:@"暂不开放退选功能"];
}

- (void)onDeauditCourse:(id)sender
{
	[[Coffeepot shared] requestWithMethodPath:[NSString stringWithFormat:@"course/%@/edit/", self.course.id] params:@{ @"status" : @"none" } requestMethod:@"POST" success:^(CPRequest *_req, id collection) {
		
		UIBarButtonItem *auditButton = [[UIBarButtonItem alloc] initWithTitle:@"旁听" style:UIBarButtonItemStyleBordered target:self action:@selector(onAuditCourse:)];
		self.navigationItem.rightBarButtonItem = auditButton;
		
		[(CPAppDelegate *)[UIApplication sharedApplication].delegate hideProgressHudAfterDelay:0.5];
		
	} error:^(CPRequest *request, NSError *error) {
		[(CPAppDelegate *)[UIApplication sharedApplication].delegate hideProgressHudAfterDelay:0.5];
		[self showAlert:[error description]];//NSLog(@"%@", [error description]);
	}];
	
	[(CPAppDelegate *)[UIApplication sharedApplication].delegate showProgressHud:@"取消旁听中..."];
}

- (void)onAuditCourse:(id)sender
{
	
	[[Coffeepot shared] requestWithMethodPath:[NSString stringWithFormat:@"course/%@/edit/", self.course.id] params:@{ @"status" : @"audit" } requestMethod:@"POST" success:^(CPRequest *_req, id collection) {
		
		UIBarButtonItem *auditButton = [[UIBarButtonItem alloc] initWithTitle:@"已旁听" style:UIBarButtonItemStyleBordered target:self action:@selector(onDeauditCourse:)];
		self.navigationItem.rightBarButtonItem = auditButton;
		
		[(CPAppDelegate *)[UIApplication sharedApplication].delegate hideProgressHudAfterDelay:0.5];
		
	} error:^(CPRequest *request, NSError *error) {
		[(CPAppDelegate *)[UIApplication sharedApplication].delegate hideProgressHudAfterDelay:0.5];
		[self showAlert:[error description]];//NSLog(@"%@", [error description]);
	}];
	
	[(CPAppDelegate *)[UIApplication sharedApplication].delegate showProgressHud:@"旁听中..."];
}

- (void)setupCourseDetail
{
	if ([self.course.status isEqualToString:@"select"]) {
		UIBarButtonItem *selectButton = [[UIBarButtonItem alloc] initWithTitle:@"已选" style:UIBarButtonItemStyleBordered target:self action:@selector(onDeselectCourse:)];
		self.navigationItem.rightBarButtonItem = selectButton;
	} else if ([self.course.status isEqualToString:@"audit"]) {
		UIBarButtonItem *auditButton = [[UIBarButtonItem alloc] initWithTitle:@"已旁听" style:UIBarButtonItemStyleBordered target:self action:@selector(onDeauditCourse:)];
		self.navigationItem.rightBarButtonItem = auditButton;
	} else {
		UIBarButtonItem *auditButton = [[UIBarButtonItem alloc] initWithTitle:@"旁听" style:UIBarButtonItemStyleBordered target:self action:@selector(onAuditCourse:)];
		self.navigationItem.rightBarButtonItem = auditButton;
	}
	
	UIButton *courseDetailView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 320, 105)];
	[courseDetailView addTarget:self action:@selector(onDisplayCourseDetail:) forControlEvents:UIControlStateHighlighted];
	courseDetailView.backgroundColor = tableBgColorPlain;
	
	UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 20, 65, 65)];
	imageView.image = [UIImage imageNamed:@"Icon"];
	[courseDetailView addSubview:imageView];
	
	UILabel *courseNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(105, 20, 205, 25)];
	courseNameLabel.backgroundColor = [UIColor clearColor];
	courseNameLabel.font = [UIFont boldSystemFontOfSize:20];
	courseNameLabel.text = self.course.name;
	[courseDetailView addSubview:courseNameLabel];
	
	CouchDatabase *localDatabase = [(CPAppDelegate *)([UIApplication sharedApplication].delegate) localDatabase];
	
	NSString *time = @"", *place = @"";
	for (NSString *lessonDocumentID in self.course.lessons) {
		Lesson *lesson = [Lesson modelForDocument:[localDatabase documentWithID:lessonDocumentID]];
		time = [time stringByAppendingFormat:@"%@ %@%@-%@节 ", [Weekset weeksetWithID:lesson.weekset_id].name, [@[@"周日", @"周一", @"周二", @"周三", @"周四", @"周五", @"周六"] objectAtIndex:([lesson.day integerValue] % 7)], lesson.start, lesson.end];
		place = [place stringByAppendingFormat:@"%@ ", lesson.location];
	}
	
	UILabel *courseTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(105, 45, 205, 20)];
	courseTimeLabel.backgroundColor = [UIColor clearColor];
	courseTimeLabel.font = [UIFont systemFontOfSize:15];
	courseTimeLabel.text = time;
	[courseDetailView addSubview:courseTimeLabel];
	
	UILabel *coursePlaceLabel = [[UILabel alloc] initWithFrame:CGRectMake(105, 65, 205, 20)];
	coursePlaceLabel.backgroundColor = [UIColor clearColor];
	coursePlaceLabel.font = [UIFont systemFontOfSize:15];
	coursePlaceLabel.text = place;
	[courseDetailView addSubview:coursePlaceLabel];
	
	self.quickDialogTableView.tableHeaderView = courseDetailView;
}

- (void)refreshDisplay
{
	self.assignments = [@[ @{ @"title" : @"已完成的作业...", @"controllerAction" : @"onDisplayCompleteAssignments:"} ] mutableCopy];
	
	NSArray *commentWithPost = [self.comments arrayByAddingObject:@{ @"title" : @"我说" , @"controllerAction" : @"onPost:" }];
	
	NSDictionary *dict = @{ @"assignments" : self.assignments, @"comments" : commentWithPost };
	[self.root bindToObject:dict];
	
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"CourseDetailSegue"]) {
		[segue.destinationViewController setCourse:self.course];
	} else if ([segue.identifier isEqualToString:@"CoursePostSegue"]) {
		[segue.destinationViewController setCourse_id:self.course.id];
	}
}

- (void)onDisplayCourseDetail:(id)sender
{
	[self performSegueWithIdentifier:@"CourseDetailSegue" sender:self];
}

- (void)onPost:(id)sender
{
	[self performSegueWithIdentifier:@"CoursePostSegue" sender:self];
}

- (void)onDisplayCompleteAssignments:(id)sender
{
	UIStoryboard *sb = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:[NSBundle mainBundle]];
	CPAssignmentViewController *avc = [sb instantiateViewControllerWithIdentifier:@"AssignmentListIdentifier"];
	avc.courseIdFilter = self.course.id;
	avc.bInitShowComplete = YES;
	[self.navigationController pushViewController:avc animated:YES];
}

#pragma mark - Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
	
	//  should be calling your tableviews data source model to reload
	//  put here just for demo
	_reloading = YES;
	
	[[Coffeepot shared] requestWithMethodPath:[NSString stringWithFormat:@"course/%@/comment/", self.course.id] params:nil requestMethod:@"GET" success:^(CPRequest *_req, id collection) {
		
		if ([collection isKindOfClass:[NSArray class]]) {
			self.comments = [@[] mutableCopy];
			for (NSDictionary *commentDict in collection) {
				[self.comments addObject:@{ @"title" : [NSString stringWithFormat:@"%@：%@", [commentDict objectForKey:@"writer"], [commentDict objectForKey:@"content"]] } ];
			}
			
			NSMutableDictionary *mutableComments = [@{ @"value" : collection } mutableCopy];
			[mutableComments setObject:self.course.id forKey:@"course_id"];
			[mutableComments setObject:@"comments" forKey:@"doc_type"];
			CouchDatabase *localDatabase = [(CPAppDelegate *)([[UIApplication sharedApplication] delegate]) localDatabase];
			CouchDocument *doc = [localDatabase documentWithID:[NSString stringWithFormat:@"comments%@", self.course.id]];
			if ([doc propertyForKey:@"_rev"]) [mutableComments setObject:[doc propertyForKey:@"_rev"] forKey:@"_rev"];
			RESTOperation *op = [doc putProperties:mutableComments];
			[op onCompletion:^{
				if (op.error) [self showAlert:[op.error description]];
			}];
			
			[self refreshDisplay];
			
			[(CPAppDelegate *)[UIApplication sharedApplication].delegate hideProgressHudAfterDelay:0.5];
			[self performSelector:@selector(doneLoadingTableViewData) withObject:self afterDelay:0.5];
			
		} else {
			[(CPAppDelegate *)[UIApplication sharedApplication].delegate hideProgressHudAfterDelay:0.5];
			[self performSelector:@selector(doneLoadingTableViewData) withObject:self afterDelay:0.5];
			[self showAlert:@"评论返回非NSArray"];
		}
		
	} error:^(CPRequest *request, NSError *error) {
		[(CPAppDelegate *)[UIApplication sharedApplication].delegate hideProgressHudAfterDelay:0.5];
		[self performSelector:@selector(doneLoadingTableViewData) withObject:self afterDelay:0.5];
		[self showAlert:[error description]];//NSLog(@"%@", [error description]);
	}];
	
	[(CPAppDelegate *)[UIApplication sharedApplication].delegate showProgressHud:@"更新七嘴八舌中..."];
}

- (void)doneLoadingTableViewData{
	
	[self.quickDialogTableView reloadData];
	//  model should call this when its done loading
	_reloading = NO;
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.quickDialogTableView];
	
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

@end
