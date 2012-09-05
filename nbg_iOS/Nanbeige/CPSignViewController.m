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
	[self.quickDialogTableView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg-TableView"]]];
}

- (WBEngine *)weibo {
    if (!_weibo) {
        _weibo = [WBEngine sharedWBEngine];
        _weibo.rootViewController = self;
    }
    return _weibo;
}

- (Renren *)renren {
	if (!_renren) {
		_renren = [Renren sharedRenren];
	}
	return _renren;
}

#pragma mark - View Lifecycle

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self) {
		self.root = [[QRootElement alloc] initWithJSONFile:@"sign"];
		self.resizeWhenKeyboardPresented = YES;
	}
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
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
	
	[User deactiveSharedAppUser];
	
	id workaround51Crash = [[NSUserDefaults standardUserDefaults] objectForKey:@"WebKitLocalStorageDatabasePathPreferenceKey"];
	NSDictionary *emptySettings = (workaround51Crash != nil)
	? [NSDictionary dictionaryWithObject:workaround51Crash forKey:@"WebKitLocalStorageDatabasePathPreferenceKey"]
	: [NSDictionary dictionary];
	[[NSUserDefaults standardUserDefaults] setPersistentDomain:emptySettings forName:[[NSBundle mainBundle] bundleIdentifier]];
	
	((CPAppDelegate *)[UIApplication sharedApplication].delegate).progressHud = nil;
	
	CouchDatabase *localDatabase = [(CPAppDelegate *)([UIApplication sharedApplication].delegate) localDatabase];
	CouchQuery *query = [localDatabase getAllDocuments];
	RESTOperation *op = [query start];
	if ([op wait]) {
		NSMutableArray *docs = [@[] mutableCopy];
		for (CouchQueryRow *row in query.rows) {
			[docs addObject:row.document];
		}
		[localDatabase deleteDocuments:docs];
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
	[self.renren delUserSessionInfo];
	NSArray *permissions = [[NSArray alloc] initWithObjects:@"status_update", nil];
	[self.renren authorizationInNavigationWithPermisson:permissions
											andDelegate:self];
	[self.quickDialogTableView deselectRowAtIndexPath:[self.quickDialogTableView indexPathForSelectedRow] animated:YES];
}

#pragma mark - WBEngineDelegate

