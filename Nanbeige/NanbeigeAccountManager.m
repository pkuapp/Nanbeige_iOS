//
//  NanbeigeAccountManager.m
//  Nanbeige
//
//  Created by ZongZiWang on 12-8-3.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import "NanbeigeAccountManager.h"
#import "ASIFormDataRequest.h"
#import "ASIHTTPRequest.h"
#import "Environment.h"
#import "Renren.h"
#import "ROConnect.h"
#import "WBEngine.h"

@interface NanbeigeAccountManager () <RenrenDelegate, WBEngineDelegate> {
	WBEngine *weiBoEngine;
	Renren *renrenEngine;
	
	ASIFormDataRequest *emailLoginRequest;
	ASIFormDataRequest *weiboLoginRequest;
	ASIFormDataRequest *editRequest;
	ASIFormDataRequest *logoutRequest;
}

@end

@implementation NanbeigeAccountManager

#pragma mark - Initialization Methods
- (id)init
{
	self = [super init];
	if (self) {
		renrenEngine = [Renren sharedRenren];
		
		weiBoEngine = [[WBEngine alloc] initWithAppKey:kWBSDKDemoAppKey appSecret:kWBSDKDemoAppSecret];
		[weiBoEngine setDelegate:self];
		[weiBoEngine setRedirectURI:@"https://api.weibo.com/oauth2/default.html"];
		[weiBoEngine setIsUserExclusive:NO];
	}
	return self;
}
- (id)initWithViewController:(UIViewController *)viewController
{
	self = [self init];
	if (self) {
		[weiBoEngine setRootViewController:viewController];
	}
	return self;
}

#pragma mark - Email Login, Logout, Edit

- (void)emailLoginWithEmail:(NSString *)email
			  Password:(NSString *)password
{
	[[NSUserDefaults standardUserDefaults] setObject:email forKey:kNANBEIGEEMAILKEY];
	[[NSUserDefaults standardUserDefaults] setObject:password forKey:kNANBEIGEPASSWORDKEY];
	
	emailLoginRequest = [ASIFormDataRequest requestWithURL:urlAPIUserLoginEmail];
	
	[emailLoginRequest addPostValue:email forKey:kAPIEMAIL];
	[emailLoginRequest addPostValue:password forKey:kAPIPASSWORD];
	[emailLoginRequest setDelegate:self];
	[emailLoginRequest setTimeOutSeconds:DEFAULT_TIMEOUT];
	[emailLoginRequest startAsynchronous];
	
}
- (void)emailLoginWithWeiboToken:(NSString *)weibo_token
{
	[[NSUserDefaults standardUserDefaults] setObject:weibo_token forKey:kWEIBOTOKENKEY];
	
	weiboLoginRequest = [ASIFormDataRequest requestWithURL:urlAPIUserLoginWeibo];
	
	[weiboLoginRequest addPostValue:weibo_token forKey:kAPITOKEN];
	[weiboLoginRequest setDelegate:self];
	[weiboLoginRequest setTimeOutSeconds:DEFAULT_TIMEOUT];
	[weiboLoginRequest startAsynchronous];
}
- (void)emailEditWithPassword:(NSString *)password
				Nickname:(NSString *)nickname
			UniversityID:(NSNumber *)university_id
			  WeiboToken:(NSString *)weibo_token
{
	editRequest = [[ASIFormDataRequest alloc] initWithURL:urlAPIUserEdit];
	if (password) {
		[editRequest addPostValue:password forKey:kAPIPASSWORD];
		[[NSUserDefaults standardUserDefaults] setObject:password forKey:kNANBEIGEPASSWORDKEY];
	}
	if (nickname) {
		[editRequest addPostValue:nickname forKey:kAPINICKNAME];
		[[NSUserDefaults standardUserDefaults] setObject:nickname forKey:kNANBEIGENICKNAMEKEY];
	}
	if (university_id) {
		[editRequest addPostValue:university_id forKey:kAPIUNIVERSITY_ID];
		[[NSUserDefaults standardUserDefaults] setObject:university_id forKey:kUNIVERSITYIDKEY];
	}
	if (weibo_token) {
		[editRequest addPostValue:weibo_token forKey:kAPIWEIBO_TOKEN];
		[[NSUserDefaults standardUserDefaults] setObject:weibo_token forKey:kWEIBOTOKENKEY];
	}
	[editRequest setDelegate:self];
	[editRequest setTimeOutSeconds:DEFAULT_TIMEOUT];
	[editRequest startAsynchronous];
}
- (void)emailLogout
{
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:kNANBEIGEEMAILKEY];
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:kNANBEIGEIDKEY];
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:kNANBEIGENICKNAMEKEY];
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:kNANBEIGEPASSWORDKEY];
	
	logoutRequest = [[ASIFormDataRequest alloc] initWithURL:urlAPIUserLogout];
	[logoutRequest setDelegate:self];
	[logoutRequest setTimeOutSeconds:DEFAULT_TIMEOUT];
	[logoutRequest startAsynchronous];
}

