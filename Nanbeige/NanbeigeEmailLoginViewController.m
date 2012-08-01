//
//  NanbeigeEmailLoginViewController.m
//  Nanbeige
//
//  Created by ZongZiWang on 12-8-1.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import "NanbeigeEmailLoginViewController.h"
#import "Environment.h"
#import "ASIFormDataRequest.h"

@interface NanbeigeEmailLoginViewController () {
	NSString *email;
	NSString *password;
}

@end

@implementation NanbeigeEmailLoginViewController

- (void)setQuickDialogTableView:(QuickDialogTableView *)aQuickDialogTableView {
    [super setQuickDialogTableView:aQuickDialogTableView];
    self.quickDialogTableView.backgroundView = nil;
    self.quickDialogTableView.backgroundColor = tableBgColor1;
    self.quickDialogTableView.bounces = NO;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self) {
		self.root = [[QRootElement alloc] initWithJSONFile:@"emailLogin"];
	}
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	UIBarButtonItem *loginButton = [[UIBarButtonItem alloc] initWithTitle:@"登录" style:UIBarButtonItemStyleBordered target:self action:@selector(onLogin:)];
	self.navigationItem.rightBarButtonItem = loginButton;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

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
					 cancelButtonTitle:@"确定"
					 otherButtonTitles:nil] show];
}

- (void)onLogin:(UIBarButtonItem *)sender {
	NSMutableDictionary *loginInfo = [[NSMutableDictionary alloc] init];
    [self.root fetchValueUsingBindingsIntoObject:loginInfo];
	email = [loginInfo objectForKey:kAPIEMAIL];
	password = [loginInfo objectForKey:kAPIPASSWORD];
	
	if ([email length] <= 0) {
		[self showAlert:@"Email不能为空！"];
		return ;
    }
	if ([password length] <= 0) {
        [self showAlert:@"密码不能为空！"];
		return ;
    }
	
	ASIFormDataRequest *loginRequest = [ASIFormDataRequest requestWithURL:urlAPIUserLoginEmail];
	
	[loginRequest addPostValue:email forKey:kAPIEMAIL];
	[loginRequest addPostValue:password forKey:kAPIPASSWORD];
	[loginRequest setDelegate:self];
	[loginRequest setTimeOutSeconds:20];
	[loginRequest startAsynchronous];
	
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    [self loading:YES];
}

- (void)chooseSchool
{
	self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"欢迎" style:UIBarButtonItemStyleBordered target:nil action:nil];
	[self performSegueWithIdentifier:@"ChooseSchoolSegue" sender:self];
}
- (void)confirmLogin
{
	
	self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"欢迎" style:UIBarButtonItemStyleBordered target:nil action:nil];
	[self performSegueWithIdentifier:@"ConfirmLoginSegue" sender:self];
}
- (void)onEmailSignup:(id)sender
{
	self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"登录" style:UIBarButtonItemStyleBordered target:nil action:nil];
	[self performSegueWithIdentifier:@"EmailSignupSegue" sender:self];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
	[self loading:NO];
	NSData *responseData = [request responseData];
	id res = [NSJSONSerialization JSONObjectWithData:responseData
											 options:NSJSONWritingPrettyPrinted
											   error:nil];
	NSLog(@"%@", res);
	if ([res objectForKey:kAPIERROR]) {
		[self showAlert:[res objectForKey:kAPIERROR]];
		return ;
	}
	
	NSString *nickname = [res objectForKey:kAPINICKNAME];
	NSNumber *nanbeigeid = [res objectForKey:kAPIID];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setValue:email forKey:kNANBEIGEEMAILKEY];
	[defaults setValue:password forKey:kNANBEIGEPASSWORDKEY];
	[defaults setValue:nickname forKey:kNANBEIGENICKNAME];
	[defaults setValue:nanbeigeid forKey:kNANBEIGEIDKEY];
	
	if ([res objectForKey:kAPIUNIVERSITY] && [[res objectForKey:kAPIUNIVERSITY] isKindOfClass:[NSDictionary class]]) {
		[defaults setValue:[[res objectForKey:kAPIUNIVERSITY] objectForKey:kAPIID] forKey:kUNIVERSITYID];
		[defaults setValue:[[res objectForKey:kAPIUNIVERSITY] objectForKey:kAPIName] forKey:kUNIVERSITYNAME];
		[self confirmLogin];
	} else [self chooseSchool];
}
- (void)requestFailed:(ASIHTTPRequest *)request
{
	[self loading:NO];
	NSData *responseData = [request responseData];
	if (responseData) {
		id res = [NSJSONSerialization JSONObjectWithData:responseData
												 options:NSJSONWritingPrettyPrinted
												   error:nil];
		NSLog(@"%@", res);
		if ([res objectForKey:kAPIERROR]) {
			[self showAlert:[res objectForKey:kAPIERROR]];
			return ;
		}
	}
	
	NSError *error = [request error];
	NSLog(@"%@", error);
	[self showAlert:[error description]];
}


@end
