//
//  NanbeigeWeiboPostViewController.m
//  Nanbeige
//
//  Created by Wang Zhongyu on 12-7-10.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import "NanbeigeWeiboPostViewController.h"

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

@interface NanbeigeWeiboPostViewController ()

@end

@implementation NanbeigeWeiboPostViewController
@synthesize textToPost;

#pragma mark - View lifecycle

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
	
	// weibo init
	engine = [[WBEngine alloc] initWithAppKey:kWBSDKDemoAppKey appSecret:kWBSDKDemoAppSecret];
	[engine setDelegate:self];
	
	// view init
	[self.textToPost becomeFirstResponder];
	indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	[indicatorView setCenter:CGPointMake(160, 240)];
    [self.view addSubview:indicatorView];
}
- (void)viewDidUnload
{
	[self setTextToPost:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    [indicatorView release], indicatorView = nil;
}
- (void)dealloc {
	[textToPost release];
	[super dealloc];
}

#pragma mark - Display Status
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
	    return (interfaceOrientation == UIInterfaceOrientationPortrait);
		//return YES;
	} else {
	    return (interfaceOrientation == UIInterfaceOrientationPortrait);
	}
}
- (void)keyboardWillShow:(NSNotification *)notification
{
    _isKeyboardHidden = NO;
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    _isKeyboardHidden = YES;
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    if (!CGRectContainsPoint(self.textToPost.frame,[touch locationInView:self.view])) {
        if (!_isKeyboardHidden) {
            [self.textToPost resignFirstResponder];
        }
    }
}

#pragma mark - IBAction

- (IBAction)onPostButtonPressed:(id)sender {
	// check text length
	if ([self.textToPost.text length] <= 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"状态不能为空！" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    
	// post
    [engine sendWeiBoWithText:textToPost.text image:nil];
	[indicatorView startAnimating];
}

- (IBAction)onCancelButtonPressed:(id)sender {
	[self dismissModalViewControllerAnimated:YES];
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

#pragma mark - WBEngineDelegate Methods

- (void)engineNotAuthorized:(WBEngine *)engine
{
	[indicatorView stopAnimating];
	[self showAlert:@"微博未授权，请在设置中连接微博"];
}

- (void)engineAuthorizeExpired:(WBEngine *)engine
{
	[indicatorView stopAnimating];
	[self showAlert:@"微博授权已过期，请在设置中再次连接微博"];
}

- (void)engine:(WBEngine *)engine requestDidSucceedWithResult:(id)result
{
    [indicatorView stopAnimating];
    NSLog(@"requestDidSucceedWithResult: %@", result);
	[self showAlert:@"微博吐槽成功！"];
	[self dismissModalViewControllerAnimated:YES];
}
	
- (void)engine:(WBEngine *)engine requestDidFailWithError:(NSError *)error
{
	[indicatorView stopAnimating];
    NSLog(@"requestDidFailWithError: %@", error);
	[self showAlert:@"微博吐槽失败，请稍后再试"];
}

@end