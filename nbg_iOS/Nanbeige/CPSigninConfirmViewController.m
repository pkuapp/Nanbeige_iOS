//
//  CPConfirmLoginViewController.m
//  CP
//
//  Created by ZongZiWang on 12-8-1.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import "CPSigninConfirmViewController.h"
#import "Environment.h"
#import "Coffeepot.h"
#import "Models+addon.h"

@interface CPSigninConfirmViewController ()

@end

@implementation CPSigninConfirmViewController

#pragma mark - Setter and Getter Methods

- (void)setQuickDialogTableView:(QuickDialogTableView *)aQuickDialogTableView {
    [super setQuickDialogTableView:aQuickDialogTableView];
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
		self.root = [[QRootElement alloc] initWithJSONFile:@"signinConfirm"];
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
}

- (void)onConfirmLogin:(id)sender
{	
	if (![[User sharedAppUser].id integerValue]) {
		NSMutableDictionary *params = [@{@"email":[User sharedAppUser].email, @"password":[User sharedAppUser].password, @"nickname":[User sharedAppUser].nickname} mutableCopy];
		if ([User sharedAppUser].campus_id) [params setObject:[User sharedAppUser].campus_id forKey:@"campus_id"];
		[[Coffeepot shared] requestWithMethodPath:@"user/reg/email/" params:params requestMethod:@"POST" success:^(CPRequest *_req, id collection) {

			[[NSUserDefaults standardUserDefaults] setObject:[User sharedAppUser].email forKey:@"sync_db_username"];
			[[NSUserDefaults standardUserDefaults] setObject:[User sharedAppUser].password forKey:@"sync_db_password"];
			[User updateSharedAppUserProfile:collection];
			
			[self onFetchUniversity:[User sharedAppUser].university_id];

		} error:^(CPRequest *request, NSError *error) {
			[self loading:NO];
			if ([[error.userInfo objectForKey:@"error"] isEqualToString:@"Email 已被使用。"]) {
				[self showAlert:[error.userInfo objectForKey:@"error"]];
			} else {
				[self showAlert:[error description]];//NSLog(@"%@", [error description]);
			}
		}];
		
	} else {
		[self onFetchUniversity:[User sharedAppUser].university_id];
	}
	
	[[[UIApplication sharedApplication] keyWindow] endEditing:YES];
	[self loading:YES];
	
}

- (void)onFetchUniversity:(NSNumber *)university_id
{
	
	[[Coffeepot shared] requestWithMethodPath:[NSString stringWithFormat:@"university/%@/", university_id] params:nil requestMethod:@"GET" success:^(CPRequest *_req, id collection) {
		
		if ([collection isKindOfClass:[NSDictionary class]]) {
			NSDictionary *universityDict = collection;
			
			University *university = [University universityWithID:university_id];
			university.doc_type = @"university";
			university.id = university_id;
			university.name = [universityDict objectForKey:@"name"];
			university.support_import_course = [[universityDict objectForKey:@"support"] objectForKey:@"import_course"];
			university.support_list_course = [[universityDict objectForKey:@"support"] objectForKey:@"list_course"];
			university.lessons_count_afternoon = [[[universityDict objectForKey:@"lessons"] objectForKey:@"count"] objectForKey:@"afternoon"];
			university.lessons_count_evening = [[[universityDict objectForKey:@"lessons"] objectForKey:@"count"] objectForKey:@"evening"];
			university.lessons_count_morning = [[[universityDict objectForKey:@"lessons"] objectForKey:@"count"] objectForKey:@"morning"];
			university.lessons_count_total = [[[universityDict objectForKey:@"lessons"] objectForKey:@"count"] objectForKey:@"total"];
			university.lessons_detail = [[universityDict objectForKey:@"lessons"] objectForKey:@"detail"];
			university.lessons_separators = [[universityDict objectForKey:@"lessons"] objectForKey:@"separators"];
			
			RESTOperation *op = [university save];
			if (op && ![op wait]) [self showAlert:[op.error description]];
			else {
				[self onFetchSemester:university_id];
			}
			
		} else {
			[self loading:NO];
			[self showAlert:@"University返回结果不是NSDictionary"];
		}
		
	} error:^(CPRequest *request, NSError *error) {
		[self loading:NO];
		[self showAlert:[error description]];//NSLog(@"%@", [error description]);
	}];
}

- (void)onFetchSemester:(NSNumber *)university_id
{
	[[Coffeepot shared] requestWithMethodPath:[NSString stringWithFormat:@"university/%@/semester/", university_id] params:nil requestMethod:@"GET" success:^(CPRequest *_req, id collection) {
		
		if ([collection isKindOfClass:[NSArray class]]) {
			
			for (NSDictionary *semesterDict in collection) {
				
				Semester *semester = [Semester semesterWithID:[semesterDict objectForKey:@"id"]];
				
				semester.doc_type = @"semester";
				semester.id = [semesterDict objectForKey:@"id"];
				semester.name = [semesterDict objectForKey:@"name"];
				semester.year = [semesterDict objectForKey:@"year"];
				semester.week_start = [[semesterDict objectForKey:@"week"] objectForKey:@"start"];
				semester.week_end = [[semesterDict objectForKey:@"week"] objectForKey:@"end"];
				
				RESTOperation *op = [semester save];
				if (op && ![op wait])
					[self showAlert:[op.error description]];
				else {
					[self onFetchWeekset:[semesterDict objectForKey:@"id"]];
				}
			}
			
			[self loading:NO];
			
			[self onComplete];
			
		} else {
			[self loading:NO];
			[self showAlert:@"Semester返回结果不是NSArray"];
		}
		
	} error:^(CPRequest *request, NSError *error) {
		[self loading:NO];
		[self showAlert:[error description]];//NSLog(@"%@", [error description]);
	}];
}

- (void)onFetchWeekset:(NSNumber *)semester_id
{
	
	[[Coffeepot shared] requestWithMethodPath:[NSString stringWithFormat:@"university/semester/%@/weekset/", semester_id] params:nil requestMethod:@"GET" success:^(CPRequest *_req, id collection) {
		
		if ([collection isKindOfClass:[NSArray class]]) {
			
			for (NSDictionary *weeksetDict in collection) {
				
				Weekset *weekset = [Weekset weeksetWithID:[weeksetDict objectForKey:@"id"]];
				
				weekset.doc_type = @"weekset";
				weekset.id = [weeksetDict objectForKey:@"id"];
				weekset.name = [weeksetDict objectForKey:@"name"];
				weekset.weeks = [weeksetDict objectForKey:@"weeks"];
				
				RESTOperation *op = [weekset save];
				if (op && ![op wait])
					[self showAlert:[op.error description]];
				else {
					
				}
			}
			
		} else {
			[self loading:NO];
			[self showAlert:@"Weekset返回结果不是NSArray"];
		}
		
	} error:^(CPRequest *request, NSError *error) {
		[self loading:NO];
		[self showAlert:[error description]];//NSLog(@"%@", [error description]);
	}];
}

- (void)onComplete
{
	[[NSUserDefaults standardUserDefaults] setObject: @1 forKey:@"CPIsSignedIn"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	UIStoryboard *sb = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:[NSBundle mainBundle]];
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
								  NSLog(@"SigninConfirm:renrenDidLogin %@", result);
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
