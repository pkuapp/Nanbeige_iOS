//
//  CPEmailLoginViewController.m
//  CP
//
//  Created by ZongZiWang on 12-8-1.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import "CPSigninEmailViewController.h"
#import "CPSignupEmailViewController.h"
#import "Environment.h"

@interface CPSigninEmailViewController () {
	NSString *email;
	NSString *password;

}

@end

@implementation CPSigninEmailViewController

#pragma mark - Setter and Getter Methods

- (void)setQuickDialogTableView:(QuickDialogTableView *)aQuickDialogTableView {
    [super setQuickDialogTableView:aQuickDialogTableView];
    self.quickDialogTableView.backgroundView = nil;
    self.quickDialogTableView.backgroundColor = tableBgColor1;
    self.quickDialogTableView.bounces = NO;
}

#pragma mark - View Lifecycle

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
	UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:sCANCEL style:UIBarButtonItemStyleBordered target:self action:@selector(close)];
	self.navigationItem.rightBarButtonItem = loginButton;
	self.navigationItem.leftBarButtonItem = closeButton;
	
	self.navigationController.navigationBar.tintColor = navBarBgColor1;
	
//	accountManager = [[CPAccountManager alloc] initWithViewController:self];
//	accountManager.delegate = self;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	[super prepareForSegue:segue sender:sender];
	if ([segue.identifier isEqualToString:@"EmailSignupSegue"]) {
		CPSignupEmailViewController *destinationVC = segue.destinationViewController;
//		destinationVC.accountManagerDelegate = self.accountManagerDelegate;
	}
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
	
//	[accountManager emailLoginWithEmail:email Password:password];
	
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    [self loading:YES];
}

- (void)close
{	
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark - AccountManagerDelegate Email

- (void)onEmailSignup:(id)sender
{
	self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"登录" style:UIBarButtonItemStyleBordered target:nil action:nil];
	[self performSegueWithIdentifier:@"EmailSignupSegue" sender:self];
}

- (void)didEmailLoginWithID:(NSNumber *)CPid
				   Nickname:(NSString *)nickname
			   UniversityID:(NSNumber *)university_id
			 UniversityName:(NSString *)university_name
				   CampusID:(NSNumber *)campus_id
				 CampusName:(NSString *)campus_name
{
	[self loading:NO];
	if ([[NSUserDefaults standardUserDefaults] objectForKey:kACCOUNTIDKEY]) {
		[[NSUserDefaults standardUserDefaults] setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kCPIDKEY] forKey:kACCOUNTIDKEY];
		[[NSUserDefaults standardUserDefaults] setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kCPNICKNAMEKEY] forKey:kACCOUNTNICKNAMEKEY];
	}
	if ([self.accountManagerDelegate respondsToSelector:@selector(didEmailLoginWithID:Nickname:UniversityID:UniversityName:CampusID:CampusName:)]) {
		[self.accountManagerDelegate didEmailLoginWithID:CPid Nickname:nickname UniversityID:university_id UniversityName:university_name CampusID:campus_id CampusName:campus_name];
	}
	[self close];
}

//#pragma mark - AccountManagerDelegate Error
//
//- (void)didRequest:(ASIHTTPRequest *)request FailWithError:(NSString *)errorString
//{
//	[self loading:NO];
//	[self showAlert:errorString];
//}


@end
