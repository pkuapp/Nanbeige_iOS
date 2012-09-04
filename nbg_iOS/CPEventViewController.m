//
//  CPEventViewController.m
//  nbg_iOS
//
//  Created by ZongZiWang on 12-9-1.
//  Copyright (c) 2012年 wuhaotian. All rights reserved.
//

#import "CPEventViewController.h"
#import "Coffeepot.h"
#import "CPCommentPostElement.h"
#import "CPLabelButtonElement.h"
#import <QuartzCore/QuartzCore.h>

@interface CPEventViewController () <UIScrollViewDelegate> {
	CALayer *shadowLayer;
}

@end

@implementation CPEventViewController

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
	self = [super initWithRoot:[[QRootElement alloc] initWithJSONFile:@"event"]];
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
	CouchDocument *doc = [localDatabase documentWithID:[NSString stringWithFormat:@"event-comments-%@", self.event.id]];
	self.comments = [@[] mutableCopy];
	for (NSDictionary *commentDict in [[doc properties] objectForKey:@"value"]) {
		[self.comments addObject:@{ @"title" : [NSString stringWithFormat:@"%@：%@", [commentDict objectForKey:@"writer"], [commentDict objectForKey:@"content"]] } ];
	}
	
	[self setupEventDetail];
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
	if (![self.event.content length] || [[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"event%@_edited", self.event.id]] boolValue]) [self reloadTableViewDataSource];
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

