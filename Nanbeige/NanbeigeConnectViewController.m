//
//  NanbeigeConnectViewController.m
//  Nanbeige
//
//  Created by Wang Zhongyu on 12-7-15.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import "NanbeigeConnectViewController.h"
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

@interface NanbeigeConnectViewController () {
	BOOL bGetRenrenName;
    BOOL _isKeyboardHidden;
	CGRect originalTextViewFrame;
}

@end

@implementation NanbeigeConnectViewController
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
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	if ([defaults valueForKey:kWEIBOIDKEY] != nil || 
		[defaults valueForKey:kRENRENIDKEY] != nil ||
		[defaults valueForKey:kNANBEIGEIDKEY] != nil) {
		if ([defaults valueForKey:kACCOUNTIDKEY] == nil && [defaults valueForKey:kNANBEIGEIDKEY] != nil) {
			[defaults setValue:[defaults valueForKey:kNANBEIGEIDKEY] forKey:kACCOUNTIDKEY];
			[defaults setValue:[defaults valueForKey:kNANBEIGEPASSWORDKEY] forKey:kACCOUNTPASSWORDKEY];
		}
		if ([defaults valueForKey:kACCOUNTIDKEY] == nil && [defaults valueForKey:kRENRENIDKEY] != nil) {
			[defaults setValue:[defaults valueForKey:kRENRENIDKEY] forKey:kACCOUNTIDKEY];
		}
		if ([defaults valueForKey:kACCOUNTIDKEY] == nil && [defaults valueForKey:kWEIBOIDKEY] != nil) {
			[defaults setValue:[defaults valueForKey:kWEIBOIDKEY] forKey:kACCOUNTIDKEY];
		}
	}
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    indicatorView = nil;
	usernameTextField = nil;
	passwordTextField = nil;
}
- (void)dealloc
{
    [weiBoEngine setDelegate:nil];
    //[weiBoEngine release], weiBoEngine = nil;
	//[renren release], renren = nil;
    [indicatorView release];
	[usernameTextField release];
	[passwordTextField release];
	
    [super dealloc];
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

- (void)didLogin
{
	[self dismissModalViewControllerAnimated:YES];
	//[self performSegueWithIdentifier:@"DidLoginSegue" sender:self];
}

#pragma Keyboard Show and Hide

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    if (!CGRectContainsPoint(self.usernameTextField.frame,[touch locationInView:self.view])) {
        if (!_isKeyboardHidden) {
            [self.usernameTextField resignFirstResponder];
        }
    }
	if (!CGRectContainsPoint(self.passwordTextField.frame,[touch locationInView:self.view])) {
        if (!_isKeyboardHidden) {
            [self.passwordTextField resignFirstResponder];
        }
    }
}
- (void)viewWillAppear:(BOOL)animated {
    // Register notifications for when the keyboard appears 
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}
- (void)viewDidAppear:(BOOL)animated {
	if ([[NSUserDefaults standardUserDefaults] valueForKey:kACCOUNTIDKEY] != nil) [self didLogin];
}
- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)keyboardWillShow:(NSNotification*)notification {
	_isKeyboardHidden = NO;
    [self moveViewForKeyboard:notification up:YES];
}
- (void)keyboardWillHide:(NSNotification*)notification {
	_isKeyboardHidden = YES;
    [self moveViewForKeyboard:notification up:NO];
}
- (void)moveViewForKeyboard:(NSNotification*)notification up:(BOOL)up {
    NSDictionary *userInfo = [notification userInfo];
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardRect;
	
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    animationDuration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    keyboardRect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
	
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
	
	if (up == YES) {
        //CGFloat keyboardTop = keyboardRect.origin.y;
        //CGRect newTextViewFrame = self.view.frame;
        //originalTextViewFrame = self.view.frame;
		//newTextViewFrame.size.height = keyboardTop - self.view.frame.origin.y - 20;
		
        //self.view.frame = newTextViewFrame;
    } else {
		// Keyboard is going away (down) - restore original frame
        //self.view.frame = originalTextViewFrame;
    }
	
    [UIView commitAnimations];
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
			;//[self showAlert:@"微博已登录但未保存用户id！"];
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
			;//[self showAlert:@"人人已登录但未保存用户id！"];
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
		[self didLogin];
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
	[defaults setValue:[defaults valueForKey:kNANBEIGEIDKEY] forKey:kACCOUNTIDKEY];
	[defaults setValue:[defaults valueForKey:kNANBEIGEPASSWORDKEY] forKey:kACCOUNTPASSWORDKEY];
	[self didLogin];
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
	} else {
		UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:nil 
														   message:@"人人已登录！" 
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
        [self showAlert:@"微博请先登出！"];
    }
}
- (void)engineDidLogIn:(WBEngine *)engine
{
	[indicatorView stopAnimating];
	[self showAlert:@"微博登录成功！" withTag:kWBAlertViewLogInTag];
	
	//TODO
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setValue:[weiBoEngine userID] forKey:kWEIBOIDKEY];
	[defaults setValue:[defaults valueForKey:kWEIBOIDKEY] forKey:kACCOUNTIDKEY];
	[self didLogin];
}
- (void)engine:(WBEngine *)engine didFailToLogInWithError:(NSError *)error
{
	[indicatorView stopAnimating];
    NSLog(@"didFailToLogInWithError: %@", error);
    [self showAlert:@"微博登录失败！"];
}
- (void)engineDidLogOut:(WBEngine *)engine
{
	[indicatorView stopAnimating];
	[self showAlert:@"微博登出成功！" withTag:kWBAlertViewLogOutTag];
}
- (void)engineNotAuthorized:(WBEngine *)engine
{
	[indicatorView stopAnimating];
    [self showAlert:@"微博未授权！"];
}
- (void)engineAuthorizeExpired:(WBEngine *)engine
{
	[indicatorView stopAnimating];
    [self showAlert:@"微博登录失败！"];
}

#pragma mark - RenrenDelegate methods

-(void)renrenDidLogin:(Renren *)renren{
	[indicatorView startAnimating];
	[self showAlert:@"人人登录成功！" withTag:kWBAlertViewLogInTag];
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
			[defaults setValue:[defaults valueForKey:kRENRENIDKEY] forKey:kACCOUNTIDKEY];
			[self didLogin];
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