//
//  NanbeigeCoursesViewController.m
//  Nanbeige
//
//  Created by ZongZiWang on 12-8-8.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import "NanbeigeCoursesViewController.h"
#import "NanbeigeTimeTable.h"
#import "Environment.h"

@interface NanbeigeCoursesViewController ()

@end

@implementation NanbeigeCoursesViewController
@synthesize paginatorView = _paginatorView;

#pragma mark - NSObject

- (id)init {
	if ((self = [super init])) {
		[self _initialize];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if ((self = [super initWithCoder:aDecoder])) {
		[self _initialize];
	}
	return self;
}


- (void)dealloc {
	_paginatorView.dataSource = nil;
	_paginatorView.delegate = nil;
}


#pragma mark - UIViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
		[self _initialize];
	}
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	
	NSDate *today = [NSDate date];
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	formatter.dateFormat = @"yyyy年MM月dd日";
	NSString *todayDate = [formatter stringFromDate:today];
	self.tabBarController.title = todayDate;
	
	UIBarButtonItem *todayButton = [[UIBarButtonItem alloc] initWithTitle:@"今天" style:UIBarButtonItemStyleBordered target:self action:@selector(onTodayButtonPressed:)];
	self.tabBarController.navigationItem.rightBarButtonItem = todayButton;
	
	_paginatorView.frame = self.view.bounds;
	[self.view addSubview:_paginatorView];
	
	self.paginatorView.pageGapWidth = TIMETABLEPAGEGAPWIDTH;
	[_paginatorView setCurrentPageIndex:0 animated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self onTodayButtonPressed:nil];
}

- (void)onTodayButtonPressed:(id)sender
{
	[_paginatorView setCurrentPageIndex:TIMETABLEPAGEINDEX animated:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
	self.paginatorView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Private

- (void)_initialize {
	_paginatorView = [[SYPaginatorView alloc] initWithFrame:CGRectZero];
	_paginatorView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_paginatorView.dataSource = self;
	_paginatorView.delegate = self;
}


#pragma mark - SYPaginatorDataSource

- (NSInteger)numberOfPagesForPaginatorView:(SYPaginatorView *)paginator {
	return TIMETABLEPAGENUMBER;
}


- (SYPageView *)paginatorView:(SYPaginatorView *)paginatorView viewForPageAtIndex:(NSInteger)pageIndex; {
	static NSString *identifier = @"timeTableIdentifier";
	
	NanbeigeTimeTable *view = (NanbeigeTimeTable *)[paginatorView dequeueReusablePageWithIdentifier:identifier];
	if (!view) {
		view = [[NanbeigeTimeTable alloc] initWithReuseIdentifier:identifier];
	}
	view.date = [NSDate dateWithTimeIntervalSinceNow:60*60*24*(pageIndex - TIMETABLEPAGEINDEX)];
	
	return view;
}

- (void)paginatorView:(SYPaginatorView *)paginatorView didScrollToPageAtIndex:(NSInteger)pageIndex
{
	NSDate *day = [NSDate dateWithTimeIntervalSinceNow:60*60*24*(pageIndex - TIMETABLEPAGEINDEX)];
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	formatter.dateFormat = @"yyyy年MM月dd日";
	NSString *dayDate = [formatter stringFromDate:day];
	self.tabBarController.title = dayDate;
}

@end
