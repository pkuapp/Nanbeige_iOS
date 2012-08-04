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
	NSUserDefaults *defaults;
	
	WBEngine *weiBoEngine;
	Renren *renrenEngine;
	
	ASIFormDataRequest *emailLoginRequest;
	ASIFormDataRequest *weiboLoginRequest;
	ASIFormDataRequest *renrenLoginRequest;
	ASIFormDataRequest *editRequest;
	ASIFormDataRequest *logoutRequest;
	ASIFormDataRequest *signupRequest;
	ASIHTTPRequest *universitiesRequest;
	ASIHTTPRequest *universityRequest;
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
		
		defaults = [NSUserDefaults standardUserDefaults];
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
	[defaults setObject:email forKey:kNANBEIGEEMAILKEY];
	[defaults setObject:password forKey:kNANBEIGEPASSWORDKEY];
	
	emailLoginRequest = [ASIFormDataRequest requestWithURL:urlAPIUserLoginEmail];
	
	[emailLoginRequest addPostValue:email forKey:kAPIEMAIL];
	[emailLoginRequest addPostValue:password forKey:kAPIPASSWORD];
	[emailLoginRequest setDelegate:self];
	[emailLoginRequest setTimeOutSeconds:DEFAULT_TIMEOUT];
	[emailLoginRequest startAsynchronous];
	
}
- (void)emailLoginWithWeiboToken:(NSString *)weibo_token
{
	[defaults setObject:weibo_token forKey:kWEIBOTOKENKEY];
	
	weiboLoginRequest = [ASIFormDataRequest requestWithURL:urlAPIUserLoginWeibo];
	
	[weiboLoginRequest addPostValue:weibo_token forKey:kAPITOKEN];
	[weiboLoginRequest setDelegate:self];
	[weiboLoginRequest setTimeOutSeconds:DEFAULT_TIMEOUT];
	[weiboLoginRequest startAsynchronous];
}
- (void)emailLoginWithRenrenToken:(NSString *)renren_token
{
	[defaults setObject:renren_token forKey:kRENRENTOKENKEY];
	
	renrenLoginRequest = [ASIFormDataRequest requestWithURL:urlAPIUserLoginRenren];
	
	[renrenLoginRequest addPostValue:renren_token forKey:kAPITOKEN];
	[renrenLoginRequest setDelegate:self];
	[renrenLoginRequest setTimeOutSeconds:DEFAULT_TIMEOUT];
	[renrenLoginRequest startAsynchronous];
}

