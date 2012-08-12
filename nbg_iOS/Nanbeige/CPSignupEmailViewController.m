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


@interface CPSignupEmailViewController () {
	NSString *email;
	NSString *nickname;
	NSString *password;
}

@end

@implementation CPSignupEmailViewController

#pragma mark - Setter and Getter Methods

- (void)setQuickDialogTableView:(QuickDialogTableView *)aQuickDialogTableView {
    [super setQuickDialogTableView:aQuickDialogTableView];
    self.quickDialogTableView.backgroundView = nil;
    self.quickDialogTableView.backgroundColor = tableBgColor1;
    self.quickDialogTableView.bounces = NO;
	self.quickDialogTableView.deselectRowWhenViewAppears = YES;
}

#pragma mark - View Lifecycle

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self) {
		self.root = [[QRootElement alloc] initWithJSONFile:@"signupEmail"];
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
	
	[[Coffeepot shared] requestWithMethodPath:@"user/reg/email/" params:@{@"email":email, @"password":password ,@"nickname":nickname} requestMethod:@"POST" success:^(CPRequest *_req, NSDictionary *collection) {
		[self loading:NO];
		
		[User updateSharedAppUserProfile:collection];
		[self performSegueWithIdentifier:@"UniversitySelectSegue" sender:self];
		
	} error:^(CPRequest *_req,NSDictionary *collection, NSError *error) {
		[self loading:NO];
		if ([collection objectForKey:@"error"]) {
			raise(-1);
		}
	}];
	
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    [self loading:YES];
}

@end