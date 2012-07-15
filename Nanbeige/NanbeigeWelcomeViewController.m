//
//  NanbeigeWelcomeViewController.m
//  Nanbeige
//
//  Created by Wang Zhongyu on 12-7-15.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import "NanbeigeWelcomeViewController.h"
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

@interface NanbeigeWelcomeViewController () {
	BOOL bGetRenrenName;
}

@end

@implementation NanbeigeWelcomeViewController
@synthesize usernameTextField;
@synthesize passwordTextField;
@synthesize renren;
@synthesize weiBoEngine;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	[indicatorView setCenter:CGPointMake(160, 240)];
	[self.view addSubview:indicatorView];
	
	bGetRenrenName = NO;
	[self setupWeibo];
	[self setupRenren];
}

- (void)viewDidUnload
{
	[self setUsernameTextField:nil];
	[self setPasswordTextField:nil];
	[self setRenren:nil];
	[self setWeiBoEngine:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
	    return (interfaceOrientation == UIInterfaceOrientationPortrait);
		//return YES;
	} else {
	    return (interfaceOrientation == UIInterfaceOrientationPortrait);
	}
}

- (void)dealloc {
	[usernameTextField release];
	[passwordTextField release];
	[renren release];
	[weiBoEngine release];
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
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	if ([weiBoEngine isLoggedIn] && ![weiBoEngine isAuthorizeExpired]) {
		if ([defaults valueForKey:kWEIBOIDKEY] != nil)
			[self showAlert:@"微博已登录但未保存用户id！"];
		else
			[self.weiBoEngine logOut];
	}
}

#pragma mark Renren Setup

- (void)setupRenren
{
    renren = [Renren sharedRenren];
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	if ([renren isSessionValid]) {
		if ([defaults valueForKey:kRENRENNAMEKEY] != nil)
			[self showAlert:@"人人已登录但未保存用户id！"];
		else
			[self.renren logout:self];
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField == self.passwordTextField) {
        [self.passwordTextField resignFirstResponder];
		
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		[defaults setValue:usernameTextField.text forKey:kNANBEIGEIDKEY];
		[defaults setValue:passwordTextField.text forKey:kNANBEIGEPASSWORDKEY];
		[self dismissModalViewControllerAnimated:YES];
		return NO;
    }
    else if (textField == self.usernameTextField) {
        [self.passwordTextField becomeFirstResponder];
    }
    return YES;
}

- (IBAction)signupButtonPressed:(id)sender {
	[self showAlert:@"稍后开放注册，敬请期待！"];
}

- (IBAction)loginButtonPressed:(id)sender {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setValue:usernameTextField.text forKey:kNANBEIGEIDKEY];
	[defaults setValue:passwordTextField.text forKey:kNANBEIGEPASSWORDKEY];
	[self dismissModalViewControllerAnimated:YES];
}

- (IBAction)renrenLogin:(id)sender {
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
		[indicatorView startAnimating];
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

- (IBAction)weiboLogin:(id)sender {
	[weiBoEngine logIn];
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
	
	//TODO
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setValue:[weiBoEngine userID] forKey:kWEIBOIDKEY];
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
	[self showAlert:@"登录成功！" withTag:kWBAlertViewLogInTag];
	ROUserInfoRequestParam *requestParam = [[[ROUserInfoRequestParam alloc] init] autorelease];
	requestParam.fields = [NSString stringWithFormat:@"uid,name"];
	[self.renren getUsersInfo:requestParam andDelegate:self];
	bGetRenrenName = YES;
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
	if (bGetRenrenName) {
		NSArray *usersInfo = (NSArray *)(response.rootObject);
		
		for (ROUserResponseItem *item in usersInfo) {
			//renrenCell.textLabel.text = [renrenCell.textLabel.text stringByAppendingString:item.userId];
			//renrenCell.textLabel.text = [renrenCell.textLabel.text stringByAppendingString:item.name];
			
			NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
			[defaults setValue:item.name forKey:kRENRENNAMEKEY];
			[defaults setValue:item.userId forKey:kRENRENIDKEY];
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
