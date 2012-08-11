//
//  CPCourseGrabberViewController.m
//  CP
//
//  Created by ZongZiWang on 12-8-10.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import "CPCourseGrabberViewController.h"
#import "Environment.h"
#import "CPCourseManager.h"

@interface CPCourseGrabberViewController () <CPCourseManagerDelegate> {
	CPCourseManager *courseManager;
}

@end

@implementation CPCourseGrabberViewController

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
		self.root = [[QRootElement alloc] initWithJSONFile:@"courseGrabber"];
	}
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	UIBarButtonItem *loginButton = [[UIBarButtonItem alloc] initWithTitle:sCONFIRM style:UIBarButtonItemStyleBordered target:self action:@selector(onConfirm:)];
	UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:sCANCEL style:UIBarButtonItemStyleBordered target:self action:@selector(close)];
	self.navigationItem.rightBarButtonItem = loginButton;
	self.navigationItem.leftBarButtonItem = closeButton;
	
	self.navigationController.navigationBar.tintColor = navBarBgColor1;
	
	courseManager = [[CPCourseManager alloc] init];
	courseManager.delegate = self;
	
	[courseManager requestCourseGrabber];
	[[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    [self loading:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
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

#pragma mark - Button controllerAction

- (void)onConfirm:(UIBarButtonItem *)sender {
	NSMutableDictionary *loginInfo = [[NSMutableDictionary alloc] init];
    [self.root fetchValueUsingBindingsIntoObject:loginInfo];
	NSString *username = [loginInfo objectForKey:kAPIUSERNAME];
	NSString *password = [loginInfo objectForKey:kAPIPASSWORD];
	NSString *captcha = [loginInfo objectForKey:kAPICAPTCHA];
	
	if ([username length] <= 0) {
		[self showAlert:@"用户名不能为空！"];
		return ;
    }
	if ([password length] <= 0) {
        [self showAlert:@"密码不能为空！"];
		return ;
    }
	
	[courseManager startCourseGrabberWithUsername:username Password:password Captcha:captcha];
	 
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    [self loading:YES];
}

- (void)close
{
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark - CourseManagerDelegate Email

- (void)didCourseGrabberReceived:(NSDictionary *)grabber
{
	if (![[grabber objectForKey:kAPIAVAILABLE] boolValue]) {
		[self loading:NO];
		[self performSelector:@selector(close) withObject:nil afterDelay:1.0];
		[self showAlert:@"抓课器暂不可用"];
		return ;
	}
	if ([[grabber objectForKey:kAPIREQUIRE_CAPTCHA] boolValue]) {
		[courseManager requestCourseGrabberCaptcha];
		return ;
	}
	[self loading:NO];
}

- (void)didCourseGrabberCaptchaReceived:(NSData *)captchaImage
{
	NSDictionary *dict = @{@"captcha":@[@{ @"placeholder" : @"验证码" }]};
	[self.root bindToObject:dict];
	[self.quickDialogTableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationBottom];
	UIImage *image = [UIImage imageWithData:captchaImage];
	CGFloat width = image.size.width * 31.0 / image.size.height;
	UIImageView *captchaImageView = [[UIImageView alloc] initWithFrame:CGRectMake(280 - width, 6, width, 31)];
	captchaImageView.image = image;
	[[[self.quickDialogTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]] contentView] addSubview:captchaImageView];
	[self loading:NO];
}

- (void)didCourseGrabberStarted
{
	[self loading:NO];
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:kCOURSE_IMPORTED];
	[self close];
}

- (void)didRequest:(ASIHTTPRequest *)request FailWithError:(NSString *)errorString
{
	[self loading:NO];
	[self showAlert:errorString];
}

- (void)didRequest:(ASIHTTPRequest *)request FailWithErrorCode:(NSString *)errorCode
{
	[self loading:NO];
	if ([errorCode isEqualToString:sERRORAUTHERROR]) {
		[self showAlert:@"用户名密码输入错误"];
	}
	if ([errorCode isEqualToString:sERRORCAPTCHAERROR]) {
		[self showAlert:@"验证码输入错误"];
	}
	if ([errorCode isEqualToString:sERRORUNKNOWNERROR]) {
		[self showAlert:@"未知错误"];
	}
}

@end
