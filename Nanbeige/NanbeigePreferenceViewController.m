//
//  NanbeigePreferenceViewController.m
//  Nanbeige
//
//  Created by ZongZiWang on 12-8-2.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import "NanbeigePreferenceViewController.h"
#import "Environment.h"

@interface NanbeigePreferenceViewController ()

@end

@implementation NanbeigePreferenceViewController

#pragma mark - Setter and Getter Methods

- (void)setQuickDialogTableView:(QuickDialogTableView *)aQuickDialogTableView {
    [super setQuickDialogTableView:aQuickDialogTableView];
    self.quickDialogTableView.backgroundView = nil;
    self.quickDialogTableView.backgroundColor = tableBgColor1;
    self.quickDialogTableView.bounces = NO;
}

#pragma mark - View Lifecycle

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self) {
		self.root = [[QRootElement alloc] initWithJSONFile:@"preference"];
	}
	return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
	    return YES;
	} else {
	    return (interfaceOrientation == UIInterfaceOrientationPortrait);
	}
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	self.navigationController.navigationBar.tintColor = navBarBgColor1;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

#pragma mark - Button controllerAction

- (void)onAccountManage:(id)sender
{
	[self performSegueWithIdentifier:@"AccountManageSegue" sender:self];
}

- (void)onChangeMainOrder:(id)sender
{
	[self performSegueWithIdentifier:@"ChangeMainOrderSegue" sender:self];
}

- (void)onResetMainOrder:(id)sender
{
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:kMAINORDERKEY];
	[self dismissModalViewControllerAnimated:YES];
}

- (void)onAbout:(id)sender
{
	[self performSegueWithIdentifier:@"AboutSegue" sender:self];
}

@end
