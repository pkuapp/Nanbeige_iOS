//
//  CPAccountManageViewController.m
//  CP
//
//  Created by ZongZiWang on 12-8-2.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import "CPAccountManageViewController.h"
#import "Coffeepot.h"
#import "Models+addon.h"
#import "Environment.h"
#import "MagicalRecord.h"

@interface CPAccountManageViewController () <UIAlertViewDelegate> {
	UIAlertView *nicknameEditAlert;
	UIAlertView *passwordEditAlert;
}

@end

@implementation CPAccountManageViewController

#pragma mark - Setter and Getter Methods

- (void)setQuickDialogTableView:(QuickDialogTableView *)aQuickDialogTableView {
    [super setQuickDialogTableView:aQuickDialogTableView];
	[self.quickDialogTableView setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg-TableView"]]];
	[self.quickDialogTableView setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg-TableView"]]];
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
		self.root = [[QRootElement alloc] initWithJSONFile:@"accountManage"];
	}
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self refreshDataSource];
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

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if ([alertView isEqual:nicknameEditAlert]) {
		if (buttonIndex == 1) {
			NSString *nickname = [[alertView textFieldAtIndex:0] text];
			[[Coffeepot shared] requestWithMethodPath:@"user/edit/" params:@{ @"nickname" : nickname } requestMethod:@"POST" success:^(CPRequest *_req, id collection) {
				
				[User updateSharedAppUserProfile:@{ @"nickname" : nickname }];
				
				[self refreshDataSource];
				
				[self loading:NO];
				
			} error:^(CPRequest *request, NSError *error) {
				[self loading:NO];
				[self showAlert:[error description]];//NSLog(@"%@", [error description]);
			}];
			
			[[[UIApplication sharedApplication] keyWindow] endEditing:YES];
			[self loading:YES];
		}
	}
	if ([alertView isEqual:passwordEditAlert]) {
		if (buttonIndex == 1) {
			NSString *password = [[alertView textFieldAtIndex:0] text];
			[[Coffeepot shared] requestWithMethodPath:@"user/edit/" params:@{ @"password" : password } requestMethod:@"POST" success:^(CPRequest *_req, id collection) {
				
				[self loading:NO];
				
			} error:^(CPRequest *request, NSError *error) {
				[self loading:NO];
				[self showAlert:[error description]];//NSLog(@"%@", [error description]);
			}];
			
			[[[UIApplication sharedApplication] keyWindow] endEditing:YES];
			[self loading:YES];
		}
	}
}

#pragma mark - Refresh

- (void)refreshDataSource
{
	[[NSManagedObjectContext defaultContext] save];
    User *appuser = [User sharedAppUser];
	NSString *nickname = appuser.nickname;
	if (!nickname) nickname = sDEFAULTNICKNAME;
	NSString *university = appuser.university_name;
	if (!university) university = sDEFAULTUNIVERSITY;
	NSString *campus = appuser.campus_name;
	if (campus) university = [university stringByAppendingFormat:@" %@", campus];
	
	NSMutableArray *loginaccount = [[NSMutableArray alloc] init];
	NSMutableArray *connectaccount = [[NSMutableArray alloc] init];
	
	if (appuser.email)
		[loginaccount addObject:[NSDictionary dictionaryWithObjectsAndKeys:sEMAIL, @"title", appuser.email, @"value", @"onLaunchActionSheet:", @"controllerAction", nil]];
	else
		[connectaccount addObject:[NSDictionary dictionaryWithObjectsAndKeys:sCONNECTEMAIL, @"title", @"onConnectEmail:", @"controllerAction", nil]];
	
	if (appuser.renren_name)
		[loginaccount addObject:[NSDictionary dictionaryWithObjectsAndKeys:sRENREN, @"title", appuser.renren_name, @"value", @"onLaunchActionSheet:", @"controllerAction",nil]];
	else
		[connectaccount addObject:[NSDictionary dictionaryWithObjectsAndKeys:sCONNECTRENREN, @"title", @"onConnectRenren:", @"controllerAction", nil]];
	
	if (appuser.weibo_name)
		[loginaccount addObject:[NSDictionary dictionaryWithObjectsAndKeys:sWEIBO, @"title", appuser.weibo_name, @"value", @"onLaunchActionSheet:", @"controllerAction",nil]];
	else
		[connectaccount addObject:[NSDictionary dictionaryWithObjectsAndKeys:sCONNECTWEIBO, @"title", @"onConnectWeibo:", @"controllerAction", nil]];
	
	NSDictionary *dict = @{
	@"identity": @[
	@{ @"title" : sNICKNAME, @"value" : nickname, @"controllerAction" : @"onEditNickname:" } ,
	@{ @"title" : sUNIVERSITY, @"value" : university , @"controllerAction" :  @"onEditUniversity:" } ] ,
	@"loginaccount" : loginaccount,
	@"connectaccount" : connectaccount};
	[self.root bindToObject:dict];
	
	[self.quickDialogTableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 3)] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - Button controllerAction

