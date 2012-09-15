//
//  CPEmailSignupViewController.m
//  CP
//
//  Created by ZongZiWang on 12-8-1.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import "CPSignupEmailViewController.h"
#import "Environment.h"
#import "Coffeepot.h"
#import "Models+addon.h"


@interface CPSignupEmailViewController () <UIAlertViewDelegate> {
	NSString *email;
	NSString *nickname;
	NSString *password;
}

@end

@implementation CPSignupEmailViewController

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
		self.root = [[QRootElement alloc] initWithJSONFile:@"signupEmail"];
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
	back_title = @" 登录 ";
	self.navigationItem.leftBarButtonItem = [UIBarButtonItem styledBackBarButtonItemWithTitle:back_title target:self.navigationController selector:@selector(popViewControllerAnimated:)];
	
	self.navigationItem.rightBarButtonItem = [UIBarButtonItem styledBlueBarButtonItemWithTitle:@"注册" target:self selector:@selector(onSignup:)];
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
	if ([nickname length] <= 0) {
        [self showAlert:@"昵称不能为空！"];
		return ;
    }
	
	[[NSUserDefaults standardUserDefaults] setObject:[User sharedAppUser].email forKey:@"sync_db_username"];
	[[NSUserDefaults standardUserDefaults] setObject:[User sharedAppUser].password forKey:@"sync_db_password"];
	[[NSUserDefaults standardUserDefaults] setObject:@"email" forKey:@"reg_by"];
	[User updateSharedAppUserProfile:@{ @"email" : email, @"nickname" : nickname, @"password" : password }];
	
	[self performSegueWithIdentifier:@"UniversitySelectSegue" sender:self];
}

- (void)loading:(BOOL)value
{
	if (!value) {
		[self.quickDialogTableView deselectRowAtIndexPath:[self.quickDialogTableView indexPathForSelectedRow] animated:YES];
	}
	[super loading:value];
}

@end