//
//  CPDashboardViewController.m
//  nbg_iOS
//
//  Created by ZongZiWang on 12-8-16.
//  Copyright (c) 2012年 wuhaotian. All rights reserved.
//

#import "CPDashboardViewController.h"
#import "Models+addon.h"

@interface CPDashboardViewController () <UIScrollViewDelegate, UITableViewDelegate>

@property (strong, nonatomic) UILabel *timeLabel;

@end

@implementation CPDashboardViewController

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
		self.root = [[QRootElement alloc] init];
	}
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	
//    NSArray *vcarray = self.navigationController.viewControllers;
//    NSString *back_title = [[vcarray objectAtIndex:vcarray.count-2] title];
//	self.navigationItem.leftBarButtonItem = [UIBarButtonItem styledBackBarButtonItemWithTitle:back_title target:self.navigationController selector:@selector(popViewControllerAnimated:)];
	
	self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"仪表盘" style:UIBarButtonItemStyleBordered target:nil action:nil];
	self.navigationItem.rightBarButtonItem = [UIBarButtonItem styledRedBarButtonItemWithTitle:@"清除课程" target:self selector:@selector(onCleanDatabase:)];

	self.root.title = TITLE_MAIN;
	
	[self setupTimeIndicator];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self setupDashboardElement];
}

- (void)onCleanDatabase:(id)sender
{
	CouchDatabase *localDatabase = [(CPAppDelegate *)([UIApplication sharedApplication].delegate) localDatabase];
	CouchQuery *query = [localDatabase getAllDocuments];
	RESTOperation *op = [query start];
	if ([op wait]) {
		NSMutableArray *docs = [@[] mutableCopy];
		for (CouchQueryRow *row in query.rows) {
			if ([[row.document propertyForKey:@"doc_type"] isEqualToString:@"course"] || [[row.document propertyForKey:@"doc_type"] isEqualToString:@"courselist"] || [[row.document propertyForKey:@"doc_type"] isEqualToString:@"usercourselist"])
			[docs addObject:row.document];
		}
		[localDatabase deleteDocuments:docs];
	}
}

- (void)onPerformSegue:(id)sender
{
	QLabelElement *element = sender;
	[self performSegueWithIdentifier:element.value sender:self];
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
	[[[UIAlertView alloc] initWithTitle:nil
								message:message
							   delegate:nil
					  cancelButtonTitle:sCONFIRM
					  otherButtonTitles:nil] show];
}

- (void)setupDashboardElement
{
	[self.root.sections removeAllObjects];
	
	if ([[User sharedAppUser].university_id integerValue]) {
		QLabelElement *assignmentElement = [[QLabelElement alloc] init];
		assignmentElement.title = @"作业";
		assignmentElement.value = @"AssignmentEnterSegue";
		assignmentElement.controllerAction = @"onPerformSegue:";
		QSection *assignmentSection = [[QSection alloc] init];
		[assignmentSection addElement:assignmentElement];
		[self.root addSection:assignmentSection];
	
		QLabelElement *roomsElement = [[QLabelElement alloc] init];
		roomsElement.title = @"自习室";
		roomsElement.value = @"RoomsEnterSegue";
		roomsElement.controllerAction = @"onPerformSegue:";
		QSection *roomsSection = [[QSection alloc] init];
		[roomsSection addElement:roomsElement];
		[self.root addSection:roomsSection];
		
		if ([[User sharedAppUser].university_name isEqualToString:@"北京大学"]) {
			QLabelElement *itsElement = [[QLabelElement alloc] init];
			itsElement.title = @"IP网关";
			itsElement.value = @"ItsEnterSegue";
			itsElement.controllerAction = @"onPerformSegue:";
			QSection *itsSection = [[QSection alloc] init];
			[itsSection addElement:itsElement];
			[self.root addSection:itsSection];
		}
		
	}
	
	[self.quickDialogTableView reloadData];
}

- (void)setupTimeIndicator
{
	UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, -460, 320, 460)];
	view.backgroundColor = [UIColor colorWithRed:227/255.0 green:225/255.0 blue:218/255.0 alpha:1.0];
	
	self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, view.frame.size.height - 30, 280, 20)];
	self.timeLabel.backgroundColor = [UIColor clearColor];
	self.timeLabel.textColor = [UIColor whiteColor];
	self.timeLabel.font = [UIFont boldSystemFontOfSize:14];
	self.timeLabel.shadowColor = [UIColor blackColor];
	self.timeLabel.shadowOffset = CGSizeMake(0, 0.5);
	self.timeLabel.textAlignment = UITextAlignmentCenter;
	
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	formatter.dateFormat = @"E M月d日";
	NSInteger week = [Semester currentWeek];
	if (!week) {
		self.timeLabel.text = [NSString stringWithFormat:@"放假^_^ %@", [formatter stringFromDate:[NSDate date]]];
	} else {
		self.timeLabel.text = [NSString stringWithFormat:@"第%d周 %@", week, [formatter stringFromDate:[NSDate date]]];
	}
	
	formatter.dateFormat = @"w";
	UIView *timeIndicator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, view.frame.size.width * [Semester currentWeek] / [Semester totalWeek], view.frame.size.height)];
	timeIndicator.backgroundColor = navBarTextColor1;
	
	[self.quickDialogTableView addSubview:view];
	[view addSubview:timeIndicator];
	[view addSubview:self.timeLabel];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	CGFloat scrollViewHeight = -scrollView.contentOffset.y;
	CGFloat timeLabelY = [self.timeLabel superview].frame.size.height - 30;
	if (scrollViewHeight > 40) {
		self.timeLabel.frame = CGRectMake(20, timeLabelY - (scrollViewHeight - 40) / 2, self.timeLabel.frame.size.width, self.timeLabel.frame.size.height);
	}
}

@end
