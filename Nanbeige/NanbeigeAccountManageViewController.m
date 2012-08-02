//
//  NanbeigeAccountManageViewController.m
//  Nanbeige
//
//  Created by ZongZiWang on 12-8-2.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import "NanbeigeAccountManageViewController.h"
#import "NanbeigeAccountManager.h"
#import "Environment.h"

@interface NanbeigeAccountManageViewController () <AccountManagerDelegate> {
	NanbeigeAccountManager *accountManager;
	NSMutableDictionary *actionSheetDict;
}

@end

@implementation NanbeigeAccountManageViewController

- (void)setQuickDialogTableView:(QuickDialogTableView *)aQuickDialogTableView {
    [super setQuickDialogTableView:aQuickDialogTableView];
    self.quickDialogTableView.backgroundView = nil;
    self.quickDialogTableView.backgroundColor = tableBgColor1;
    self.quickDialogTableView.bounces = YES;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self) {
		self.root = [[QRootElement alloc] initWithJSONFile:@"accountManage"];
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
	
	accountManager = [[NanbeigeAccountManager alloc] initWithViewController:self];
	accountManager.delegate = self;
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

- (void)refreshDataSource
{
	NSString *nickname = [[NSUserDefaults standardUserDefaults] objectForKey:kACCOUNTNICKNAMEKEY];
	if (!nickname) nickname = @"未命名";
	NSString *university = [[NSUserDefaults standardUserDefaults] objectForKey:kUNIVERSITYNAMEKEY];
	if (!university) university = @"未选校";
	
	NSMutableArray *loginaccount = [[NSMutableArray alloc] init];
	NSMutableArray *connectaccount = [[NSMutableArray alloc] init];
	
	if ([[NSUserDefaults standardUserDefaults] objectForKey:kNANBEIGEEMAILKEY])
		[loginaccount addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Email", @"title", [[NSUserDefaults standardUserDefaults] objectForKey:kNANBEIGEEMAILKEY], @"value", nil]];
	else
		[connectaccount addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"连接到南北阁", @"title", @"onEmailLogin:", @"controllerAction", nil]];
	
	if ([[NSUserDefaults standardUserDefaults] objectForKey:kRENRENNAMEKEY])
		[loginaccount addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"人人网", @"title", [[NSUserDefaults standardUserDefaults] objectForKey:kRENRENNAMEKEY], @"value", nil]];
	else
		[connectaccount addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"连接到人人网", @"title", @"onRenrenLogin:", @"controllerAction", nil]];
	
	if ([[NSUserDefaults standardUserDefaults] objectForKey:kWEIBONAMEKEY])
		[loginaccount addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"新浪微博", @"title", [[NSUserDefaults standardUserDefaults] objectForKey:kWEIBONAMEKEY], @"value", nil]];
	else
		[connectaccount addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"连接到新浪微博", @"title", @"onWeiboLogin:", @"controllerAction", nil]];
	
	NSDictionary *dict = @{
	@"identity": @[
	@{ @"title" : @"昵称", @"value" : nickname } ,
	@{ @"title" : @"学校", @"value" : university } ] ,
	@"loginaccount" : loginaccount,
	@"connectaccount" : connectaccount};
	[self.root bindToObject:dict];

}
- (void)refreshDisplay
{
	[self refreshDataSource];
	[self.quickDialogTableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 3)] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)onLogout:(id)sender
{
	[self.quickDialogTableView deselectRowAtIndexPath:[self.quickDialogTableView indexForElement:sender] animated:YES];
	
	NSMutableString *disconnect1String = [[NSMutableString alloc] init], *disconnect2String = [[NSMutableString alloc] init], *disconnect3String = [[NSMutableString alloc] init], *disconnectAllString = [[NSMutableString alloc] initWithString:@"全部登出"];
	NSArray *disconnects = [[NSArray alloc] initWithObjects:disconnect1String, disconnect2String, disconnect3String, nil];
	actionSheetDict = [[NSMutableDictionary alloc] init];
	if ([[NSUserDefaults standardUserDefaults] objectForKey:kNANBEIGEEMAILKEY]) {
		NSInteger index = actionSheetDict.count;
		[[disconnects objectAtIndex:index] setString:@"断开南北阁连接"];
		[actionSheetDict setObject:[NSNumber numberWithInt:2] forKey:[disconnects objectAtIndex:index]];
	}
	if ([[NSUserDefaults standardUserDefaults] objectForKey:kRENRENNAMEKEY]){
		NSInteger index = actionSheetDict.count;
		[[disconnects objectAtIndex:index] setString:@"断开人人网连接"];
		[actionSheetDict setObject:[NSNumber numberWithInt:3] forKey:[disconnects objectAtIndex:index]];
	}
	if ([[NSUserDefaults standardUserDefaults] objectForKey:kWEIBONAMEKEY]) {
		NSInteger index = actionSheetDict.count;
		[[disconnects objectAtIndex:index] setString:@"断开新浪微博连接"];
		[actionSheetDict setObject:[NSNumber numberWithInt:4] forKey:[disconnects objectAtIndex:index]];
	}
	if (actionSheetDict.count == 1) {
		[disconnect1String setString:@""];
		[disconnectAllString setString:@"确认登出"];
		[actionSheetDict removeAllObjects];
	}
	[actionSheetDict setObject:[NSNumber numberWithInt:1] forKey:disconnectAllString];
	if ([disconnect1String length] == 0) disconnect1String = 0;
	if ([disconnect2String length] == 0) disconnect2String = 0;
	if ([disconnect3String length] == 0) disconnect3String = 0;
	
	UIActionSheet *menu = [[UIActionSheet alloc] initWithTitle:nil
													  delegate:self
											 cancelButtonTitle:@"取消"
										destructiveButtonTitle:disconnectAllString
											 otherButtonTitles:disconnect1String, disconnect2String, disconnect3String, nil];
	[menu showInView:self.view];
}