- (void)onUnfollowEvent:(id)sender
{
	if (_reloading) return ;
	
	[[Coffeepot shared] requestWithMethodPath:[NSString stringWithFormat:@"event/%@/edit/", self.event.id] params:@{ @"follow" : @0 } requestMethod:@"POST" success:^(CPRequest *_req, id collection) {
		
		self.event.follow = @0;
		self.event.follower_count = [NSNumber numberWithInteger:[self.event.follower_count integerValue]-1];
		RESTOperation *saveOp = [self.event save];
		if (saveOp && ![saveOp wait]) [self showAlert:[saveOp.error description]];
		else {
			UIBarButtonItem *followButton = [[UIBarButtonItem alloc] initWithTitle:@"关注" style:UIBarButtonItemStyleBordered target:self action:@selector(onFollowEvent:)];
			self.navigationItem.rightBarButtonItem = followButton;
			[followButton setBackgroundImage:[[UIImage imageNamed:@"btn-default"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 7, 0, 7)] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
			[followButton setBackgroundImage:[[UIImage imageNamed:@"btn-pressed-default"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 9, 0, 9)] forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
			
			[[NSUserDefaults standardUserDefaults] setObject:@1 forKey:@"user_events_edited"];
			[[NSUserDefaults standardUserDefaults] synchronize];
			
			[self performSelector:@selector(refreshData) withObject:nil afterDelay:0.5];
		}
		
		[(CPAppDelegate *)[UIApplication sharedApplication].delegate hideProgressHud];
		
	} error:^(CPRequest *request, NSError *error) {
		[(CPAppDelegate *)[UIApplication sharedApplication].delegate hideProgressHud];
		[self showAlert:[error description]];//NSLog(@"%@", [error description]);
	}];
	
	[(CPAppDelegate *)[UIApplication sharedApplication].delegate showProgressHud:@"取消关注中..."];
}

- (void)onFollowEvent:(id)sender
{
	if (_reloading) return ;
	
	[[Coffeepot shared] requestWithMethodPath:[NSString stringWithFormat:@"event/%@/edit/", self.event.id] params:@{ @"follow" : @1 } requestMethod:@"POST" success:^(CPRequest *_req, id collection) {
		
		self.event.follow = @1;
		self.event.follower_count = [NSNumber numberWithInteger:[self.event.follower_count integerValue]+1];
		RESTOperation *saveOp = [self.event save];
		if (saveOp && ![saveOp wait]) [self showAlert:[saveOp.error description]];
		else {
			UIBarButtonItem *followButton = [[UIBarButtonItem alloc] initWithTitle:@"已关注" style:UIBarButtonItemStyleBordered target:self action:@selector(onUnfollowEvent:)];
			[followButton setBackgroundImage:[[UIImage imageNamed:@"btn-now"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 7, 0, 7)] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
			[followButton setBackgroundImage:[[UIImage imageNamed:@"btn-pressed-now"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 9, 0, 9)] forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
			self.navigationItem.rightBarButtonItem = followButton;
			
			[[NSUserDefaults standardUserDefaults] setObject:@1 forKey:@"user_events_edited"];
			[[NSUserDefaults standardUserDefaults] synchronize];
			
			[self performSelector:@selector(refreshData) withObject:nil afterDelay:0.5];
		}
		
		[(CPAppDelegate *)[UIApplication sharedApplication].delegate hideProgressHud];
		
	} error:^(CPRequest *request, NSError *error) {
		[(CPAppDelegate *)[UIApplication sharedApplication].delegate hideProgressHud];
		[self showAlert:[error description]];//NSLog(@"%@", [error description]);
	}];
	
	[(CPAppDelegate *)[UIApplication sharedApplication].delegate showProgressHud:@"关注中..."];
}

- (void)setupEventDetail
{
	if ([self.event.follow boolValue]) {
		UIBarButtonItem *followButton = [[UIBarButtonItem alloc] initWithTitle:@"已关注" style:UIBarButtonItemStyleBordered target:self action:@selector(onUnfollowEvent:)];
		[followButton setBackgroundImage:[[UIImage imageNamed:@"btn-now"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 7, 0, 7)] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
		[followButton setBackgroundImage:[[UIImage imageNamed:@"btn-pressed-now"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 9, 0, 9)] forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
		self.navigationItem.rightBarButtonItem = followButton;
	} else {
		UIBarButtonItem *followButton = [[UIBarButtonItem alloc] initWithTitle:@"关注" style:UIBarButtonItemStyleBordered target:self action:@selector(onFollowEvent:)];
		[followButton setBackgroundImage:[[UIImage imageNamed:@"btn-default"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 7, 0, 7)] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
		[followButton setBackgroundImage:[[UIImage imageNamed:@"btn-pressed-default"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 9, 0, 9)] forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
		self.navigationItem.rightBarButtonItem = followButton;
	}
	
	UIButton *eventDetailView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 320, 105)];
//	[eventDetailView addTarget:self action:@selector(onDisplayEventDetail:) forControlEvents:UIControlStateHighlighted];
	eventDetailView.backgroundColor = tableBgColorPlain;
	
	UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 20, 65, 65)];
	imageView.image = [UIImage imageNamed:@"Icon"];
	[eventDetailView addSubview:imageView];
	
	UILabel *eventNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(105, 20, 205, 45)];
	eventNameLabel.backgroundColor = [UIColor clearColor];
	eventNameLabel.font = [UIFont boldSystemFontOfSize:20];
	eventNameLabel.text = self.event.title;
	[eventDetailView addSubview:eventNameLabel];
	
//	CouchDatabase *localDatabase = [(CPAppDelegate *)([UIApplication sharedApplication].delegate) localDatabase];
	
//	UILabel *eventTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(105, 45, 205, 20)];
//	eventTimeLabel.backgroundColor = [UIColor clearColor];
//	eventTimeLabel.font = [UIFont systemFontOfSize:15];
//	eventTimeLabel.text = time;
//	[eventDetailView addSubview:eventTimeLabel];
	
	UILabel *eventSubtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(105, 65, 205, 20)];
	eventSubtitleLabel.backgroundColor = [UIColor clearColor];
	eventSubtitleLabel.font = [UIFont systemFontOfSize:15];
	eventSubtitleLabel.text = self.event.subtitle;
	[eventDetailView addSubview:eventSubtitleLabel];
	
	self.quickDialogTableView.tableHeaderView = eventDetailView;
}

- (void)refreshDisplay
{
	NSMutableArray *informations = [@[] mutableCopy];
	if (self.event.time) [informations addObject:@{ @"title": @"时间", @"value" : self.event.time }];
	if (self.event.location) [informations addObject:@{ @"title": @"地点", @"value" : self.event.location }];
	if (self.event.organizer) [informations addObject:@{ @"title": @"发起人", @"value" : self.event.organizer }];
	if (self.event.category_name) [informations addObject:@{ @"title": @"类别", @"value" : self.event.category_name }];
	if (self.event.follower_count) [informations addObject:@{ @"title": @"关注人数", @"value" : [NSString stringWithFormat:@"%@", self.event.follower_count] }];
	
	NSDictionary *dict = @{ @"informations" : informations, @"comments" : self.comments };
	[self.root bindToObject:dict];
	
	QSection *informationSection = [[self.root sections] objectAtIndex:0];
	QSection *commentSection = [[self.root sections] objectAtIndex:1];
	
	CPCommentPostElement *commentPostElement = [[CPCommentPostElement alloc] initWithTitle:@"我说" Value:nil];
	commentPostElement.controllerAction = @"onPost:";
	[commentSection insertElement:commentPostElement atIndex:0];
	
	NSString *content;
	if ([self.event.content length] == 0) content = @"无详细内容";
	else content = self.event.content;
	
	CGSize boundingSize = CGSizeMake(280, CGFLOAT_MAX);
	UIFont *labelFont = [UIFont systemFontOfSize:14];
	CGSize labelStringSize = [content sizeWithFont:labelFont
									constrainedToSize:boundingSize
										lineBreakMode:UILineBreakModeWordWrap];
	
	UIView *eventContentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, labelStringSize.height+60)];
	informationSection.footerView = eventContentView;
	
	UIView *eventContentBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, 320, labelStringSize.height+40)];
	eventContentBgView.backgroundColor = tableBgColorPlain;
	[eventContentView addSubview:eventContentBgView];
	
	UILabel *eventContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 40, 280, labelStringSize.height)];
	eventContentLabel.backgroundColor = [UIColor clearColor];
	eventContentLabel.font = labelFont;
	eventContentLabel.text = content;
	[eventContentView addSubview:eventContentLabel];
	
	UIImage *shadowImg = [UIImage imageNamed:@"NavigationBar-shadow"];
	UIImageView *shadowView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, shadowImg.size.height)];
	shadowView.image = shadowImg;
	[eventContentView addSubview:shadowView];
	
	UIImage *mirrorShadowImg = [[UIImage alloc] initWithCGImage:shadowImg.CGImage scale:1.0 orientation:UIImageOrientationDownMirrored];
	UIImageView *mirrorShadowView = [[UIImageView alloc] initWithFrame:CGRectMake(0, labelStringSize.height+60-mirrorShadowImg.size.height, self.view.frame.size.width, shadowImg.size.height)];
	mirrorShadowView.image = mirrorShadowImg;
	[eventContentView addSubview:mirrorShadowView];
}

