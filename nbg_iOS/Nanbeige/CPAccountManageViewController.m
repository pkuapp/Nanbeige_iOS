//
//  CPAccountManageViewController.m
//  CP
//
//  Created by ZongZiWang on 12-8-2.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import "CPAccountManageViewController.h"

#import "Environment.h"

@interface CPAccountManageViewController () <UIAlertViewDelegate> {

	
	UIAlertView *nicknameEditAlert;
	UIAlertView *passwordEditAlert;
}

@end

@implementation CPAccountManageViewController

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
		self.root = [[QRootElement alloc] initWithJSONFile:@"accountManage"];
	}
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
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

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if ([alertView isEqual:nicknameEditAlert]) {
		if (buttonIndex == 1) {
			NSString *nickname = [[alertView textFieldAtIndex:0] text];
			[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:kACCOUNTEDIT];
			[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:kACCOUNTEDITNICKNAME];
			[[NSUserDefaults standardUserDefaults] setObject:nickname forKey:kCPNICKNAMEKEY];
			[[NSUserDefaults standardUserDefaults] setObject:nickname forKey:kACCOUNTNICKNAMEKEY];
			[self refreshDisplay];
		}
	}
	if ([alertView isEqual:passwordEditAlert]) {
		if (buttonIndex == 1) {
			NSString *password = [[alertView textFieldAtIndex:0] text];
			[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:kACCOUNTEDIT];
			[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:kACCOUNTEDITPASSWORD];
			[[NSUserDefaults standardUserDefaults] setObject:password forKey:kCPPASSWORDKEY];
			[self refreshDisplay];
		}
	}
}

#pragma mark - Refresh

- (void)refreshDataSource
{
	NSString *nickname = [[NSUserDefaults standardUserDefaults] objectForKey:kACCOUNTNICKNAMEKEY];
	if (!nickname) nickname = sDEFAULTNICKNAME;
	NSString *university = [[NSUserDefaults standardUserDefaults] objectForKey:kUNIVERSITYNAMEKEY];
	if (!university) university = sDEFAULTUNIVERSITY;
	NSString *campus = [[NSUserDefaults standardUserDefaults] objectForKey:kCAMPUSNAMEKEY];
	if (campus) university = [university stringByAppendingFormat:@" %@", campus];
	
	NSMutableArray *loginaccount = [[NSMutableArray alloc] init];
	NSMutableArray *connectaccount = [[NSMutableArray alloc] init];
	
	if ([[NSUserDefaults standardUserDefaults] objectForKey:kCPEMAILKEY])
		[loginaccount addObject:[NSDictionary dictionaryWithObjectsAndKeys:sEMAIL, @"title", [[NSUserDefaults standardUserDefaults] objectForKey:kCPEMAILKEY], @"value", @"onLaunchActionSheet:", @"controllerAction", nil]];
	else
		[connectaccount addObject:[NSDictionary dictionaryWithObjectsAndKeys:sCONNECTEMAIL, @"title", @"onEmailLogin:", @"controllerAction", nil]];
	
	if ([[NSUserDefaults standardUserDefaults] objectForKey:kRENRENNAMEKEY])
		[loginaccount addObject:[NSDictionary dictionaryWithObjectsAndKeys:sRENREN, @"title", [[NSUserDefaults standardUserDefaults] objectForKey:kRENRENNAMEKEY], @"value", @"onLaunchActionSheet:", @"controllerAction", nil]];
	else
		[connectaccount addObject:[NSDictionary dictionaryWithObjectsAndKeys:sCONNECTRENREN, @"title", @"onRenrenLogin:", @"controllerAction", nil]];
	
	if ([[NSUserDefaults standardUserDefaults] objectForKey:kWEIBONAMEKEY])
		[loginaccount addObject:[NSDictionary dictionaryWithObjectsAndKeys:sWEIBO, @"title", [[NSUserDefaults standardUserDefaults] objectForKey:kWEIBONAMEKEY], @"value", @"onLaunchActionSheet:", @"controllerAction", nil]];
	else
		[connectaccount addObject:[NSDictionary dictionaryWithObjectsAndKeys:sCONNECTWEIBO, @"title", @"onWeiboLogin:", @"controllerAction", nil]];
	
	NSDictionary *dict = @{
	@"identity": @[
	@{ @"title" : sNICKNAME, @"value" : nickname, @"controllerAction" : @"onEditNickname:" } ,
	@{ @"title" : sUNIVERSITY, @"value" : university, @"controllerAction" : @"onEditUniversity:" } ] ,
	@"loginaccount" : loginaccount,
	@"connectaccount" : connectaccount};
	[self.root bindToObject:dict];

}

- (void)refreshDisplay
{
	[self refreshDataSource];
	[self.quickDialogTableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 3)] withRowAnimation:UITableViewRowAnimationFade];
	if ([[[NSUserDefaults standardUserDefaults] objectForKey:kACCOUNTEDIT] boolValue]) {
		[self loading:YES];
		[[[UIApplication sharedApplication] keyWindow] endEditing:YES];

	}
}