#pragma mark - Renren Login, Logout

- (void)renrenLogin
{
	[renrenEngine delUserSessionInfo];
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"access_Token"];
	NSArray *permissions = [[NSArray alloc] initWithObjects:@"status_update", nil];
	[renrenEngine authorizationInNavigationWithPermisson:permissions
											 andDelegate:self];
}
- (void)renrenLogout
{
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:kRENRENIDKEY];
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:kRENRENNAMEKEY];
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:kRENRENTOKENKEY];
	[renrenEngine logout:self];
}
- (BOOL)isRenrenSessionValid
{
	return [renrenEngine isSessionValid];
}

#pragma mark - Weibo Login, Logout

- (void)weiboLogin
{
	[weiBoEngine logIn];
}
- (void)weiboLogout
{
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:kWEIBOIDKEY];
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:kWEIBONAMEKEY];
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:kWEIBOTOKENKEY];
	[weiBoEngine logOut];
}
- (BOOL)isWeiboSessionValid
{
	return ([weiBoEngine isLoggedIn] && ![weiBoEngine isAuthorizeExpired]);
}

#pragma mark - ASIHTTPRequestDelegate

- (void)requestFinished:(ASIHTTPRequest *)request
{
	NSData *responseData = [request responseData];
	id res = [NSJSONSerialization JSONObjectWithData:responseData
											 options:NSJSONWritingPrettyPrinted
											   error:nil];
	NSLog(@"%@", res);
	
	if ([request isEqual:emailLoginRequest] || [request isEqual:weiboLoginRequest]) {
		NSString *nickname = nil;
		NSNumber *nanbeigeid = [res objectForKey:kAPIID];
		NSNumber *university_id = nil;
		NSString *university_name = nil;
		
		if ([[res objectForKey:kAPINICKNAME] isKindOfClass:[NSString class]]) {
			nickname = [res objectForKey:kAPINICKNAME];
		}
		if ([res objectForKey:kAPIUNIVERSITY] && [[res objectForKey:kAPIUNIVERSITY] isKindOfClass:[NSDictionary class]]) {
			university_id = [[res objectForKey:kAPIUNIVERSITY] objectForKey:kAPIID];
			university_name = [[res objectForKey:kAPIUNIVERSITY] objectForKey:kAPINAME];
		}
		
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		[defaults setValue:nickname forKey:kNANBEIGENICKNAMEKEY];
		[defaults setValue:nanbeigeid forKey:kNANBEIGEIDKEY];
		[defaults setValue:university_id forKey:kUNIVERSITYIDKEY];
		[defaults setValue:university_name forKey:kUNIVERSITYNAMEKEY];
		
		if ([self.delegate respondsToSelector:@selector(didEmailLoginWithID:Nickname:UniversityID:UniversityName:)]) {
			[self.delegate didEmailLoginWithID:nanbeigeid Nickname:nickname UniversityID:university_id UniversityName:university_name];
		}
	}
	if ([request isEqual:editRequest]) {
		if ([self.delegate respondsToSelector:@selector(didEmailEdit)]) {
			[self.delegate didEmailEdit];
		}
	}
	if ([request isEqual:logoutRequest]) {
		if ([self.delegate respondsToSelector:@selector(didEmailLogout)]) {
			[self.delegate didEmailLogout];
		}
	}
	
}
- (void)requestFailed:(ASIHTTPRequest *)request
{
	NSData *responseData = [request responseData];
	if (responseData) {
		id res = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONWritingPrettyPrinted error:nil];
		NSLog(@"%@", res);
		if ([res objectForKey:kAPIERROR]) {
			if ([self.delegate respondsToSelector:@selector(requestError:)]) {
				[self.delegate requestError:[res objectForKey:kAPIERROR]];
			}
			return ;
		}
	}
	
	NSError *error = [request error];
	NSLog(@"%@", error);
	if ([self.delegate respondsToSelector:@selector(requestError:)]) {
		[self.delegate requestError:[error description]];
	}
}


#pragma mark - WBEngineDelegate

// Log in successfully.
- (void)engineDidLogIn:(WBEngine *)engine
{
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:kACCOUNTEDIT];
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:kACCOUNTEDITWEIBO_TOKEN];
	[[NSUserDefaults standardUserDefaults] setObject:[weiBoEngine accessToken] forKey:kWEIBOTOKENKEY];
	[[NSUserDefaults standardUserDefaults] setObject:[weiBoEngine userID] forKey:kWEIBOIDKEY];
	
	NSDictionary *params = @{ @"uid" : [weiBoEngine userID] };
	[weiBoEngine loadRequestWithMethodName:@"users/show.json" httpMethod:@"GET" params:params postDataType:kWBRequestPostDataTypeNone httpHeaderFields:nil];
}

// Failed to log in.
// Possible reasons are:
// 1) Either username or password is wrong;
// 2) Your app has not been authorized by Sina yet.
- (void)engine:(WBEngine *)engine didFailToLogInWithError:(NSError *)error
{
	if ([self.delegate respondsToSelector:@selector(requestError:)]) {
		[self.delegate requestError:[error description]];
	}
}

