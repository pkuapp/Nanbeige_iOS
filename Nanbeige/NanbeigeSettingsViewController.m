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
@synthesize weiboCell;
@synthesize renrenCell;

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
	indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	[indicatorView setCenter:CGPointMake(160, 240)];
	[self.view addSubview:indicatorView];
	
	[self setupWeibo];
	[self setupRenren];
}
- (void)viewDidUnload
{
	[self setWeiboCell:nil];
	[self setRenrenCell:nil];
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
    
	[weiboCell release];
	[renrenCell release];
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
	weiboCell.textLabel.text = [@"微博账号:"stringByAppendingString:[weiBoEngine userID]];
	
	weiboLogOutBtnOAuth = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[weiboLogOutBtnOAuth setFrame:CGRectMake(250, 20, 50, 25)];
	[weiboLogOutBtnOAuth setTitle:@"退出" forState:UIControlStateNormal];
	[weiboLogOutBtnOAuth addTarget:self action:@selector(onWeiboLogOutButtonPressed) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:weiboLogOutBtnOAuth];
}
- (void)onWeiboLogOutButtonPressed
{
	[weiboLogOutBtnOAuth removeFromSuperview];
	weiboCell.textLabel.text = @"连接微博账号";
	
	[weiBoEngine logOut];
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
	ROUserInfoRequestParam *requestParam = [[[ROUserInfoRequestParam alloc] init] autorelease];
	requestParam.fields = [NSString stringWithFormat:@"uid,name"];
	[self.renren getUsersInfo:requestParam andDelegate:self];
	renrenCell.textLabel.text = @"人人账号:";
	
	renrenLogOutBtnOAuth = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[renrenLogOutBtnOAuth setFrame:CGRectMake(250, 65, 50, 25)];
	[renrenLogOutBtnOAuth setTitle:@"退出" forState:UIControlStateNormal];
	[renrenLogOutBtnOAuth addTarget:self action:@selector(onRenrenLogOutButtonPressed) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:renrenLogOutBtnOAuth];
	[indicatorView startAnimating];
}
- (void)onRenrenLogOutButtonPressed
{
	[indicatorView startAnimating];
	[renrenLogOutBtnOAuth removeFromSuperview];
	renrenCell.textLabel.text = @"连接人人账号";
	[renren logout:self];
	[self showAlert:@"登出成功！" withTag:kWBAlertViewLogOutTag];
	[indicatorView stopAnimating];
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
	if (![self.renren isSessionValid]){
		NSArray *permissions = [[NSArray alloc] initWithObjects:@"status_update", nil];
		[self.renren authorizationInNavigationWithPermisson:permissions andDelegate:self];
	} else {
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
	[indicatorView stopAnimating];
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
	[indicatorView stopAnimating];
	[self showAlert:@"登出成功！" withTag:kWBAlertViewLogOutTag];
}
- (void)engineNotAuthorized:(WBEngine *)engine
{
	[indicatorView stopAnimating];
    [self showAlert:@"未授权！"];
}
- (void)engineAuthorizeExpired:(WBEngine *)engine
{
	[indicatorView stopAnimating];
    [self showAlert:@"登录失败！"];
}

#pragma mark - RenrenDelegate methods

-(void)renrenDidLogin:(Renren *)renren{
	[indicatorView stopAnimating];
	[self showAlert:@"登录成功！" withTag:kWBAlertViewLogInTag];
	[self setRenrenLogoutButton];
}
- (void)renren:(Renren *)renren loginFailWithError:(ROError*)error{
	[indicatorView stopAnimating];
	NSString *title = [NSString stringWithFormat:@"Error code:%d", [error code]];
	NSString *description = [NSString stringWithFormat:@"%@", [error localizedDescription]];
	UIAlertView *alertView =[[[UIAlertView alloc] initWithTitle:title message:description delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil] autorelease];
	[alertView show];
}
- (void)renren:(Renren *)renren requestDidReturnResponse:(ROResponse*)response{
	[indicatorView stopAnimating];
	if ([renrenCell.textLabel.text isEqualToString:@"人人账号:"]) {
		NSArray *usersInfo = (NSArray *)(response.rootObject);
		
		for (ROUserResponseItem *item in usersInfo) {
			//renrenCell.textLabel.text = [renrenCell.textLabel.text stringByAppendingString:item.userId];
			renrenCell.textLabel.text = [renrenCell.textLabel.text stringByAppendingString:item.name];
		}
	} else {
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
}
- (void)renren:(Renren *)renren requestFailWithError:(ROError*)error{
	[indicatorView stopAnimating];
	NSString* errorCode = [NSString stringWithFormat:@"Error:%d",error.code];
    NSString* errorMsg = [error localizedDescription];
    
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:errorCode message:errorMsg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alert show];
    [alert release];
}

@end