#pragma mark - Button controllerAction

- (void)onEditNickname:(id)sender
{	
	[self.quickDialogTableView deselectRowAtIndexPath:[self.quickDialogTableView indexForElement:sender] animated:YES];
	nicknameEditAlert = [[UIAlertView alloc] initWithTitle:sEDITNICKNAME message:nil delegate:self cancelButtonTitle:sCANCEL otherButtonTitles:sCONFIRM, nil];
	nicknameEditAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
	[nicknameEditAlert show];
}

- (void)onEditPassword:(id)sender
{
	[self.quickDialogTableView deselectRowAtIndexPath:[self.quickDialogTableView indexForElement:sender] animated:YES];
	passwordEditAlert = [[UIAlertView alloc] initWithTitle:sEDITPASSWORD message:nil delegate:self cancelButtonTitle:sCANCEL otherButtonTitles:sCONFIRM, nil];
	passwordEditAlert.alertViewStyle = UIAlertViewStyleSecureTextInput;
	[passwordEditAlert show];
}

- (void)onEditUniversity:(id)sender
{
	[self.quickDialogTableView deselectRowAtIndexPath:[self.quickDialogTableView indexForElement:sender] animated:YES];
	[self performSegueWithIdentifier:@"ChooseSchoolSegue" sender:self];
}

- (void)onEmailLogin:(id)sender
{
	[self performSegueWithIdentifier:@"EmailLoginSegue" sender:self];
}

- (void)onWeiboLogin:(id)sender
{
	[self.quickDialogTableView deselectRowAtIndexPath:[self.quickDialogTableView indexForElement:sender] animated:YES];

}

- (void)onRenrenLogin:(id)sender
{
	[self.quickDialogTableView deselectRowAtIndexPath:[self.quickDialogTableView indexForElement:sender] animated:YES];

}

- (void)onLaunchActionSheet:(id)sender
{
	[self.quickDialogTableView deselectRowAtIndexPath:[self.quickDialogTableView indexForElement:sender] animated:YES];
	NSString *disconnectOrLogout = [dictLABEL2ACTIONSHEET objectForKey:[sender title]];
	NSString *otherButtonTitle = nil;
	if ([disconnectOrLogout isEqualToString:sDISCONNECTEMAIL]) {
		otherButtonTitle = sEDITPASSWORD;
	}
	
	UIActionSheet *menu = [[UIActionSheet alloc] initWithTitle:nil
													  delegate:self
											 cancelButtonTitle:sCANCEL
										destructiveButtonTitle:disconnectOrLogout
											 otherButtonTitles:otherButtonTitle, nil];
	[menu showInView:self.view];
}

- (void)onLogout:(id)sender
{
	[self onRenrenLogout:sender];
	[self onWeiboLogout:sender];
	[self onEmailLogout:sender];
	
	
	id workaround51Crash = [[NSUserDefaults standardUserDefaults] objectForKey:@"WebKitLocalStorageDatabasePathPreferenceKey"];
	NSDictionary *emptySettings = (workaround51Crash != nil)
	? [NSDictionary dictionaryWithObject:workaround51Crash forKey:@"WebKitLocalStorageDatabasePathPreferenceKey"]
	: [NSDictionary dictionary];
	[[NSUserDefaults standardUserDefaults] setPersistentDomain:emptySettings forName:[[NSBundle mainBundle] bundleIdentifier]];
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark - ActionSheetDelegate Setup

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	NSInteger methodIndex = [[dictACTIONSHEET2DISCONNECT objectForKey:[actionSheet buttonTitleAtIndex:buttonIndex]] integerValue];
	switch (methodIndex) {
		case 1:
			[self onLogout:self];
			break;
		case 2:
			[self onEmailDisconnect:self];
			break;
		case 3:
			[self onRenrenDisconnect:self];
			break;
		case 4:
			[self onWeiboDisconnect:self];
			break;
		case 5:
			[self onEditPassword:self];
			break;
		case 6:
			[self onEditNickname:self];
			
		default:
			break;
	}
}

#pragma mark - ActionSheet Button controllerAction

- (void)onRenrenLogout:(id)sender
{

	[self refreshDisplay];
}
- (void)onRenrenDisconnect:(id)sender
{
	[self onRenrenLogout:sender];
}
- (void)onWeiboLogout:(id)sender
{

	[self refreshDisplay];
}
- (void)onWeiboDisconnect:(id)sender
{
	[self onWeiboLogout:sender];
}
- (void)onEmailLogout:(id)sender
{

	[self refreshDisplay];
}
- (void)onEmailDisconnect:(id)sender
{
	[self onEmailLogout:sender];
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

- (void)didEmailEdit
{
	[self loading:NO];

//	[accountManager requestUniversityWithID:[[NSUserDefaults standardUserDefaults] objectForKey:kUNIVERSITYIDKEY]];
}

@end
