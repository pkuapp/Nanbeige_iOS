//
//  CPDashboardViewController.m
//  nbg_iOS
//
//  Created by ZongZiWang on 12-8-16.
//  Copyright (c) 2012年 wuhaotian. All rights reserved.
//

#import "CPDashboardViewController.h"

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
		[self setupDashboardElement];
	}
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
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
	QSection *section = [[QSection alloc] init];
	[self.root addSection:section];
	QLabelElement *assignmentElement = [[QLabelElement alloc] init];
	assignmentElement.title = @"作业";
	assignmentElement.value = @"AssignmentEnterSegue";
	assignmentElement.controllerAction = @"onPerformSegue:";
	QLabelElement *roomsElement = [[QLabelElement alloc] init];
	roomsElement.title = @"自习室";
	roomsElement.value = @"RoomsEnterSegue";
	roomsElement.controllerAction = @"onPerformSegue:";
	[section addElement:assignmentElement];
	[section addElement:roomsElement];
}

- (void)setupTimeIndicator
{
	UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, -460, 320, 460)];
	view.backgroundColor = [UIColor colorWithRed:227/255.0 green:225/255.0 blue:218/255.0 alpha:1.0];
	
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	formatter.dateFormat = @"第w周 E M月d日";
	self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, view.frame.size.height - 30, 280, 20)];
	self.timeLabel.text = [formatter stringFromDate:[NSDate date]];
	self.timeLabel.backgroundColor = [UIColor clearColor];
	self.timeLabel.textColor = [UIColor whiteColor];
	self.timeLabel.font = [UIFont boldSystemFontOfSize:14];
	self.timeLabel.shadowColor = [UIColor blackColor];
	self.timeLabel.shadowOffset = CGSizeMake(0, 0.5);
	self.timeLabel.textAlignment = UITextAlignmentCenter;
	
	formatter.dateFormat = @"w";
	UIView *timeIndicator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, view.frame.size.width * [[formatter stringFromDate:[NSDate date]] integerValue] / 52, view.frame.size.height)];
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