- (void)engineDidLogIn:(WBEngine *)engine
{
	
	NSDictionary *params = @{ @"uid" : self.weibo.userID };
    
	[self.weibo loadRequestWithMethodName:@"users/show.json" httpMethod:@"GET" params:params postDataType:kWBRequestPostDataTypeNone httpHeaderFields:nil
    success:^(WBRequest *request, id result) {
		
		if ([result isKindOfClass:[NSDictionary class]] && [result objectForKey:@"screen_name"]) {
			
			[[Coffeepot shared] requestWithMethodPath:@"user/login/weibo/" params:@{@"token":self.weibo.accessToken} requestMethod:@"POST" success:^(CPRequest *_req, id collection) {
				
				[[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"-weibo-%@", self.weibo.userID] forKey:@"sync_db_username"];
				[[NSUserDefaults standardUserDefaults] setObject:self.weibo.accessToken forKey:@"sync_db_password"];
                [User updateSharedAppUserProfile:@{ @"weibo" : @{ @"id" : [NSNumber numberWithInteger:[[self.weibo userID] integerValue]] , @"name" : [result objectForKey:@"screen_name"] , @"token" : [self.weibo accessToken] } }];
				[User updateSharedAppUserProfile:collection];
				
				[self loading:NO];
				
                [self performSegueWithIdentifier:@"SigninConfirmSegue" sender:self];
                
            } error:^(CPRequest *request, NSError *error) {
				
				if ([[error.userInfo objectForKey:@"error_code"] isEqualToString:@"UserNotFound"]) {
                    
					[[Coffeepot shared] requestWithMethodPath:@"user/reg/weibo/" params:@{@"token":self.weibo.accessToken, @"nickname":[result objectForKey:@"screen_name"]} requestMethod:@"POST" success:^(CPRequest *_req, NSDictionary *collection) {					
						[[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"-weibo-%@", self.weibo.userID] forKey:@"sync_db_username"];
						[[NSUserDefaults standardUserDefaults] setObject:self.weibo.accessToken forKey:@"sync_db_password"];
						[User updateSharedAppUserProfile:@{ @"weibo" : @{ @"id" : [NSNumber numberWithInteger:[[self.weibo userID] integerValue]] , @"name" : [result objectForKey:@"screen_name"] , @"token" : [self.weibo accessToken] } }];
						[User updateSharedAppUserProfile:collection];
						
						[self loading:NO];
						
						[self performSegueWithIdentifier:@"UniversitySelectSegue" sender:self];
						
					} error:^(CPRequest *request, NSError *error) {
						[self loading:NO];
						[self showAlert:[error description]];//NSLog(@"%@", [error description]);
					}];
					
                } else {
					[self loading:NO];
					[self showAlert:[error description]];//NSLog(@"%@", [error description]);
				}
            }];
        } else {
			[self loading:NO];
			[self showAlert:[result description]];//NSLog(@"%@", [error description]);
		}
    }
    fail:^(WBRequest *request, NSError *error) {
        [self loading:NO];
		[self showAlert:[error description]];//NSLog(@"%@", [error description]);
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
	
}

// When you use the WBEngine's request methods,
// you may receive the following four callbacks.
- (void)engineNotAuthorized:(WBEngine *)engine
{
	
}
- (void)engineAuthorizeExpired:(WBEngine *)engine
{
	
}

#pragma mark - RenrenDelegate

/**
 * 授权登录成功时被调用，第三方开发者实现这个方法
 * @param renren 传回代理授权登录接口请求的Renren类型对象。
 */
- (void)renrenDidLogin:(Renren *)renren
{
	ROUserInfoRequestParam *requestParam = [[ROUserInfoRequestParam alloc] init];
	requestParam.fields = [NSString stringWithFormat:@"uid,name"];
	
	[self.renren requestWithParam:requestParam
					  andDelegate:self
						  success:^(RORequest *request, id result) {
							  
							  if ([result isKindOfClass:[NSArray class]] && [[result objectAtIndex:0] objectForKey:@"name"]) {
								  
								  [[Coffeepot shared] requestWithMethodPath:@"user/login/renren/" params:@{@"token":self.renren.accessToken} requestMethod:@"POST" success:^(CPRequest *_req, id collection) {
									  
									  [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"-renren-%@", [[result objectAtIndex:0] objectForKey:@"id"]] forKey:@"sync_db_username"];
									  [[NSUserDefaults standardUserDefaults] setObject:self.renren.accessToken forKey:@"sync_db_password"];
									  [User updateSharedAppUserProfile:@{ @"renren" : @{ @"id" : [[result objectAtIndex:0] objectForKey:@"uid"] , @"name" : [[result objectAtIndex:0] objectForKey:@"name"] , @"token" : [self.renren accessToken]  } }];
									  [User updateSharedAppUserProfile:collection];
									  
									  [self loading:NO];

									  [self performSegueWithIdentifier:@"SigninConfirmSegue" sender:self];

								  } error:^(CPRequest *request, NSError *error) {
	
									  if ([[error.userInfo objectForKey:@"error_code"] isEqualToString:@"UserNotFound"]) {
										  
										  [[Coffeepot shared] requestWithMethodPath:@"user/reg/renren/" params:@{@"token":self.renren.accessToken, @"nickname":[[result objectAtIndex:0] objectForKey:@"name"]} requestMethod:@"POST" success:^(CPRequest *_req, NSDictionary *collection) {
											  
											  [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"-renren-%@", [[result objectAtIndex:0] objectForKey:@"id"]] forKey:@"sync_db_username"];
											  [[NSUserDefaults standardUserDefaults] setObject:self.renren.accessToken forKey:@"sync_db_password"];
											  [User updateSharedAppUserProfile:@{ @"renren" : @{ @"id" : [[result objectAtIndex:0] objectForKey:@"uid"] , @"name" : [[result objectAtIndex:0] objectForKey:@"name"] , @"token" : [self.renren accessToken]  } }];
											  [User updateSharedAppUserProfile:collection];
											  
											  [self loading:NO];

											  [self performSegueWithIdentifier:@"UniversitySelectSegue" sender:self];
											  
										  } error:^(CPRequest *request, NSError *error) {
											  [self loading:NO];
											  [self showAlert:[error description]];//NSLog(@"%@", [error description]);
										  }];
										  
									  } else {
										  [self loading:NO];
										  [self showAlert:[error description]];//NSLog(@"%@", [error description]);
									  }
									  
								  }];
								  
							  } else if ([result isKindOfClass:[NSDictionary class]]) {
								  NSLog(@"Sign:renrenDidLogin %@", result);
							  } else {
								  [self loading:NO];
								  [self showAlert:[result description]];//NSLog(@"%@", [error description]);
							  }
						  }
							 fail:^(RORequest *request, ROError *error) {
								 [self loading:NO];
								 [self showAlert:[error description]];//NSLog(@"%@", [error description]);
							 }
	 ];
	
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    [self loading:YES];
}

/**
 * 用户登出成功后被调用 第三方开发者实现这个方法
 * @param renren 传回代理登出接口请求的Renren类型对象。
 */
- (void)renrenDidLogout:(Renren *)renren
{
	
}

/**
 * 授权登录失败时被调用，第三方开发者实现这个方法
 * @param renren 传回代理授权登录接口请求的Renren类型对象。
 */
- (void)renren:(Renren *)renren loginFailWithError:(ROError*)error
{
	
}

/**
 * 接口请求成功，第三方开发者实现这个方法
 * @param renren 传回代理服务器接口请求的Renren类型对象。
 * @param response 传回接口请求的响应。
 */
- (void)renren:(Renren *)renren requestDidReturnResponse:(ROResponse*)response
{
	
}

/**
 * 接口请求失败，第三方开发者实现这个方法
 * @param renren 传回代理服务器接口请求的Renren类型对象。
 * @param response 传回接口请求的错误对象。
 */
- (void)renren:(Renren *)renren requestFailWithError:(ROError*)error
{
	
}

/**
 * renren取消Dialog时调用，第三方开发者实现这个方法
 * @param renren 传回代理授权登录接口请求的Renren类型对象。
 */
- (void)renrenDialogDidCancel:(Renren *)renren
{
	
}

- (void)loading:(BOOL)value
{
	if (!value) {
		[self.quickDialogTableView deselectRowAtIndexPath:[self.quickDialogTableView indexPathForSelectedRow] animated:YES];
	}
	[super loading:value];
}

@end
