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
#import "Coffeepot.h"
#import "Models+addon.h"

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
    self.quickDialogTableView.backgroundColor = tableBgColorGrouped;
    self.quickDialogTableView.bounces = NO;
	self.quickDialogTableView.deselectRowWhenViewAppears = YES;
}

#pragma mark - View Lifecycle

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self) {
		self.root = [[QRootElement alloc] initWithJSONFile:@"signinEmail"];
	}
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	UIBarButtonItem *loginButton = [[UIBarButtonItem alloc] initWithTitle:@"登录" style:UIBarButtonItemStyleBordered target:self action:@selector(onLogin:)];
//	UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:sCANCEL style:UIBarButtonItemStyleBordered target:self action:@selector(close)];
	self.navigationItem.rightBarButtonItem = loginButton;
//	self.navigationItem.leftBarButtonItem = closeButton;
	
	self.navigationController.navigationBar.tintColor = navBarBgColor1;	
}

- (void)viewWillAppear:(BOOL)animated
{
	self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"欢迎" style:UIBarButtonItemStyleBordered target:nil action:nil];
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
	
	[[Coffeepot shared] requestWithMethodPath:@"user/login/email/" params:@{@"email":email, @"password":password } requestMethod:@"POST" success:^(CPRequest *_req, id collection) {
		[self loading:NO];
		
		[[NSUserDefaults standardUserDefaults] setObject:email forKey:@"sync_db_username"];
		[[NSUserDefaults standardUserDefaults] setObject:password forKey:@"sync_db_password"];
		
		[User updateSharedAppUserProfile:collection];
		[self performSegueWithIdentifier:@"SigninConfirmSegue" sender:self];
		
	} error:^(CPRequest *request, NSError *error) {
		[self loading:NO];
		[self showAlert:[error description]];//NSLog(%"%@", [error description]);
	}];
	
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    [self loading:YES];
}

- (void)onEmailSignup:(id)sender
{
	self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"登录" style:UIBarButtonItemStyleBordered target:nil action:nil];
	[self performSegueWithIdentifier:@"SignupEmailSegue" sender:self];
}

@end