- (void)refreshData
{
	[self refreshDisplay];
	[self.quickDialogTableView reloadData];
}

#pragma mark - Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
	
	//  should be calling your tableviews data source model to reload
	//  put here just for demo
	_reloading = YES;
	
//	[[Coffeepot shared] requestWithMethodPath:[NSString stringWithFormat:@"event/%@/comment/", self.event.id] params:nil requestMethod:@"GET" success:^(CPRequest *_req, id collection) {
//		
//		if ([collection isKindOfClass:[NSArray class]]) {
//			self.comments = [@[] mutableCopy];
//			for (NSDictionary *commentDict in collection) {
//				[self.comments addObject:@{ @"title" : [NSString stringWithFormat:@"%@：%@", [commentDict objectForKey:@"writer"], [commentDict objectForKey:@"content"]] } ];
//			}
//			
//			NSMutableDictionary *mutableComments = [@{ @"value" : collection } mutableCopy];
//			[mutableComments setObject:self.event.id forKey:@"event_id"];
//			[mutableComments setObject:@"comments" forKey:@"doc_type"];
//			CouchDatabase *localDatabase = [(CPAppDelegate *)([[UIApplication sharedApplication] delegate]) localDatabase];
//			CouchDocument *doc = [localDatabase documentWithID:[NSString stringWithFormat:@"event-comments-%@", self.event.id]];
//			if ([doc propertyForKey:@"_rev"]) [mutableComments setObject:[doc propertyForKey:@"_rev"] forKey:@"_rev"];
//			RESTOperation *op = [doc putProperties:mutableComments];
//			[op onCompletion:^{
//				if (op.error) [self showAlert:[op.error description]];
//			}];
//			
//			[[NSUserDefaults standardUserDefaults] setObject:@0 forKey:[NSString stringWithFormat:@"event%@_edited", self.event.id]];
//			
//			if (![self.event.organizer length]) {
				
				[[Coffeepot shared] requestWithMethodPath:[NSString stringWithFormat:@"event/%@/", self.event.id] params:nil requestMethod:@"GET" success:^(CPRequest *_req, id collection) {
					
					if ([collection isKindOfClass:[NSDictionary class]]) {
						NSDictionary *eventDict = collection;
						
						Event *event = [Event eventWithID:[eventDict objectForKey:@"id"]];
						
						event.doc_type = @"event";
						event.id = [eventDict objectForKey:@"id"];
						event.title = [eventDict objectForKey:@"title"];
						event.subtitle = [eventDict objectForKey:@"subtitle"];
						event.category_id = [[eventDict objectForKey:@"category"] objectForKey:@"id"];
						event.category_name = [[eventDict objectForKey:@"category"] objectForKey:@"name"];
						event.time = [eventDict objectForKey:@"time"];
						event.organizer = [eventDict objectForKey:@"organizer"];
						event.location = [eventDict objectForKey:@"location"];
						event.content = [eventDict objectForKey:@"content"];
						event.follower_count = [eventDict objectForKey:@"follower_count"];
						
						RESTOperation *eventSaveOp = [event save];
						if (eventSaveOp && ![eventSaveOp wait])
							[self showAlert:[eventSaveOp.error description]];
						
						[self setupEventDetail];
						[self refreshDisplay];
						
						[(CPAppDelegate *)[UIApplication sharedApplication].delegate hideProgressHud];
						[self performSelector:@selector(doneLoadingTableViewData) withObject:self afterDelay:0.5];
						
					} else {
						[(CPAppDelegate *)[UIApplication sharedApplication].delegate hideProgressHud];
						[self performSelector:@selector(doneLoadingTableViewData) withObject:self afterDelay:0.5];
						[self showAlert:@"活动返回非NSDictionary"];
					}
					
				} error:^(CPRequest *request, NSError *error) {
					[(CPAppDelegate *)[UIApplication sharedApplication].delegate hideProgressHud];
					[self performSelector:@selector(doneLoadingTableViewData) withObject:self afterDelay:0.5];
					[self showAlert:[error description]];//NSLog(@"%@", [error description]);
				}];
				
//			} else {
//				[self refreshDisplay];
//				
//				[(CPAppDelegate *)[UIApplication sharedApplication].delegate hideProgressHud];
//				[self performSelector:@selector(doneLoadingTableViewData) withObject:self afterDelay:0.5];
//			}
//			
//		} else {
//			[(CPAppDelegate *)[UIApplication sharedApplication].delegate hideProgressHud];
//			[self performSelector:@selector(doneLoadingTableViewData) withObject:self afterDelay:0.5];
//			[self showAlert:@"评论返回非NSArray"];
//		}
//		
//	} error:^(CPRequest *request, NSError *error) {
//		[(CPAppDelegate *)[UIApplication sharedApplication].delegate hideProgressHud];
//		[self performSelector:@selector(doneLoadingTableViewData) withObject:self afterDelay:0.5];
//		[self showAlert:[error description]];//NSLog(@"%@", [error description]);
//	}];
	
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