- (void)emailEditWithPassword:(NSString *)password
					 Nickname:(NSString *)nickname
					 CampusID:(NSNumber *)campus_id
				   WeiboToken:(NSString *)weibo_token
{
	editRequest = [[ASIFormDataRequest alloc] initWithURL:urlAPIUserEdit];
	
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:kACCOUNTEDIT];
	if (!campus_id && [[[NSUserDefaults standardUserDefaults] objectForKey:kACCOUNTEDITCAMPUS_ID] boolValue]) {
		campus_id = [[NSUserDefaults standardUserDefaults] objectForKey:kCAMPUSIDKEY];
	}
	if (!weibo_token && [[[NSUserDefaults standardUserDefaults] objectForKey:kACCOUNTEDITWEIBO_TOKEN] boolValue]) {
		weibo_token = [[NSUserDefaults standardUserDefaults] objectForKey:kWEIBOTOKENKEY];
	}
	if (!nickname && [[[NSUserDefaults standardUserDefaults] objectForKey:kACCOUNTEDITNICKNAME] boolValue]) {
		nickname = [[NSUserDefaults standardUserDefaults] objectForKey:kNANBEIGENICKNAMEKEY];
	}
	if (!password && [[[NSUserDefaults standardUserDefaults] objectForKey:kACCOUNTEDITPASSWORD] boolValue]) {
		password = [[NSUserDefaults standardUserDefaults] objectForKey:kNANBEIGEPASSWORDKEY];
	}
	
	if (campus_id) {
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:kACCOUNTEDITCAMPUS_ID];
		[editRequest addPostValue:campus_id forKey:kAPICAMPUS_ID];
		[defaults setObject:campus_id forKey:kCAMPUSIDKEY];
	}
	if (weibo_token) {
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:kACCOUNTEDITWEIBO_TOKEN];
		[editRequest addPostValue:weibo_token forKey:kAPIWEIBO_TOKEN];
		[defaults setObject:weibo_token forKey:kWEIBOTOKENKEY];
	}
	if (nickname) {
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:kACCOUNTEDITNICKNAME];
		[editRequest addPostValue:nickname forKey:kAPINICKNAME];
		[defaults setObject:nickname forKey:kNANBEIGENICKNAMEKEY];
	}
	if (password) {
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:kACCOUNTEDITPASSWORD];
		[editRequest addPostValue:password forKey:kAPIPASSWORD];
		[defaults setObject:password forKey:kNANBEIGEPASSWORDKEY];
	}
	
	[editRequest setDelegate:self];
	[editRequest setTimeOutSeconds:DEFAULT_TIMEOUT];
	[editRequest startAsynchronous];
}
- (void)emailLogout
{
	[defaults removeObjectForKey:kNANBEIGEEMAILKEY];
	[defaults removeObjectForKey:kNANBEIGEIDKEY];
	[defaults removeObjectForKey:kNANBEIGENICKNAMEKEY];
	[defaults removeObjectForKey:kNANBEIGEPASSWORDKEY];
	
	logoutRequest = [[ASIFormDataRequest alloc] initWithURL:urlAPIUserLogout];
	[logoutRequest setDelegate:self];
	[logoutRequest setTimeOutSeconds:DEFAULT_TIMEOUT];
	[logoutRequest startAsynchronous];
}
- (void)emailSignupWithEmail:(NSString *)email
					Password:(NSString *)password
					Nickname:(NSString *)nickname
{
	[defaults setObject:email forKey:kNANBEIGEEMAILKEY];
	[defaults setObject:password forKey:kNANBEIGEPASSWORDKEY];
	[defaults setObject:nickname forKey:kNANBEIGENICKNAMEKEY];

	signupRequest = [ASIFormDataRequest requestWithURL:urlAPIUserRegEmail];
	
	[signupRequest addPostValue:email forKey:kAPIEMAIL];
	[signupRequest addPostValue:nickname forKey:kAPINICKNAME];
	[signupRequest addPostValue:password forKey:kAPIPASSWORD];
	[signupRequest setDelegate:self];
	[signupRequest setTimeOutSeconds:DEFAULT_TIMEOUT];
	[signupRequest startAsynchronous];
}

#pragma mark - Renren Login, Logout

- (void)renrenLogin
{
	[renrenEngine delUserSessionInfo];
	[defaults removeObjectForKey:@"access_Token"];
	NSArray *permissions = [[NSArray alloc] initWithObjects:@"status_update", nil];
	[renrenEngine authorizationInNavigationWithPermisson:permissions
											 andDelegate:self];
}
- (void)renrenLogout
{
	[defaults removeObjectForKey:kRENRENIDKEY];
	[defaults removeObjectForKey:kRENRENNAMEKEY];
	[defaults removeObjectForKey:kRENRENTOKENKEY];
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
	[defaults removeObjectForKey:kWEIBOIDKEY];
	[defaults removeObjectForKey:kWEIBONAMEKEY];
	[defaults removeObjectForKey:kWEIBOTOKENKEY];
	[weiBoEngine logOut];
}
- (BOOL)isWeiboSessionValid
{
	return ([weiBoEngine isLoggedIn] && ![weiBoEngine isAuthorizeExpired]);
}

#pragma mark - University API

- (void)requestUniversities
{
	universitiesRequest = [[ASIHTTPRequest alloc] initWithURL:urlAPIUniversity];
	
	[universitiesRequest setDelegate:self];
	[universitiesRequest setTimeOutSeconds:DEFAULT_TIMEOUT];
	[universitiesRequest startAsynchronous];
}
- (void) requestUniversitie:(NSNumber *)university_id
{
	universityRequest = [[ASIHTTPRequest alloc] initWithURL:[urlAPIUniversity URLByAppendingPathComponent:[NSString stringWithFormat:@"%@/", university_id]]];
	
	[universityRequest setDelegate:self];
	[universityRequest setTimeOutSeconds:DEFAULT_TIMEOUT];
	[universityRequest startAsynchronous];
}

#pragma mark - ASIHTTPRequestDelegate