- (void)onEditNickname:(id)sender
{	
	nicknameEditAlert = [[UIAlertView alloc] initWithTitle:sEDITNICKNAME message:nil delegate:self cancelButtonTitle:sCANCEL otherButtonTitles:sCONFIRM, nil];
	nicknameEditAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
	[nicknameEditAlert show];
}

- (void)onEditUniversity:(id)sender
{
	[self performSegueWithIdentifier:@"UniversitySelectSegue" sender:self];
}

- (void)onConnectEmail:(id)sender
{
	[self showAlert:@"绑定Email功能暂未实现"];
//	[self performSegueWithIdentifier:@"ConnectEmailSegue" sender:self];
}

- (void)onConnectWeibo:(id)sender
{
    self.weibo.delegate = self;
    self.weibo.isUserExclusive = NO;
    self.weibo.redirectURI = @"https://api.weibo.com/oauth2/default.html";
    [self.weibo logIn];
}

- (void)onConnectRenren:(id)sender
{
	[self.renren delUserSessionInfo];
	NSArray *permissions = [[NSArray alloc] initWithObjects:@"status_update", nil];
	[self.renren authorizationInNavigationWithPermisson:permissions
											andDelegate:self];
	[self.quickDialogTableView deselectRowAtIndexPath:[self.quickDialogTableView indexForElement:sender] animated:YES];
}

- (void)onLaunchActionSheet:(id)sender
{
	[self.quickDialogTableView deselectRowAtIndexPath:[self.quickDialogTableView indexForElement:sender] animated:YES];
	NSString *disconnectOrLogout = [dictLABEL2ACTIONSHEET objectForKey:[sender title]];
	NSString *otherButtonTitle = nil;
	if ([[sender title] isEqualToString:sEMAIL]) {
		otherButtonTitle = sEDITPASSWORD;
	}
	if ([disconnectOrLogout isEqualToString:sDISCONNECTEMAIL] || [disconnectOrLogout isEqualToString:sDISCONNECTRENREN] || [disconnectOrLogout isEqualToString:sDISCONNECTWEIBO]) disconnectOrLogout = nil;
	if (!disconnectOrLogout && !otherButtonTitle) return ;
	
	UIActionSheet *menu = [[UIActionSheet alloc] initWithTitle:nil
													  delegate:self
											 cancelButtonTitle:sCANCEL
										destructiveButtonTitle:disconnectOrLogout
											 otherButtonTitles:otherButtonTitle, nil];
	[menu showInView:self.view];
}

#pragma mark - ActionSheetDelegate Setup

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	NSString *method = [actionSheet buttonTitleAtIndex:buttonIndex];
	if ([method isEqualToString:sLOGOUT]) 
		[self onLogout:self];
	if ([method isEqualToString:sDISCONNECTEMAIL])
		[self onDisconnectEmail:self];
	if ([method isEqualToString:sDISCONNECTRENREN])
		[self onDisconnectRenren:self];
	if ([method isEqualToString:sDISCONNECTWEIBO])
		[self onDisconnectWeibo:self];
	if ([method isEqualToString:sEDITPASSWORD])
		[self onEditPassword:self];
	if ([method isEqualToString:sEDITNICKNAME])
		[self onEditNickname:self];
}

#pragma mark - ActionSheet Button controllerAction

- (void)onEditPassword:(id)sender
{
	passwordEditAlert = [[UIAlertView alloc] initWithTitle:sEDITPASSWORD message:nil delegate:self cancelButtonTitle:sCANCEL otherButtonTitles:sCONFIRM, nil];
	passwordEditAlert.alertViewStyle = UIAlertViewStyleSecureTextInput;
	[passwordEditAlert show];
	[self.quickDialogTableView deselectRowAtIndexPath:[self.quickDialogTableView indexForElement:sender] animated:YES];
}

- (void)onLocalRenrenLogout:(id)sender
{
	[self.renren logout:self];
}
- (void)onDisconnectRenren:(id)sender
{
	[User sharedAppUser].renren_name = nil;
	[User sharedAppUser].renren_token = nil;
	[self onLocalRenrenLogout:sender];
	// TODO disconnect Renren on Server
	[self refreshDataSource];
}

