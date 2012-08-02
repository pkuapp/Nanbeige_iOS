//
//  NanbeigeAccountManageViewController.m
//  Nanbeige
//
//  Created by ZongZiWang on 12-8-2.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import "NanbeigeAccountManageViewController.h"
#import "Environment.h"

@interface NanbeigeAccountManageViewController ()

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
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated
{
	NSString *nickname = [[NSUserDefaults standardUserDefaults] objectForKey:kNANBEIGENICKNAME];
	if (!nickname) nickname = @"未命名";
	NSString *university = [[NSUserDefaults standardUserDefaults] objectForKey:kUNIVERSITYNAME];
	
	NSMutableArray *loginaccount = [[NSMutableArray alloc] init];
	NSMutableArray *connectaccount = [[NSMutableArray alloc] init];
	
	if ([[NSUserDefaults standardUserDefaults] objectForKey:kNANBEIGEEMAILKEY])
		[loginaccount addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Email", @"title", [[NSUserDefaults standardUserDefaults] objectForKey:kNANBEIGEEMAILKEY], @"value", nil]];
	else
		[connectaccount addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"连接到南北阁", @"title", nil]];
	
	if ([[NSUserDefaults standardUserDefaults] objectForKey:kRENRENNAMEKEY])
		[loginaccount addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"人人网", @"title", [[NSUserDefaults standardUserDefaults] objectForKey:kRENRENNAMEKEY], @"value", nil]];
	else
		[connectaccount addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"连接到人人网", @"title", nil]];
	
	if ([[NSUserDefaults standardUserDefaults] objectForKey:kWEIBOIDKEY])
		[loginaccount addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"新浪微博", @"title", [[NSUserDefaults standardUserDefaults] objectForKey:kWEIBOIDKEY], @"value", nil]];
	else
		[connectaccount addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"连接到新浪微博", @"title", nil]];
	
	NSDictionary *dict = @{
	@"identity": @[
	@{ @"title" : @"昵称", @"value" : nickname } ,
	@{ @"title" : @"学校", @"value" : university } ] ,
	@"loginaccount" : loginaccount,
	@"connectaccount" : connectaccount};
	[self.root bindToObject:dict];
}

- (void)onLogout:(id)sender
{
	[self.quickDialogTableView deselectRowAtIndexPath:[self.quickDialogTableView indexForElement:sender] animated:YES];
	UIActionSheet *menu = [[UIActionSheet alloc] initWithTitle:nil
													  delegate:self
											 cancelButtonTitle:@"取消"
										destructiveButtonTitle:@"全部登出"
											 otherButtonTitles:@"断开南北阁连接", @"断开人人网连接", @"断开新浪微博连接", nil];
	[menu showInView:self.view];
}

