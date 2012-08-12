//
//  CPConfirmLoginViewController.m
//  CP
//
//  Created by ZongZiWang on 12-8-1.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import "CPSigninComfirmViewController.h"

#import "Environment.h"
#import "Models+addon.h"

@interface CPSigninComfirmViewController ()  {
//	CPAccountManager *accountManager;
	NSMutableDictionary *actionSheetDict;
}

@end

@implementation CPSigninComfirmViewController

#pragma mark - Setter and Getter Methods

- (void)setQuickDialogTableView:(QuickDialogTableView *)aQuickDialogTableView {
    [super setQuickDialogTableView:aQuickDialogTableView];
    self.quickDialogTableView.backgroundView = nil;
    self.quickDialogTableView.backgroundColor = tableBgColor1;
    self.quickDialogTableView.bounces = YES;
}

#pragma mark - View Lifecycle

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self) {
		self.root = [[QRootElement alloc] initWithJSONFile:@"confirmLogin"];
	}
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	
//	accountManager = [[CPAccountManager alloc] initWithViewController:self];
//	accountManager.delegate = self;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated
{
	[self refreshDisplay];
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

#pragma mark - Refresh

- (void)refreshDataSource
{
    User *appuser = [User sharedAppUser];
	NSString *nickname = appuser.nickname;
	if (!nickname) nickname = sDEFAULTNICKNAME;
	NSString *university = appuser.university_name;
	if (!university) university = sDEFAULTUNIVERSITY;
    
	NSString *campus = [[NSUserDefaults standardUserDefaults] objectForKey:kCAMPUSNAMEKEY];
	if (campus) university = [university stringByAppendingFormat:@" %@", campus];
	
	NSMutableArray *loginaccount = [[NSMutableArray alloc] init];
	NSMutableArray *connectaccount = [[NSMutableArray alloc] init];
	
	if (appuser.email)
		[loginaccount addObject:[NSDictionary dictionaryWithObjectsAndKeys:sEMAIL, @"title", [[NSUserDefaults standardUserDefaults] objectForKey:kCPEMAILKEY], @"value", nil]];
	else
		[connectaccount addObject:[NSDictionary dictionaryWithObjectsAndKeys:sCONNECTEMAIL, @"title", @"onEmailLogin:", @"controllerAction", nil]];
	
	if ([[NSUserDefaults standardUserDefaults] objectForKey:kRENRENNAMEKEY])
		[loginaccount addObject:[NSDictionary dictionaryWithObjectsAndKeys:sRENREN, @"title", appuser.renren_token, @"value", nil]];
	else
		[connectaccount addObject:[NSDictionary dictionaryWithObjectsAndKeys:sCONNECTRENREN, @"title", @"onRenrenLogin:", @"controllerAction", nil]];
	
	if (appuser.weibo_token)
		[loginaccount addObject:[NSDictionary dictionaryWithObjectsAndKeys:sWEIBO, @"title", appuser.weibo_token, @"value", nil]];
	else
		[connectaccount addObject:[NSDictionary dictionaryWithObjectsAndKeys:sCONNECTWEIBO, @"title", @"onWeiboLogin:", @"controllerAction", nil]];
	
	NSDictionary *dict = @{
	@"identity": @[
	@{ @"title" : sNICKNAME, @"value" : nickname } ,
	@{ @"title" : sUNIVERSITY, @"value" : university } ] ,
	@"loginaccount" : loginaccount,
	@"connectaccount" : connectaccount};
	[self.root bindToObject:dict];
	
}
- (void)refreshDisplay
{
	[self refreshDataSource];
	[self.quickDialogTableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 3)] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - Button controllerAction

- (void)onEmailLogin:(id)sender
{
	[self performSegueWithIdentifier:@"EmailLoginSegue" sender:self];
}
- (void)onWeiboLogin:(id)sender
{
	[self.quickDialogTableView deselectRowAtIndexPath:[self.quickDialogTableView indexForElement:sender] animated:YES];
//	[accountManager weiboLogin];
}

- (void)onRenrenLogin:(id)sender
{
	[self.quickDialogTableView deselectRowAtIndexPath:[self.quickDialogTableView indexForElement:sender] animated:YES];
//	[accountManager renrenLogin];
}

- (void)onConfirmLogin:(id)sender
{
//	[self.quickDialogTableView deselectRowAtIndexPath:[self.quickDialogTableView indexForElement:sender] animated:YES];
	
#warning 获取该学校信息
//	[accountManager requestUniversityWithID:[[NSUserDefaults standardUserDefaults] objectForKey:kUNIVERSITYIDKEY]];
	
//	if ([[[NSUserDefaults standardUserDefaults] objectForKey:kACCOUNTEDIT] boolValue]) {
//
//		[self loading:YES];
//		[[[UIApplication sharedApplication] keyWindow] endEditing:YES];
		
//	} else {
		[[NSUserDefaults standardUserDefaults] setObject: @1 forKey:@"CPIsSignedIn"];
    [[NSUserDefaults standardUserDefaults] synchronize];
//		[[NSUserDefaults standardUserDefaults] setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kCPNICKNAMEKEY] forKey:kACCOUNTNICKNAMEKEY];
//		[self dismissModalViewControllerAnimated:YES];
//	}
}

#pragma mark - AccountManagerDelegate Weibo

- (void)didWeiboLoginWithUserID:(NSString *)user_id UserName:(NSString *)user_name WeiboToken:(NSString *)weibo_token
{
	NSLog(@"id:%@, name:%@, token:%@", user_id, user_name, weibo_token);
	[self refreshDisplay];
}

#pragma mark - AccountManagerDelegate Renren

- (void)didRenrenLoginWithUserID:(NSNumber *)user_id UserName:(NSString *)user_name RenrenToken:(NSString *)renren_token
{
	NSLog(@"id:%@, name:%@, token:%@", user_id, user_name, renren_token);
	[self refreshDisplay];
}

#pragma mark - AccountManagerDelegate Email

- (void)didEmailEdit {
	[self loading:NO];
	[[NSUserDefaults standardUserDefaults] setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kCPIDKEY] forKey:kACCOUNTIDKEY];
	[[NSUserDefaults standardUserDefaults] setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kCPNICKNAMEKEY] forKey:kACCOUNTNICKNAMEKEY];
	[self dismissModalViewControllerAnimated:YES];
}

//#pragma mark - AccountManagerDelegate Error
//
//- (void)didRequest:(ASIHTTPRequest *)request FailWithError:(NSString *)errorString
//{
//	[self loading:NO];
//	[self showAlert:errorString];
//}

@end
