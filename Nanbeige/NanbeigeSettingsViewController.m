//
//  NanbeigeSettingsViewController.m
//  Nanbeige
//
//  Created by Wang Zhongyu on 12-7-9.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import "NanbeigeSettingsViewController.h"
#import "Environment.h"
#import "ROConnect.h"

#define kWBSDKDemoAppKey @"1362082242"
#define kWBSDKDemoAppSecret @"26a3e4f3e784bd183aeac3d58440f19f"

#ifndef kWBSDKDemoAppKey
#error
#endif

#ifndef kWBSDKDemoAppSecret
#error
#endif

#define kWBAlertViewLogOutTag 100
#define kWBAlertViewLogInTag  101

@interface NanbeigeSettingsViewController ()

@end

@implementation NanbeigeSettingsViewController
@synthesize weiBoEngine;
@synthesize renren;

#pragma mark - View lifecycle

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	[self setupWeibo];
	[self setupRenren];
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [indicatorView release], indicatorView = nil;
}
- (void)dealloc
{
    [weiBoEngine setDelegate:nil];
    [weiBoEngine release], weiBoEngine = nil;
	
	[renren release], renren = nil;
    
    [indicatorView release], indicatorView = nil;
    
    [super dealloc];
}

#pragma mark Weibo Setup
- (void)setupWeibo
{
	WBEngine *engine = [[WBEngine alloc] initWithAppKey:kWBSDKDemoAppKey appSecret:kWBSDKDemoAppSecret];
    [engine setRootViewController:self];
    [engine setDelegate:self];
    [engine setRedirectURI:@"https://api.weibo.com/oauth2/default.html"];
    [engine setIsUserExclusive:NO];
    self.weiBoEngine = engine;
    [engine release];
	
	if ([weiBoEngine isLoggedIn] && ![weiBoEngine isAuthorizeExpired]) {
		[self setWeiboLogoutButton];
	}
}
- (void)setWeiboLogoutButton
{
	weiboLogOutBtnOAuth = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[weiboLogOutBtnOAuth setFrame:CGRectMake(250, 20, 50, 25)];
	[weiboLogOutBtnOAuth setTitle:@"退出" forState:UIControlStateNormal];
	[weiboLogOutBtnOAuth addTarget:self action:@selector(onWeiboLogOutButtonPressed) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:weiboLogOutBtnOAuth];
}
- (void)onWeiboLogOutButtonPressed
{
    [weiBoEngine logOut];
	[weiboLogOutBtnOAuth removeFromSuperview];
}
- (void)weiboLogIn
{
	[weiBoEngine logIn];
}

#pragma mark Renren Setup

- (void)setupRenren
{
    renren = [Renren sharedRenren];
	if ([renren isSessionValid]) {
		[self setRenrenLogoutButton];
	}
}
- (void)setRenrenLogoutButton
{
	renrenLogOutBtnOAuth = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[renrenLogOutBtnOAuth setFrame:CGRectMake(250, 65, 50, 25)];
	[renrenLogOutBtnOAuth setTitle:@"退出" forState:UIControlStateNormal];
	[renrenLogOutBtnOAuth addTarget:self action:@selector(onRenrenLogOutButtonPressed) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:renrenLogOutBtnOAuth];
}
- (void)onRenrenLogOutButtonPressed
{
	[renren logout:self];
	[self showAlert:@"登出成功！" withTag:kWBAlertViewLogOutTag];
	[renrenLogOutBtnOAuth removeFromSuperview];
}
- (void)renrenLogIn
{
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
	[indicatorView startAnimating];
	if (![self.renren isSessionValid]){
		NSArray *permissions = [[NSArray alloc] initWithObjects:@"status_update", nil];
		[self.renren authorizationInNavigationWithPermisson:permissions andDelegate:self];
	} else {
		[indicatorView stopAnimating];
		UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:nil 
														   message:@"人人账号已登录！" 
														  delegate:self
												 cancelButtonTitle:@"确定" 
												 otherButtonTitles:nil];
		[alertView setTag:kWBAlertViewLogInTag];
		[alertView show];
		[alertView release];
	}
}

