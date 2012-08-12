//
//  CPChooseLoginViewController.m
//  CP
//
//  Created by ZongZiWang on 12-8-1.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import "CPSignViewController.h"
#import "Environment.h"

#import "CPSigninEmailViewController.h"
#import "Coffeepot.h"

#import "Models+addon.h"

#import <Objection-iOS/Objection.h>

@interface CPSignViewController () {

}

@end

@implementation CPSignViewController

#pragma mark - Setter and Getter Methods

- (void)setQuickDialogTableView:(QuickDialogTableView *)aQuickDialogTableView {
    [super setQuickDialogTableView:aQuickDialogTableView];
    self.quickDialogTableView.backgroundView = nil;
    self.quickDialogTableView.backgroundColor = tableBgColor1;
    self.quickDialogTableView.bounces = NO;
	self.quickDialogTableView.deselectRowWhenViewAppears = YES;
}

- (WBEngine *)weibo {
    if (!_weibo) {
        _weibo = [WBEngine sharedWBEngine];
        _weibo.rootViewController = self;
    }
    return _weibo;
}

#pragma mark - View Lifecycle

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self) {
		self.root = [[QRootElement alloc] initWithJSONFile:@"sign"];
	}
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	self.navigationController.navigationBar.tintColor = navBarBgColor1;
	self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"欢迎" style:UIBarButtonItemStyleBordered target:nil action:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	//Only clean defaults when Login Methods show to choose
	id workaround51Crash = [[NSUserDefaults standardUserDefaults] objectForKey:@"WebKitLocalStorageDatabasePathPreferenceKey"];
	NSDictionary *emptySettings = (workaround51Crash != nil)
	? [NSDictionary dictionaryWithObject:workaround51Crash forKey:@"WebKitLocalStorageDatabasePathPreferenceKey"]
	: [NSDictionary dictionary];
	[[NSUserDefaults standardUserDefaults] setPersistentDomain:emptySettings forName:[[NSBundle mainBundle] bundleIdentifier]];
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

- (void)onEmailLogin:(id)sender
{
	[self performSegueWithIdentifier:@"SigninEmailSegue" sender:self];
}

- (void)onWeiboLogin:(id)sender
{
    self.weibo.delegate = self;
    self.weibo.isUserExclusive = NO;
    self.weibo.redirectURI = @"https://api.weibo.com/oauth2/default.html";
    [self.weibo logIn];

}

- (void)onRenrenLogin:(id)sender
{
    
}

#pragma mark - WBEngineDelegate

- (void)engineDidLogIn:(WBEngine *)engine
{
	
	NSDictionary *params = @{ @"uid" : self.weibo.userID };
    
	[self.weibo loadRequestWithMethodName:@"users/show.json" httpMethod:@"GET" params:params postDataType:kWBRequestPostDataTypeNone httpHeaderFields:nil
    success:^(WBRequest *request, id result) {
        if ([result isKindOfClass:[NSDictionary class]] && [result objectForKey:kAPISCREEN_NAME]) {
            
			[[Coffeepot shared] requestWithMethodPath:@"user/login/weibo/" params:@{@"token":self.weibo.accessToken} requestMethod:@"POST" success:^(CPRequest *_req, NSDictionary *collection) {
                
                [User updateSharedAppUserProfile:collection];
                [self performSegueWithIdentifier:@"SigninConfirmSegue" sender:self];
                
            } error:^(CPRequest *_req,NSDictionary *collection, NSError *error) {
                
				if ([[collection objectForKey:@"error_code"] isEqualToString:@"UserNotFound"]) {
                    
					[[Coffeepot shared] requestWithMethodPath:@"user/reg/weibo/" params:@{@"token":self.weibo.accessToken, @"nickname":[result objectForKey:kAPISCREEN_NAME]} requestMethod:@"POST" success:^(CPRequest *_req, NSDictionary *collection) {
						
						[User updateSharedAppUserProfile:collection];
						[self performSegueWithIdentifier:@"UniversitySelectSegue" sender:self];
							
						
					} error:^(CPRequest *_req,NSDictionary *collection, NSError *error) {
						if ([collection objectForKey:@"error"]) {
							raise(-1);
						}
					}];
                } else if ([collection objectForKey:@"error"]) {
					raise(-1);
				}
            }];
        }
    }
    fail:^(WBRequest *request, NSError *error) {
        [self loading:NO];
        [self showAlert:error.description];
    }];
	
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    [self loading:YES];
}

// Failed to log in.
// Possible reasons are:
// 1) Either username or password is wrong;
// 2) Your app has not been authorized by Sina yet.
- (void)engine:(WBEngine *)engine didFailToLogInWithError:(NSError *)error
{
	if ([self respondsToSelector:@selector(didRequest:FailWithError:)]) {
//		[self didRequest:nil FailWithError:[error description]];
	}
}

// When you use the WBEngine's request methods,
// you may receive the following four callbacks.
- (void)engineNotAuthorized:(WBEngine *)engine
{
	if ([self respondsToSelector:@selector(didRequest:FailWithError:)]) {
//		[self didRequest:nil FailWithError:@"微博未授权"];
	}
}
- (void)engineAuthorizeExpired:(WBEngine *)engine
{
	if ([self respondsToSelector:@selector(didRequest:FailWithError:)]) {
//		[self didRequest:nil FailWithError:@"微博授权已过期"];
	}
}

@end
