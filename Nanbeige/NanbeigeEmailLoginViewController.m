//
//  NanbeigeEmailLoginViewController.m
//  Nanbeige
//
//  Created by ZongZiWang on 12-8-1.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import "NanbeigeEmailLoginViewController.h"
#import "Environment.h"
#import "NanbeigeAccountManager.h"

@interface NanbeigeEmailLoginViewController () <AccountManagerDelegate> {
	NSString *email;
	NSString *password;
	NanbeigeAccountManager *accountManager;
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
	
	self.navigationController.navigationBar.tintColor = navBarBgColor1;
	
	accountManager = [[NanbeigeAccountManager alloc] initWithViewController:self];
	accountManager.delegate = self;
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
	
	[accountManager emailLoginWithEmail:email Password:password];
	
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    [self loading:YES];
}

- (void)chooseSchool
{
	if (![[NSUserDefaults standardUserDefaults] objectForKey:kACCOUNTIDKEY]) {
		self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"欢迎" style:UIBarButtonItemStyleBordered target:nil action:nil];
		[self performSegueWithIdentifier:@"ChooseSchoolSegue" sender:self];
	} else {
		[[NSUserDefaults standardUserDefaults] setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kNANBEIGEIDKEY] forKey:kACCOUNTIDKEY];
		[[NSUserDefaults standardUserDefaults] setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kNANBEIGENICKNAMEKEY] forKey:kACCOUNTNICKNAMEKEY];
		[self dismissModalViewControllerAnimated:YES];
	}
}
- (void)confirmLogin
{
	if (![[NSUserDefaults standardUserDefaults] objectForKey:kACCOUNTIDKEY]) {
		self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"欢迎" style:UIBarButtonItemStyleBordered target:nil action:nil];
		[self performSegueWithIdentifier:@"ConfirmLoginSegue" sender:self];
	} else {
		[[NSUserDefaults standardUserDefaults] setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kNANBEIGEIDKEY] forKey:kACCOUNTIDKEY];
		[[NSUserDefaults standardUserDefaults] setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kNANBEIGENICKNAMEKEY] forKey:kACCOUNTNICKNAMEKEY];
		[self dismissModalViewControllerAnimated:YES];
	}
}
- (void)onEmailSignup:(id)sender
{
	self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"登录" style:UIBarButtonItemStyleBordered target:nil action:nil];
	[self performSegueWithIdentifier:@"EmailSignupSegue" sender:self];
}

- (void)didEmailLoginWithID:(NSNumber *)nanbeigeid
				   Nickname:(NSString *)nickname
			   UniversityID:(NSNumber *)university_id
			 UniversityName:(NSString *)university_name
{
	[self loading:NO];
	if (university_id) {
		[self confirmLogin];
	} else {
		[self chooseSchool];
	}
}
- (void)requestError:(NSString *)errorString
{
	[self loading:NO];
	[self showAlert:errorString];
}


@end