#pragma mark - ActionSheetDelegate Setup

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	NSInteger methodIndex = [[actionSheetDict objectForKey:[actionSheet buttonTitleAtIndex:buttonIndex]] integerValue];
	switch (methodIndex) {
		case 1:
			[self onLogoutAll:self];
			break;
		case 2:
			[self onEmailLogout:self];
			break;
		case 3:
			[self onRenrenLogout:self];
			break;
		case 4:
			[self onWeiboLogout:self];
			break;
			
		default:
			break;
	}
}

- (void)onEmailLogin:(id)sender
{
	[self performSegueWithIdentifier:@"EmailLoginSegue" sender:self];
}
- (void)onWeiboLogin:(id)sender
{
	[self.quickDialogTableView deselectRowAtIndexPath:[self.quickDialogTableView indexForElement:sender] animated:YES];
	[accountManager weiboLogin];
}
- (void)didWeiboLoginWithUserID:(NSString *)user_id UserName:(NSString *)user_name WeiboToken:(NSString *)weibo_token
{
	NSLog(@"id:%@, name:%@, token:%@", user_id, user_name, weibo_token);
	[self refreshDisplay];
}
- (void)onRenrenLogin:(id)sender
{
	[self.quickDialogTableView deselectRowAtIndexPath:[self.quickDialogTableView indexForElement:sender] animated:YES];
	[accountManager renrenLogin];
}
- (void)didRenrenLoginWithUserID:(NSNumber *)user_id UserName:(NSString *)user_name RenrenToken:(NSString *)renren_token
{
	NSLog(@"id:%@, name:%@, token:%@", user_id, user_name, renren_token);
	[self refreshDisplay];
}

- (void)onRenrenLogout:(id)sender
{
	[accountManager renrenLogout];
	[self refreshDisplay];
}
- (void)onWeiboLogout:(id)sender
{
	[accountManager weiboLogout];
	[self refreshDisplay];
}
- (void)onEmailLogout:(id)sender
{
	[accountManager emailLogout];
	[self refreshDisplay];
}
- (void)onLogoutAll:(id)sender
{
	[self onRenrenLogout:sender];
	[self onWeiboLogout:sender];
	[self onEmailLogout:sender];
	
	NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
	[[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
	[self dismissModalViewControllerAnimated:YES];
}

-(void)showAlert:(NSString*)message{
	[[[UIAlertView alloc] initWithTitle:nil
								message:message
							   delegate:nil
					  cancelButtonTitle:@"确定"
					  otherButtonTitles:nil] show];
}
- (void)requestError:(NSString *)errorString
{
	[self loading:NO];
	[self showAlert:errorString];
}

@end
