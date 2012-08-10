//
//  NanbeigeEmailSignupViewController.m
//  Nanbeige
//
//  Created by ZongZiWang on 12-8-1.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import "CPSignupEmailViewController.h"
#import "Environment.h"
#import "CPAccountManager.h"

@interface CPSignupEmailViewController () <CPAccountManagerDelegate> {
	NSString *email;
	NSString *nickname;
	NSString *password;
	CPAccountManager *accountManager;
}

@end

@implementation CPSignupEmailViewController

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
	
	accountManager = [[CPAccountManager alloc] initWithViewController:self];
	accountManager.delegate = self;
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
	
	[accountManager emailSignupWithEmail:email Password:password Nickname:nickname];
	
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    [self loading:YES];
}

#pragma mark - AccountManagerDelegate Email

- (void)didEmailSignupWithID:(NSNumber *)nanbeigeid
{
	[self loading:NO];
	
	if ([[NSUserDefaults standardUserDefaults] objectForKey:kACCOUNTIDKEY]) {
		[[NSUserDefaults standardUserDefaults] setObject:nanbeigeid forKey:kACCOUNTIDKEY];
		[[NSUserDefaults standardUserDefaults] setObject:nickname forKey:kACCOUNTNICKNAMEKEY];
	}
	if ([self.accountManagerDelegate respondsToSelector:@selector(didEmailLoginWithID:Nickname:UniversityID:UniversityName:CampusID:CampusName:)]) {
		[self.accountManagerDelegate didEmailLoginWithID:nanbeigeid Nickname:nickname UniversityID:nil UniversityName:nil CampusID:nil CampusName:nil];
	}
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark - AccountManagerDelegate Error

- (void)didRequest:(ASIHTTPRequest *)request FailWithError:(NSString *)errorString
{
	[self loading:NO];
	[self showAlert:errorString];
}

@end
