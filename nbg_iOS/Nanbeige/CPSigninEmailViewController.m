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

@interface CPSigninEmailViewController () <UIAlertViewDelegate> {
	NSString *email;
	NSString *password;
}

@end

@implementation CPSigninEmailViewController

#pragma mark - Setter and Getter Methods

- (void)setQuickDialogTableView:(QuickDialogTableView *)aQuickDialogTableView {
    [super setQuickDialogTableView:aQuickDialogTableView];
	[self.quickDialogTableView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg-TableView"]]];
}

#pragma mark - View Lifecycle

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self) {
		self.root = [[QRootElement alloc] initWithJSONFile:@"signinEmail"];
		self.resizeWhenKeyboardPresented = YES;
	}
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    NSArray *vcarray = self.navigationController.viewControllers;
    NSString *back_title = [[vcarray objectAtIndex:vcarray.count-2] title];
	back_title = @" 欢迎 ";
	self.navigationItem.leftBarButtonItem = [UIBarButtonItem styledBackBarButtonItemWithTitle:back_title target:self.navigationController selector:@selector(popViewControllerAnimated:)];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[User deactiveSharedAppUser];
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
							   delegate:self
					  cancelButtonTitle:sCONFIRM
					  otherButtonTitles:nil] show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	[self.quickDialogTableView deselectRowAtIndexPath:[self.quickDialogTableView indexPathForSelectedRow] animated:YES];
}

#pragma mark - Button controllerAction

- (void)onLogin:(id)sender {
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
		
		if ([collection isKindOfClass:[NSDictionary class]]) {
			
			[[NSUserDefaults standardUserDefaults] setObject:email forKey:@"sync_db_username"];
			[[NSUserDefaults standardUserDefaults] setObject:password forKey:@"sync_db_password"];
			[User updateSharedAppUserProfile:collection];
			
			[self loading:NO];
			[self performSegueWithIdentifier:@"SigninConfirmSegue" sender:self];
		} else {
			[self loading:NO];
			[self showAlert:[collection description]];//NSLog(@"%@", [error description]);
		}
		
	} error:^(CPRequest *request, NSError *error) {
		[self loading:NO];
		if ([error.userInfo objectForKey:@"error"]) [self showAlert:[error.userInfo objectForKey:@"error"]]; else [self showAlert:[error description]];//NSLog(@"%@", [error description]);
	}];
	
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    [self loading:YES];
}

- (void)onEmailSignup:(id)sender
{
	[self performSegueWithIdentifier:@"SignupEmailSegue" sender:self];
}

- (void)loading:(BOOL)value
{
	if (!value) {
		[self.quickDialogTableView deselectRowAtIndexPath:[self.quickDialogTableView indexPathForSelectedRow] animated:YES];
	}
	[super loading:value];
}

@end
