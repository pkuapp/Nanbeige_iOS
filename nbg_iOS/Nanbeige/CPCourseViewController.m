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
#import "CPCommentPostElement.h"
#import "CPLabelButtonElement.h"
#import <QuartzCore/QuartzCore.h>

@interface CPCourseViewController () <UIScrollViewDelegate> {
	CALayer *shadowLayer;
}

@end

@implementation CPCourseViewController

#pragma mark - Setter and Getter Methods

- (void)setQuickDialogTableView:(QuickDialogTableView *)aQuickDialogTableView {
    [super setQuickDialogTableView:aQuickDialogTableView];
	[self.quickDialogTableView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg-TableView"]]];
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
		[view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg-TableView"]]];
		[self.quickDialogTableView addSubview:view];
		_refreshHeaderView = view;
	}
	//  update the last update date
	[_refreshHeaderView refreshLastUpdatedDate];
	
	CouchDatabase *localDatabase = [(CPAppDelegate *)([[UIApplication sharedApplication] delegate]) localDatabase];
	CouchDocument *doc = [localDatabase documentWithID:[NSString stringWithFormat:@"comments-%@", self.course.id]];
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
	
	if (!shadowLayer) {
		CGFloat detailBottom = 105;
		UIImage *shadowImg = [UIImage imageNamed:@"NavigationBar-shadow"];
		shadowLayer = [CALayer layer];
		shadowLayer.frame = CGRectMake(0, detailBottom, self.view.frame.size.width, shadowImg.size.height);
		shadowLayer.contents = (id)shadowImg.CGImage;
		shadowLayer.zPosition = 1;
		[self.quickDialogTableView.layer addSublayer:shadowLayer];
	}
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	if (![self.course.orig_id length] ||
		[[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"course%@_edited", self.course.id]] boolValue]) [self reloadTableViewDataSource];
}