- (void)onLocalWeiboLogout:(id)sender
{
	[self.weibo logOut];
}
- (void)onDisconnectWeibo:(id)sender
{
	[User sharedAppUser].weibo_name = nil;
	[User sharedAppUser].weibo_token = nil;
	[self onLocalWeiboLogout:sender];
	// TODO disconnect Weibo on Server
	[self refreshDataSource];
}

- (void)onLocalEmailLogout:(id)sender
{
	[[Coffeepot shared] requestWithMethodPath:@"user/logout/" params:nil requestMethod:@"POST" success:^(CPRequest *_req, id collection) {
		
		[self loading:NO];
		
	} error:^(CPRequest *request, NSError *error) {
		[self loading:NO];
		NSLog(@"AccountManage:onLocalEmailLogout %@", [error description]);
	}];
	
	[[[UIApplication sharedApplication] keyWindow] endEditing:YES];
	[self loading:YES];
}
- (void)onDisconnectEmail:(id)sender
{
	[User sharedAppUser].email = nil;
	[self onLocalEmailLogout:sender];
	// TODO disconnect Email on Server
	[self refreshDataSource];
}

- (void)onLogout:(id)sender
{
	[self onLocalRenrenLogout:sender];
	[self onLocalWeiboLogout:sender];
	[self onLocalEmailLogout:sender];
	
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
	
	[User deactiveSharedAppUser];
	
	id workaround51Crash = [[NSUserDefaults standardUserDefaults] objectForKey:@"WebKitLocalStorageDatabasePathPreferenceKey"];
	NSDictionary *emptySettings = (workaround51Crash != nil)
	? [NSDictionary dictionaryWithObject:workaround51Crash forKey:@"WebKitLocalStorageDatabasePathPreferenceKey"]
	: [NSDictionary dictionary];
	[[NSUserDefaults standardUserDefaults] setPersistentDomain:emptySettings forName:[[NSBundle mainBundle] bundleIdentifier]];
	
	UIStoryboard *sb = [UIStoryboard storyboardWithName:@"CPSigninFlow" bundle:[NSBundle mainBundle]];
	[UIApplication sharedApplication].delegate.window.rootViewController = [sb instantiateInitialViewController];
}

#pragma mark - WBEngineDelegate

- (void)engineDidLogIn:(WBEngine *)engine
{
	
	NSDictionary *params = @{ @"uid" : self.weibo.userID };
    
	[self.weibo loadRequestWithMethodName:@"users/show.json" httpMethod:@"GET" params:params postDataType:kWBRequestPostDataTypeNone httpHeaderFields:nil
								  success:^(WBRequest *request, id result) {
									  
									  if ([result isKindOfClass:[NSDictionary class]] && [result objectForKey:@"screen_name"]) {
										  
										  [[Coffeepot shared] requestWithMethodPath:@"user/edit/" params:@{@"weibo_token":self.weibo.accessToken} requestMethod:@"POST" success:^(CPRequest *_req, id collection) {
											  
											  [User updateSharedAppUserProfile:@{ @"weibo" : @{ @"id" : [NSNumber numberWithInteger:[[self.weibo userID] integerValue]] , @"name" : [result objectForKey:@"screen_name"] , @"token" : [self.weibo accessToken] } }];
											  
											  [self refreshDataSource];
											  
											  [self loading:NO];
											  
										  } error:^(CPRequest *request, NSError *error) {
											  [self loading:NO];
											  [self showAlert:[error description]];//NSLog(@"%@", [error description]);
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
								    
								  [[Coffeepot shared] requestWithMethodPath:@"user/edit/" params:@{@"renren_token":self.renren.accessToken} requestMethod:@"POST" success:^(CPRequest *_req, id collection) {
									  
									  [User updateSharedAppUserProfile:@{ @"renren" : @{ @"id" : [[result objectAtIndex:0] objectForKey:@"uid"] , @"name" : [[result objectAtIndex:0] objectForKey:@"name"] , @"token" : [self.renren accessToken]  } }];
									  
									  [self refreshDataSource];
									  
									  [self loading:NO];

								  } error:^(CPRequest *request, NSError *error) {
									  [self loading:NO];
									  [self showAlert:[error description]];//NSLog(@"%@", [error description]);
								  }];
							  } else if ([result isKindOfClass:[NSDictionary class]]) {
								  NSLog(@"AccountManage:renrenDidLogin %@", result);
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

@end

