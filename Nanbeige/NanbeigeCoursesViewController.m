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

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	
	self.tabBarController.navigationController.navigationBar.titleTextAttributes = @{ UITextAttributeTextColor : [UIColor blackColor], UITextAttributeTextShadowColor: [UIColor whiteColor] , UITextAttributeFont : [UIFont boldSystemFontOfSize:17], UITextAttributeTextShadowOffset : [NSValue valueWithUIOffset:UIOffsetMake(0, 0.5)]};
	self.tabBarController.tabBar.tintColor = tabBarBgColor1;
	
	_paginatorView.frame = self.view.bounds;
	[self.view setBackgroundColor:tableBgColor2];
	[self.view addSubview:_paginatorView];
	
	self.paginatorView.pageGapWidth = TIMETABLEPAGEGAPWIDTH;
	[_paginatorView removePageControlFromSuperview];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	self.tabBarController.navigationController.navigationBar.titleTextAttributes = @{ UITextAttributeTextColor : [UIColor blackColor], UITextAttributeTextShadowColor: [UIColor whiteColor] , UITextAttributeFont : [UIFont boldSystemFontOfSize:17], UITextAttributeTextShadowOffset : [NSValue valueWithUIOffset:UIOffsetMake(0, 0.5)]};
	self.tabBarController.tabBar.tintColor = tabBarBgColor1;
	
	UIBarButtonItem *todayButton = [[UIBarButtonItem alloc] initWithTitle:@"今天" style:UIBarButtonItemStyleBordered target:self action:@selector(onTodayButtonPressed:)];
	self.tabBarController.navigationItem.rightBarButtonItem = todayButton;
	
	[self onTodayButtonPressed:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
	self.paginatorView = nil;
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

#pragma mark - Button controllerAction

- (void)onTodayButtonPressed:(id)sender
{
	[_paginatorView setCurrentPageIndex:TIMETABLEPAGEINDEX animated:YES];
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
	NSString *identifier = [[NSDate dateWithTimeIntervalSinceNow:60*60*24*(pageIndex - TIMETABLEPAGEINDEX)] description];
	
	NanbeigeTimeTable *view = (NanbeigeTimeTable *)[paginatorView dequeueReusablePageWithIdentifier:identifier];
	if (!view) {
		view = [[NanbeigeTimeTable alloc] initWithDate:[NSDate dateWithTimeIntervalSinceNow:60*60*24*(pageIndex - TIMETABLEPAGEINDEX)]];
	}
	
	return view;
}

#pragma mark - SYPaginatorViewDelegate

- (void)paginatorView:(SYPaginatorView *)paginatorView didScrollToPageAtIndex:(NSInteger)pageIndex
{
	NSDate *day = [NSDate dateWithTimeIntervalSinceNow:60*60*24*(pageIndex - TIMETABLEPAGEINDEX)];
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	formatter.dateFormat = @"第w周 E M月d日";
	NSString *dayDate = [formatter stringFromDate:day];
	self.tabBarController.title = dayDate;
}

@end