- (void)viewDidUnload
{
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

- (void)onDeselectCourse:(id)sender
{
	if (_reloading) return ;
	
	[self showAlert:@"暂不开放退选功能"];
}

- (void)onDeauditCourse:(id)sender
{
	if (_reloading) return ;
	
	[[Coffeepot shared] requestWithMethodPath:[NSString stringWithFormat:@"course/%@/edit/", self.course.id] params:@{ @"status" : @"none" } requestMethod:@"POST" success:^(CPRequest *_req, id collection) {
		
		self.course.status = @"none";
		RESTOperation *saveOp = [self.course save];
		if (saveOp && ![saveOp wait]) [self showAlert:[saveOp.error description]];
		else {
			UIBarButtonItem *auditButton = [[UIBarButtonItem alloc] initWithTitle:@"旁听" style:UIBarButtonItemStyleBordered target:self action:@selector(onAuditCourse:)];
			self.navigationItem.rightBarButtonItem = auditButton;
			[auditButton setBackgroundImage:[[UIImage imageNamed:@"btn-default"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 7, 0, 7)] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
			[auditButton setBackgroundImage:[[UIImage imageNamed:@"btn-pressed-default"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 9, 0, 9)] forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
			
			[[NSUserDefaults standardUserDefaults] setObject:@1 forKey:@"user_courses_edited"];
			[[NSUserDefaults standardUserDefaults] synchronize];
		}
		[(CPAppDelegate *)[UIApplication sharedApplication].delegate hideProgressHud];
		
	} error:^(CPRequest *request, NSError *error) {
		[(CPAppDelegate *)[UIApplication sharedApplication].delegate hideProgressHud];
		[self showAlert:[error description]];//NSLog(@"%@", [error description]);
	}];
	
	[(CPAppDelegate *)[UIApplication sharedApplication].delegate showProgressHud:@"取消旁听中..."];
}

- (void)onAuditCourse:(id)sender
{
	if (_reloading) return ;
	
	[[Coffeepot shared] requestWithMethodPath:[NSString stringWithFormat:@"course/%@/edit/", self.course.id] params:@{ @"status" : @"audit" } requestMethod:@"POST" success:^(CPRequest *_req, id collection) {
		
		self.course.status = @"audit";
		RESTOperation *saveOp = [self.course save];
		if (saveOp && ![saveOp wait]) [self showAlert:[saveOp.error description]];
		else {
			UIBarButtonItem *auditButton = [[UIBarButtonItem alloc] initWithTitle:@"已旁听" style:UIBarButtonItemStyleBordered target:self action:@selector(onDeauditCourse:)];
			[auditButton setBackgroundImage:[[UIImage imageNamed:@"btn-now"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 7, 0, 7)] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
			[auditButton setBackgroundImage:[[UIImage imageNamed:@"btn-pressed-now"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 9, 0, 9)] forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
			self.navigationItem.rightBarButtonItem = auditButton;
			
			[[NSUserDefaults standardUserDefaults] setObject:@1 forKey:@"user_courses_edited"];
			[[NSUserDefaults standardUserDefaults] synchronize];
		}
		
		[(CPAppDelegate *)[UIApplication sharedApplication].delegate hideProgressHud];
		
	} error:^(CPRequest *request, NSError *error) {
		[(CPAppDelegate *)[UIApplication sharedApplication].delegate hideProgressHud];
		[self showAlert:[error description]];//NSLog(@"%@", [error description]);
	}];
	
	[(CPAppDelegate *)[UIApplication sharedApplication].delegate showProgressHud:@"旁听中..."];
}

- (void)setupCourseDetail
{
	if ([self.course.status isEqualToString:@"select"]) {
		UIBarButtonItem *selectButton = [[UIBarButtonItem alloc] initWithTitle:@"已选" style:UIBarButtonItemStyleBordered target:self action:@selector(onDeselectCourse:)];
		[selectButton setBackgroundImage:[[UIImage imageNamed:@"btn-now"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 7, 0, 7)] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
		[selectButton setBackgroundImage:[[UIImage imageNamed:@"btn-pressed-now"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 9, 0, 9)] forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
		self.navigationItem.rightBarButtonItem = selectButton;
	} else if ([self.course.status isEqualToString:@"audit"]) {
		UIBarButtonItem *auditButton = [[UIBarButtonItem alloc] initWithTitle:@"已旁听" style:UIBarButtonItemStyleBordered target:self action:@selector(onDeauditCourse:)];
		[auditButton setBackgroundImage:[[UIImage imageNamed:@"btn-now"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 7, 0, 7)] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
		[auditButton setBackgroundImage:[[UIImage imageNamed:@"btn-pressed-now"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 9, 0, 9)] forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
		self.navigationItem.rightBarButtonItem = auditButton;
	} else {
		UIBarButtonItem *auditButton = [[UIBarButtonItem alloc] initWithTitle:@"旁听" style:UIBarButtonItemStyleBordered target:self action:@selector(onAuditCourse:)];
		[auditButton setBackgroundImage:[[UIImage imageNamed:@"btn-default"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 7, 0, 7)] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
		[auditButton setBackgroundImage:[[UIImage imageNamed:@"btn-pressed-default"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 9, 0, 9)] forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
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
	self.assignments = [@[ ] mutableCopy];
	
	CouchDatabase *database = [(CPAppDelegate *)([[UIApplication sharedApplication] delegate]) database];
	CouchDesignDocument *design = [database designDocumentWithName: @"assignment"];
    [design defineViewNamed:[NSString stringWithFormat:@"assignment?id=%@", self.course.id] mapBlock: MAPBLOCK({
		NSString *type = [doc objectForKey:@"doc_type"];
		NSNumber *finished = [doc objectForKey: @"finished"];
		NSString *due = [doc objectForKey: @"due"];
		NSNumber *course_id = [doc objectForKey:@"course_id"];
		if ([type isEqualToString:@"assignment"] && [course_id isEqualToNumber:self.course.id] && ![finished boolValue]) emit(due, doc);
	}) version: @"1.0"];
	
	CouchQuery *query = [design queryViewNamed:[NSString stringWithFormat:@"assignment?id=%@", self.course.id]];
	query.descending = NO;
	RESTOperation *queryOp = [query start];
	if (queryOp && ![queryOp wait]) [self showAlert:[queryOp.error description]];
	else {
		for (CouchQueryRow* row in [query rows]) {
            [self.assignments addObject:@{ @"title" : [row.document propertyForKey:@"content"] , @"value" : [row.document propertyForKey:@"due_display"] }];
        }
	}
	
	NSDictionary *dict = @{ @"assignments" : self.assignments, @"comments" : self.comments };
	[self.root bindToObject:dict];
	
	QSection *assignmentSection = [[self.root sections] objectAtIndex:0];
	CPLabelButtonElement *completeAssignmentsElement = [[CPLabelButtonElement alloc] initWithTitle:@"已完成的作业..." Value:nil];
	completeAssignmentsElement.controllerAction = @"onDisplayCompleteAssignments:";
	[assignmentSection addElement:completeAssignmentsElement];
	
	QSection *commentSection = [[self.root sections] objectAtIndex:1];
	CPCommentPostElement *commentPostElement = [[CPCommentPostElement alloc] initWithTitle:@"我说" Value:nil];
	commentPostElement.controllerAction = @"onPost:";
	[commentSection insertElement:commentPostElement atIndex:0];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"CourseDetailSegue"]) {
		[segue.destinationViewController setCourse:self.course];
	} else if ([segue.identifier isEqualToString:@"CoursePostSegue"]) {
		[(id)[(UINavigationController *)(segue.destinationViewController) topViewController] setCourse_id:self.course.id];
	}
}

- (void)onDisplayCourseDetail:(id)sender
{
	if (_reloading) return ;
	[self performSegueWithIdentifier:@"CourseDetailSegue" sender:self];
}

- (void)onPost:(id)sender
{
	if (_reloading) return ;
	[self performSegueWithIdentifier:@"CoursePostSegue" sender:self];
}

- (void)onDisplayCompleteAssignments:(id)sender
{
	if (_reloading) return ;
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
			CouchDocument *doc = [localDatabase documentWithID:[NSString stringWithFormat:@"comments-%@", self.course.id]];
			if ([doc propertyForKey:@"_rev"]) [mutableComments setObject:[doc propertyForKey:@"_rev"] forKey:@"_rev"];
			RESTOperation *op = [doc putProperties:mutableComments];
			[op onCompletion:^{
				if (op.error) [self showAlert:[op.error description]];
			}];
			
			[[NSUserDefaults standardUserDefaults] setObject:@0 forKey:[NSString stringWithFormat:@"course%@_edited", self.course.id]];
			
			if (![self.course.orig_id length]) {
				
				[[Coffeepot shared] requestWithMethodPath:[NSString stringWithFormat:@"course/%@/", self.course.id] params:nil requestMethod:@"GET" success:^(CPRequest *_req, id collection) {
					
					if ([collection isKindOfClass:[NSDictionary class]]) {
						NSDictionary *courseDict = collection;
						
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
						
						[self setupCourseDetail];
						[self refreshDisplay];
						
						[(CPAppDelegate *)[UIApplication sharedApplication].delegate hideProgressHud];
						[self performSelector:@selector(doneLoadingTableViewData) withObject:self afterDelay:0.5];
						
					} else {
						[(CPAppDelegate *)[UIApplication sharedApplication].delegate hideProgressHud];
						[self performSelector:@selector(doneLoadingTableViewData) withObject:self afterDelay:0.5];
						[self showAlert:@"课程返回非NSDictionary"];
					}
					
				} error:^(CPRequest *request, NSError *error) {
					[(CPAppDelegate *)[UIApplication sharedApplication].delegate hideProgressHud];
					[self performSelector:@selector(doneLoadingTableViewData) withObject:self afterDelay:0.5];
					[self showAlert:[error description]];//NSLog(@"%@", [error description]);
				}];
				
			} else {
				[self refreshDisplay];
				
				[(CPAppDelegate *)[UIApplication sharedApplication].delegate hideProgressHud];
				[self performSelector:@selector(doneLoadingTableViewData) withObject:self afterDelay:0.5];
			}
			
		} else {
			[(CPAppDelegate *)[UIApplication sharedApplication].delegate hideProgressHud];
			[self performSelector:@selector(doneLoadingTableViewData) withObject:self afterDelay:0.5];
			[self showAlert:@"评论返回非NSArray"];
		}
		
	} error:^(CPRequest *request, NSError *error) {
		[(CPAppDelegate *)[UIApplication sharedApplication].delegate hideProgressHud];
		[self performSelector:@selector(doneLoadingTableViewData) withObject:self afterDelay:0.5];
		[self showAlert:[error description]];//NSLog(@"%@", [error description]);
	}];
	
	[(CPAppDelegate *)[UIApplication sharedApplication].delegate showProgressHud:@"更新课程信息中..."];
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
