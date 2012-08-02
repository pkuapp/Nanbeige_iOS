//
//  NanbeigeEmailSignupViewController.m
//  Nanbeige
//
//  Created by ZongZiWang on 12-8-1.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import "NanbeigeEmailSignupViewController.h"
#import "Environment.h"
#import "ASIFormDataRequest.h"

@interface NanbeigeEmailSignupViewController () {
	NSString *email;
	NSString *nickname;
	NSString *password;
}

@end

@implementation NanbeigeEmailSignupViewController

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
		self.root = [[QRootElement alloc] initWithJSONFile:@"emailSignup"];
	}
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	UIBarButtonItem *signupButton = [[UIBarButtonItem alloc] initWithTitle:@"注册" style:UIBarButtonItemStyleBordered target:self action:@selector(onSignup:)];
	self.navigationItem.rightBarButtonItem = signupButton;
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

- (void)onSignup:(UIBarButtonItem *)sender {
	NSMutableDictionary *signupInfo = [[NSMutableDictionary alloc] init];
    [self.root fetchValueUsingBindingsIntoObject:signupInfo];
	email = [signupInfo objectForKey:kAPIEMAIL];
	nickname = [signupInfo objectForKey:kAPINICKNAME];
	password = [signupInfo objectForKey:kAPIPASSWORD];
	
	if ([email length] <= 0) {
		[self showAlert:@"Email不能为空！"];
		return ;
    }
	if ([password length] <= 0) {
        [self showAlert:@"密码不能为空！"];
		return ;
    }
	
	ASIFormDataRequest *signupRequest = [ASIFormDataRequest requestWithURL:urlAPIUserRegEmail];
	
	[signupRequest addPostValue:email forKey:kAPIEMAIL];
	[signupRequest addPostValue:nickname forKey:kAPINICKNAME];
	[signupRequest addPostValue:password forKey:kAPIPASSWORD];
	[signupRequest setDelegate:self];
	[signupRequest setTimeOutSeconds:DEFAULT_TIMEOUT];
	[signupRequest startAsynchronous];
	
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    [self loading:YES];
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
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:email forKey:kNANBEIGEEMAILKEY];
	[defaults setObject:password forKey:kNANBEIGEPASSWORDKEY];
	[defaults setObject:nickname forKey:kNANBEIGENICKNAMEKEY];
	[defaults setObject:[res objectForKey:kAPIID] forKey:kNANBEIGEIDKEY];
	
	if (![[NSUserDefaults standardUserDefaults] objectForKey:kACCOUNTIDKEY]) {
		[self performSegueWithIdentifier:@"ChooseSchoolSegue" sender:self];
	} else {
		[defaults setObject:[res objectForKey:kAPIID] forKey:kACCOUNTIDKEY];
		[defaults setObject:nickname forKey:kACCOUNTNICKNAMEKEY];
		[self dismissModalViewControllerAnimated:YES];
	}
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