#pragma mark Display Status

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
	    return (interfaceOrientation == UIInterfaceOrientationPortrait);
		//return YES;
	} else {
	    return (interfaceOrientation == UIInterfaceOrientationPortrait);
	}
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSUInteger section = [indexPath section];
	NSUInteger row = [indexPath row];
	switch (section) {
		case 0:
			switch (row) {
				case 0:
					[self weiboLogIn];
					break;
				case 1:
					[self renrenLogIn];
					break;
				default:
					break;
			}
			break;
		case 1:
			break;
		case 2:
			break;
		default:
			break;
	}
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark

-(void)showAlert:(NSString*)message{
	UIAlertView* alertView =[[UIAlertView alloc] initWithTitle:nil 
													   message:message
													  delegate:nil
											 cancelButtonTitle:@"确定"
											 otherButtonTitles:nil];
	[alertView show];
    [alertView release];
}
-(void)showAlert:(NSString *)message
		 withTag:(int)tag
{
	UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:nil 
													   message:message
													  delegate:self
											 cancelButtonTitle:@"确定" 
											 otherButtonTitles:nil];
    [alertView setTag:tag];
	[alertView show];
	[alertView release];
}

#pragma mark - WBEngineDelegate Methods

#pragma mark Authorize

- (void)engineAlreadyLoggedIn:(WBEngine *)engine
{
    [indicatorView stopAnimating];
    if ([engine isUserExclusive]) {
        [self showAlert:@"请先登出！"];
    }
}
- (void)engineDidLogIn:(WBEngine *)engine
{
	[self showAlert:@"登录成功！" withTag:kWBAlertViewLogInTag];
	[self setWeiboLogoutButton];
}
- (void)engine:(WBEngine *)engine didFailToLogInWithError:(NSError *)error
{
    [indicatorView stopAnimating];
    NSLog(@"didFailToLogInWithError: %@", error);
    [self showAlert:@"登录失败！"];
}
- (void)engineDidLogOut:(WBEngine *)engine
{
	[self showAlert:@"登出成功！" withTag:kWBAlertViewLogOutTag];
}
- (void)engineNotAuthorized:(WBEngine *)engine
{
    [self showAlert:@"未授权！"];
}
- (void)engineAuthorizeExpired:(WBEngine *)engine
{
    [self showAlert:@"登录失败！"];
}

#pragma mark - RenrenDelegate methods

-(void)renrenDidLogin:(Renren *)renren{
	[indicatorView stopAnimating];
	[self showAlert:@"登录成功！" withTag:kWBAlertViewLogInTag];
	[self setRenrenLogoutButton];
}
- (void)renren:(Renren *)renren loginFailWithError:(ROError*)error{
	NSString *title = [NSString stringWithFormat:@"Error code:%d", [error code]];
	NSString *description = [NSString stringWithFormat:@"%@", [error localizedDescription]];
	UIAlertView *alertView =[[[UIAlertView alloc] initWithTitle:title message:description delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil] autorelease];
	[alertView show];
}
- (void)renren:(Renren *)renren requestDidReturnResponse:(ROResponse*)response{
	NSDictionary* params = (NSDictionary *)response.rootObject;
    if (params!=nil) {
        NSString *msg=nil;
        NSMutableString *result = [[NSMutableString alloc] initWithString:@""];
        for (id key in params) {
			msg = [NSString stringWithFormat:@"key: %@ value: %@    ",key,[params objectForKey:key]];
		    [result appendString:msg];
		}
		[self showAlert:result];
        [result release];
	}
}
- (void)renren:(Renren *)renren requestFailWithError:(ROError*)error{
	NSString* errorCode = [NSString stringWithFormat:@"Error:%d",error.code];
    NSString* errorMsg = [error localizedDescription];
    
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:errorCode message:errorMsg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alert show];
    [alert release];
}

@end
