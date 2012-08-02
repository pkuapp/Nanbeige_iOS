//
//  NanbeigeChooseLoginViewController.m
//  Nanbeige
//
//  Created by ZongZiWang on 12-8-1.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import "NanbeigeChooseLoginViewController.h"
#import "Environment.h"
#import "NanbeigeAccountManager.h"

@interface NanbeigeChooseLoginViewController () <AccountManagerDelegate> {
	NanbeigeAccountManager *accountManager;
}

@end

@implementation NanbeigeChooseLoginViewController

- (void)setQuickDialogTableView:(QuickDialogTableView *)aQuickDialogTableView {
    [super setQuickDialogTableView:aQuickDialogTableView];
    self.quickDialogTableView.backgroundView = nil;
    self.quickDialogTableView.backgroundColor = tableBgColor1;
    self.quickDialogTableView.bounces = NO;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self) {
		self.root = [[QRootElement alloc] initWithJSONFile:@"chooseLogin"];
	}
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	self.navigationController.navigationBar.tintColor = navBarBgColor1;
	self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"欢迎" style:UIBarButtonItemStyleBordered target:nil action:nil];
	
	accountManager = [[NanbeigeAccountManager alloc] initWithViewController:self];
	accountManager.delegate = self;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
	    return YES;
	} else {
	    return (interfaceOrientation == UIInterfaceOrientationPortrait);
	}
}

- (void)onEmailLogin:(id)sender
{
	[self.quickDialogTableView deselectRowAtIndexPath:[self.quickDialogTableView indexForElement:sender] animated:YES];
	[self performSegueWithIdentifier:@"EmailLoginSegue" sender:self];
}
- (void)onWeiboLogin:(id)sender
{
	[self.quickDialogTableView deselectRowAtIndexPath:[self.quickDialogTableView indexForElement:sender] animated:YES];
	[accountManager weiboLogin];
}
- (void)onRenrenLogin:(id)sender
{
	[self.quickDialogTableView deselectRowAtIndexPath:[self.quickDialogTableView indexForElement:sender] animated:YES];
	[accountManager renrenLogin];
}

- (void)didWeiboLoginWithUserID:(NSString *)user_id UserName:(NSString *)user_name WeiboToken:(NSString *)weibo_token
{
	[accountManager emailLoginWithWeiboToken:weibo_token];
}
- (void)didRenrenLoginWithUserID:(NSNumber *)user_id UserName:(NSString *)user_name RenrenToken:(NSString *)renren_token
{
	[self performSegueWithIdentifier:@"ChooseSchoolSegue" sender:self];
}

- (void)didEmailLoginWithID:(NSNumber *)ID Nickname:(NSString *)nickname UniversityID:(NSNumber *)university_id UniversityName:(NSString *)university_name
{
	if (university_id) {
		[self performSegueWithIdentifier:@"ConfirmLoginSegue" sender:self];
	} else {
		[self performSegueWithIdentifier:@"ChooseSchoolSegue" sender:self];
	}
}

@end