#pragma mark - ActionSheetDelegate Setup

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	switch (buttonIndex) {
		case 0:
			NSLog(@"全部登出");
		{
			
			NSString *nickname = [[NSUserDefaults standardUserDefaults] objectForKey:kNANBEIGENICKNAME];
			if (!nickname) nickname = @"未命名";
			NSString *university = [[NSUserDefaults standardUserDefaults] objectForKey:kUNIVERSITYNAME];
			
			NSMutableArray *loginaccount = [[NSMutableArray alloc] init];
			NSMutableArray *connectaccount = [[NSMutableArray alloc] init];
			
			if ([[NSUserDefaults standardUserDefaults] objectForKey:kNANBEIGEEMAILKEY])
				[loginaccount addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Email", @"title", [[NSUserDefaults standardUserDefaults] objectForKey:kNANBEIGEEMAILKEY], @"value", nil]];
			else
				[connectaccount addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"连接到南北阁", @"title", nil]];
			
			if ([[NSUserDefaults standardUserDefaults] objectForKey:kRENRENNAMEKEY] || YES)
				[loginaccount addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"人人网", @"title", [[NSUserDefaults standardUserDefaults] objectForKey:kRENRENNAMEKEY], @"value", nil]];
			else
				[connectaccount addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"连接到人人网", @"title", nil]];
			
			if ([[NSUserDefaults standardUserDefaults] objectForKey:kWEIBOIDKEY] || YES)
				[loginaccount addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"新浪微博", @"title", [[NSUserDefaults standardUserDefaults] objectForKey:kWEIBOIDKEY], @"value", nil]];
			else
				[connectaccount addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"连接到新浪微博", @"title", nil]];
			
			NSDictionary *dict = @{
			@"identity": @[
			@{ @"title" : @"昵称", @"value" : nickname } ,
			@{ @"title" : @"学校", @"value" : university } ] ,
			@"loginaccount" : loginaccount,
			@"connectaccount" : connectaccount};
			[self.root bindToObject:dict];
			[self.quickDialogTableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 3)] withRowAnimation:UITableViewRowAnimationFade];
		}
			break;
		case 1:
			NSLog(@"南北阁账号登出");
		{
			
			NSString *nickname = [[NSUserDefaults standardUserDefaults] objectForKey:kNANBEIGENICKNAME];
			if (!nickname) nickname = @"未命名";
			NSString *university = [[NSUserDefaults standardUserDefaults] objectForKey:kUNIVERSITYNAME];
			
			NSMutableArray *loginaccount = [[NSMutableArray alloc] init];
			NSMutableArray *connectaccount = [[NSMutableArray alloc] init];
			
			if ([[NSUserDefaults standardUserDefaults] objectForKey:kNANBEIGEEMAILKEY])
				[loginaccount addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Email", @"title", [[NSUserDefaults standardUserDefaults] objectForKey:kNANBEIGEEMAILKEY], @"value", nil]];
			else
				[connectaccount addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"连接到南北阁", @"title", nil]];
			
			if ([[NSUserDefaults standardUserDefaults] objectForKey:kRENRENNAMEKEY] || YES)
				[loginaccount addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"人人网", @"title", [[NSUserDefaults standardUserDefaults] objectForKey:kRENRENNAMEKEY], @"value", nil]];
			else
				[connectaccount addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"连接到人人网", @"title", nil]];
			
			if ([[NSUserDefaults standardUserDefaults] objectForKey:kWEIBOIDKEY])
				[loginaccount addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"新浪微博", @"title", [[NSUserDefaults standardUserDefaults] objectForKey:kWEIBOIDKEY], @"value", nil]];
			else
				[connectaccount addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"连接到新浪微博", @"title", nil]];
			
			NSDictionary *dict = @{
			@"identity": @[
			@{ @"title" : @"昵称", @"value" : nickname } ,
			@{ @"title" : @"学校", @"value" : university } ] ,
			@"loginaccount" : loginaccount,
			@"connectaccount" : connectaccount};
			[self.root bindToObject:dict];
			[self.quickDialogTableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 3)] withRowAnimation:UITableViewRowAnimationFade];
		}
			break;
		case 2:
			NSLog(@"人人网登出");
			
			if (NO) {
				self.renrenEngine = [Renren sharedRenren];
				NSHTTPCookieStorage *cookies;
				cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
				NSArray* graphCookies = [cookies cookiesForURL:
										 [NSURL URLWithString:@"http://graph.renren.com"]];
				for (NSHTTPCookie* cookie in graphCookies) {
					[cookies deleteCookie:cookie];
				}
				NSArray* widgetCookies = [cookies cookiesForURL:[NSURL URLWithString:@"http://widget.renren.com"]];
				for (NSHTTPCookie* cookie in widgetCookies) {
					[cookies deleteCookie:cookie];
				}
				if (![self.renrenEngine isSessionValid]){
					NSArray *permissions = [[NSArray alloc] initWithObjects:@"status_update", nil];
					[self.renrenEngine authorizationInNavigationWithPermisson:permissions andDelegate:self];
				} else {
					[[[UIAlertView alloc]initWithTitle:nil
											   message:@"人人已登录！"
											  delegate:self
									 cancelButtonTitle:@"确定"
									 otherButtonTitles:nil] show];
				}
			}
		{
			
			NSString *nickname = [[NSUserDefaults standardUserDefaults] objectForKey:kNANBEIGENICKNAME];
			if (!nickname) nickname = @"未命名";
			NSString *university = [[NSUserDefaults standardUserDefaults] objectForKey:kUNIVERSITYNAME];
			
			NSMutableArray *loginaccount = [[NSMutableArray alloc] init];
			NSMutableArray *connectaccount = [[NSMutableArray alloc] init];
			
			if ([[NSUserDefaults standardUserDefaults] objectForKey:kNANBEIGEEMAILKEY])
				[loginaccount addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Email", @"title", [[NSUserDefaults standardUserDefaults] objectForKey:kNANBEIGEEMAILKEY], @"value", nil]];
			else
				[connectaccount addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"连接到南北阁", @"title", nil]];
			
			if ([[NSUserDefaults standardUserDefaults] objectForKey:kRENRENNAMEKEY])
				[loginaccount addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"人人网", @"title", [[NSUserDefaults standardUserDefaults] objectForKey:kRENRENNAMEKEY], @"value", nil]];
			else
				[connectaccount addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"连接到人人网", @"title", nil]];
			
			if ([[NSUserDefaults standardUserDefaults] objectForKey:kWEIBOIDKEY] || YES)
				[loginaccount addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"新浪微博", @"title", [[NSUserDefaults standardUserDefaults] objectForKey:kWEIBOIDKEY], @"value", nil]];
			else
				[connectaccount addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"连接到新浪微博", @"title", nil]];
			
			NSDictionary *dict = @{
			@"identity": @[
			@{ @"title" : @"昵称", @"value" : nickname } ,
			@{ @"title" : @"学校", @"value" : university } ] ,
			@"loginaccount" : loginaccount,
			@"connectaccount" : connectaccount};
			[self.root bindToObject:dict];
			[self.quickDialogTableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 3)] withRowAnimation:UITableViewRowAnimationFade];
		}
			break;
		case 3:
			NSLog(@"新浪微博登出");
			if (NO) {
			WBEngine *engine = [[WBEngine alloc] initWithAppKey:kWBSDKDemoAppKey appSecret:kWBSDKDemoAppSecret];
			[engine setRootViewController:self];
			[engine setDelegate:self];
			[engine setRedirectURI:@"https://api.weibo.com/oauth2/default.html"];
			[engine setIsUserExclusive:NO];
			self.weiBoEngine = engine;
				
			[engine logIn];
			
			
			} else {
			
			NSString *nickname = [[NSUserDefaults standardUserDefaults] objectForKey:kNANBEIGENICKNAME];
			if (!nickname) nickname = @"未命名";
			NSString *university = [[NSUserDefaults standardUserDefaults] objectForKey:kUNIVERSITYNAME];
			
			NSMutableArray *loginaccount = [[NSMutableArray alloc] init];
			NSMutableArray *connectaccount = [[NSMutableArray alloc] init];
			
			if ([[NSUserDefaults standardUserDefaults] objectForKey:kNANBEIGEEMAILKEY] && NO)
				[loginaccount addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Email", @"title", [[NSUserDefaults standardUserDefaults] objectForKey:kNANBEIGEEMAILKEY], @"value", nil]];
			else
				[connectaccount addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"连接到南北阁", @"title", nil]];
			
			if ([[NSUserDefaults standardUserDefaults] objectForKey:kRENRENNAMEKEY])
				[loginaccount addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"人人网", @"title", [[NSUserDefaults standardUserDefaults] objectForKey:kRENRENNAMEKEY], @"value", nil]];
			else
				[connectaccount addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"连接到人人网", @"title", nil]];
			
			if ([[NSUserDefaults standardUserDefaults] objectForKey:kWEIBOIDKEY])
				[loginaccount addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"新浪微博", @"title", [[NSUserDefaults standardUserDefaults] objectForKey:kWEIBOIDKEY], @"value", nil]];
			else
				[connectaccount addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"连接到新浪微博", @"title", nil]];
			
			NSDictionary *dict = @{
			@"identity": @[
			@{ @"title" : @"昵称", @"value" : nickname } ,
			@{ @"title" : @"学校", @"value" : university } ] ,
			@"loginaccount" : loginaccount,
			@"connectaccount" : connectaccount};
			[self.root bindToObject:dict];
			[self.quickDialogTableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 3)] withRowAnimation:UITableViewRowAnimationFade];
		}
			break;
		case 4:
			NSLog(@"取消");
			break;
			
		default:
			break;
	}
}

@end