- (void)requestFinished:(ASIHTTPRequest *)request
{
	NSData *responseData = [request responseData];
	id res = [NSJSONSerialization JSONObjectWithData:responseData
											 options:NSJSONWritingPrettyPrinted
											   error:nil];
	NSLog(@"%@", res);
	
	if ([res isKindOfClass:[NSDictionary class]] && [res objectForKey:kAPIERROR]) {
		if ([self.delegate respondsToSelector:@selector(requestError:)]) {
			[self.delegate requestError:[res objectForKey:kAPIERROR]];
		}
		return ;
	}
	
	if ([request isEqual:emailLoginRequest] || [request isEqual:weiboLoginRequest] || [request isEqual:renrenLoginRequest]) {
		NSNumber *nanbeigeid = [res objectForKey:kAPIID];
		NSString *nickname = nil;
		NSNumber *university_id = nil;
		NSString *university_name = nil;
		NSNumber *campus_id = nil;
		NSString *campus_name = nil;
		
		if ([[res objectForKey:kAPINICKNAME] isKindOfClass:[NSString class]]) {
			nickname = [res objectForKey:kAPINICKNAME];
		}
		if ([res objectForKey:kAPIUNIVERSITY] && [[res objectForKey:kAPIUNIVERSITY] isKindOfClass:[NSDictionary class]]) {
			university_id = [[res objectForKey:kAPIUNIVERSITY] objectForKey:kAPIID];
			university_name = [[res objectForKey:kAPIUNIVERSITY] objectForKey:kAPINAME];
		}
		if ([res objectForKey:kAPICAMPUS] && [[res objectForKey:kAPICAMPUS] isKindOfClass:[NSDictionary class]]) {
			campus_id = [[res objectForKey:kAPICAMPUS] objectForKey:kAPIID];
			campus_name = [[res objectForKey:kAPICAMPUS] objectForKey:kAPINAME];
		}
		[defaults setValue:nickname forKey:kNANBEIGENICKNAMEKEY];
		[defaults setValue:nanbeigeid forKey:kNANBEIGEIDKEY];
		[defaults setValue:university_id forKey:kUNIVERSITYIDKEY];
		[defaults setValue:university_name forKey:kUNIVERSITYNAMEKEY];
		[defaults setValue:campus_id forKey:kCAMPUSIDKEY];
		[defaults setValue:campus_name forKey:kCAMPUSNAMEKEY];
		[defaults removeObjectForKey:kCAMPUSIDKEY];
		[defaults removeObjectForKey:kCAMPUSNAMEKEY];
		
		if ([self.delegate respondsToSelector:@selector(didEmailLoginWithID:Nickname:UniversityID:UniversityName:CampusID:CampusName:)]) {
			[self.delegate didEmailLoginWithID:nanbeigeid Nickname:nickname UniversityID:university_id UniversityName:university_name CampusID:campus_id CampusName:campus_name];
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
	if ([request isEqual:signupRequest]) {
		NSNumber *nanbeigeid = [res objectForKey:kAPIID];
		[defaults setObject:nanbeigeid forKey:kNANBEIGEIDKEY];
		if ([self.delegate respondsToSelector:@selector(didEmailSignupWithID:)]) {
			[self.delegate didEmailSignupWithID:nanbeigeid];
		}
	}
	if ([request isEqual:universitiesRequest]) {
		if ([self.delegate respondsToSelector:@selector(didUniversitiesReceived:)]) {
			[self.delegate didUniversitiesReceived:res];
		}
	}
	if ([request isEqual:universityRequest]) {
		if ([self.delegate respondsToSelector:@selector(didUniversityReceived:)]) {
			[self.delegate didUniversityReceived:res];
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
	[defaults setObject:[NSNumber numberWithBool:YES] forKey:kACCOUNTEDIT];
	[defaults setObject:[NSNumber numberWithBool:YES] forKey:kACCOUNTEDITWEIBO_TOKEN];
	[defaults setObject:[weiBoEngine accessToken] forKey:kWEIBOTOKENKEY];
	[defaults setObject:[weiBoEngine userID] forKey:kWEIBOIDKEY];
	
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
		[defaults setObject:[result objectForKey:kAPISCREEN_NAME] forKey:kWEIBONAMEKEY];
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