// Log out successfully.
- (void)engineDidLogOut:(WBEngine *)engine
{
	if ([self.delegate respondsToSelector:@selector(didWeiboLogout)]) {
		[self.delegate didWeiboLogout];
	}
}

// When you use the WBEngine's request methods,
// you may receive the following four callbacks.
- (void)engineNotAuthorized:(WBEngine *)engine
{
	if ([self.delegate respondsToSelector:@selector(requestError:)]) {
		[self.delegate requestError:@"微博未授权"];
	}
}
- (void)engineAuthorizeExpired:(WBEngine *)engine
{
	if ([self.delegate respondsToSelector:@selector(requestError:)]) {
		[self.delegate requestError:@"微博授权已过期"];
	}
}
- (void)engine:(WBEngine *)engine requestDidFailWithError:(NSError *)error
{
	if ([self.delegate respondsToSelector:@selector(requestError:)]) {
		[self.delegate requestError:[error description]];
	}
}
- (void)engine:(WBEngine *)engine requestDidSucceedWithResult:(id)result
{
	NSLog(@"%@", result);
	if ([result isKindOfClass:[NSDictionary class]] && [result objectForKey:kAPISCREEN_NAME]) {
		[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:kAPISCREEN_NAME] forKey:kWEIBONAMEKEY];
		if ([self.delegate respondsToSelector:@selector(didWeiboLoginWithUserID:UserName:WeiboToken:)]) {
			[self.delegate didWeiboLoginWithUserID:[weiBoEngine userID] UserName:[result objectForKey:kAPISCREEN_NAME] WeiboToken:[weiBoEngine accessToken]];
		}
	}
}

#pragma mark - RenrenDelegate
/**
 * 接口请求成功，第三方开发者实现这个方法
 * @param renren 传回代理服务器接口请求的Renren类型对象。
 * @param response 传回接口请求的响应。
 */
- (void)renren:(Renren *)renren requestDidReturnResponse:(ROResponse*)response
{
	if ([response.rootObject isKindOfClass:[NSArray class]]) {
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		[defaults setValue:[renrenEngine accessToken] forKey:kRENRENTOKENKEY];
		NSArray *usersInfo = (NSArray *)(response.rootObject);
		for (ROUserResponseItem *item in usersInfo) {
			[defaults setValue:item.name forKey:kRENRENNAMEKEY];
			[defaults setValue:item.userId forKey:kRENRENIDKEY];
		}
		if ([self.delegate respondsToSelector:@selector(didRenrenLoginWithUserID:UserName:RenrenToken:)]) {
			[self.delegate didRenrenLoginWithUserID:[defaults objectForKey:kRENRENIDKEY] UserName:[defaults objectForKey:kRENRENNAMEKEY] RenrenToken:[defaults objectForKey:kRENRENTOKENKEY]];
		}
	} else if ([response.rootObject isKindOfClass:[NSDictionary class]]) {
		NSDictionary* params = (NSDictionary *)response.rootObject;
		if (params!=nil) {
			NSString *msg=nil;
			NSMutableString *result = [[NSMutableString alloc] initWithString:@""];
			for (id key in params) {
				msg = [NSString stringWithFormat:@"key: %@ value: %@    ", key, [params objectForKey:key]];
				[result appendString:msg];
			}
			NSLog(@"%@", result);
		}
	}
}

/**
 * 接口请求失败，第三方开发者实现这个方法
 * @param renren 传回代理服务器接口请求的Renren类型对象。
 * @param response 传回接口请求的错误对象。
 */
- (void)renren:(Renren *)renren requestFailWithError:(ROError*)error
{
	if ([self.delegate respondsToSelector:@selector(requestError:)]) {
		[self.delegate requestError:[error localizedDescription]];
	}
}

/**
 * 授权登录成功时被调用，第三方开发者实现这个方法
 * @param renren 传回代理授权登录接口请求的Renren类型对象。
 */
- (void)renrenDidLogin:(Renren *)renren
{
	ROUserInfoRequestParam *requestParam = [[ROUserInfoRequestParam alloc] init];
	requestParam.fields = [NSString stringWithFormat:@"uid,name"];
	[renrenEngine getUsersInfo:requestParam andDelegate:self];
	
}

/**
 * 用户登出成功后被调用 第三方开发者实现这个方法
 * @param renren 传回代理登出接口请求的Renren类型对象。
 */
- (void)renrenDidLogout:(Renren *)renren
{
	if ([self.delegate respondsToSelector:@selector(didRenrenLogout)]) {
		[self.delegate didRenrenLogout];
	}
}
/**
 * 授权登录失败时被调用，第三方开发者实现这个方法
 * @param renren 传回代理授权登录接口请求的Renren类型对象。
 */
- (void)renren:(Renren *)renren loginFailWithError:(ROError*)error
{
	if ([self.delegate respondsToSelector:@selector(requestError:)]) {
		[self.delegate requestError:[error localizedDescription]];
	}
}

@end
