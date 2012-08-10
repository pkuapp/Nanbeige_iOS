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
	ASIFormDataRequest *emailSignupRequest;
	ASIFormDataRequest *weiboSingupRequest;
	ASIFormDataRequest *renrenSignupRequest;
	ASIHTTPRequest *universitiesRequest;
	ASIHTTPRequest *universityRequest;
	ASIHTTPRequest *buildingsRequest;
	ASIHTTPRequest *roomsRequest;
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
	[emailLoginRequest setDidFinishSelector:@selector(emailLoginRequestFinished:)];
	
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
	[weiboLoginRequest setDidFinishSelector:@selector(emailLoginRequestFinished:)];
	
	[weiboLoginRequest addPostValue:weibo_token forKey:kAPITOKEN];
	[weiboLoginRequest setDelegate:self];
	[weiboLoginRequest setTimeOutSeconds:DEFAULT_TIMEOUT];
	[weiboLoginRequest startAsynchronous];
}
- (void)emailLoginWithRenrenToken:(NSString *)renren_token
{
	[defaults setObject:renren_token forKey:kRENRENTOKENKEY];
	
	renrenLoginRequest = [ASIFormDataRequest requestWithURL:urlAPIUserLoginRenren];
	[renrenLoginRequest setDidFinishSelector:@selector(emailLoginRequestFinished:)];
	
	[renrenLoginRequest addPostValue:renren_token forKey:kAPITOKEN];
	[renrenLoginRequest setDelegate:self];
	[renrenLoginRequest setTimeOutSeconds:DEFAULT_TIMEOUT];
	[renrenLoginRequest startAsynchronous];
}
- (void)emailLoginRequestFinished:(ASIHTTPRequest *)request
{
	id res = [self resultFromRequest:request];
	if ([res isKindOfClass:[NSDictionary class]] && ([res objectForKey:kAPIERROR] || [res objectForKey:kAPIERROR_CODE])) return ;
	
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
	
	if (nickname && ![defaults objectForKey:kNANBEIGENICKNAMEKEY])
		[defaults setValue:nickname forKey:kNANBEIGENICKNAMEKEY];
	if (nanbeigeid && ![defaults objectForKey:kNANBEIGEIDKEY])
		[defaults setValue:nanbeigeid forKey:kNANBEIGEIDKEY];
	if (university_id && ![defaults objectForKey:kUNIVERSITYIDKEY])
		[defaults setValue:university_id forKey:kUNIVERSITYIDKEY];
	if (university_name && ![defaults objectForKey:kUNIVERSITYNAMEKEY])
		[defaults setValue:university_name forKey:kUNIVERSITYNAMEKEY];
	if (campus_id && ![defaults objectForKey:kCAMPUSIDKEY])
		[defaults setValue:campus_id forKey:kCAMPUSIDKEY];
	if (campus_name && ![defaults objectForKey:kCAMPUSNAMEKEY])
		[defaults setValue:campus_name forKey:kCAMPUSNAMEKEY];
	
	if ([self.delegate respondsToSelector:@selector(didEmailLoginWithID:Nickname:UniversityID:UniversityName:CampusID:CampusName:)]) {
		[self.delegate didEmailLoginWithID:nanbeigeid Nickname:nickname UniversityID:university_id UniversityName:university_name CampusID:campus_id CampusName:campus_name];
	}
}

- (void)emailEditWithPassword:(NSString *)password
					 Nickname:(NSString *)nickname
					 CampusID:(NSNumber *)campus_id
				   WeiboToken:(NSString *)weibo_token
{
	editRequest = [[ASIFormDataRequest alloc] initWithURL:urlAPIUserEdit];
	[editRequest setDidFinishSelector:@selector(editRequestFinished:)];
	
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
- (void)editRequestFinished:(ASIHTTPRequest *)request
{
	id res = [self resultFromRequest:request];
	if ([res isKindOfClass:[NSDictionary class]] && ([res objectForKey:kAPIERROR] || [res objectForKey:kAPIERROR_CODE])) return ;
	
	if ([self.delegate respondsToSelector:@selector(didEmailEdit)]) {
		[self.delegate didEmailEdit];
	}
}

- (void)emailLogout
{
	[defaults removeObjectForKey:kNANBEIGEEMAILKEY];
	[defaults removeObjectForKey:kNANBEIGEIDKEY];
	[defaults removeObjectForKey:kNANBEIGENICKNAMEKEY];
	[defaults removeObjectForKey:kNANBEIGEPASSWORDKEY];
	
	logoutRequest = [[ASIFormDataRequest alloc] initWithURL:urlAPIUserLogout];
	[logoutRequest setDidFinishSelector:@selector(logoutRequestFinished:)];
	
	[logoutRequest setDelegate:self];
	[logoutRequest setTimeOutSeconds:DEFAULT_TIMEOUT];
	[logoutRequest startAsynchronous];
}
- (void)logoutRequestFinished:(ASIHTTPRequest *)request
{
	id res = [self resultFromRequest:request];
	if ([res isKindOfClass:[NSDictionary class]] && ([res objectForKey:kAPIERROR] || [res objectForKey:kAPIERROR_CODE])) return ;
	
	if ([self.delegate respondsToSelector:@selector(didEmailLogout)]) {
		[self.delegate didEmailLogout];
	}
}

- (void)emailSignupWithEmail:(NSString *)email
					Password:(NSString *)password
					Nickname:(NSString *)nickname
{
	[defaults setObject:email forKey:kNANBEIGEEMAILKEY];
	[defaults setObject:password forKey:kNANBEIGEPASSWORDKEY];
	[defaults setObject:nickname forKey:kNANBEIGENICKNAMEKEY];

	emailSignupRequest = [ASIFormDataRequest requestWithURL:urlAPIUserRegEmail];
	[emailSignupRequest setDidFinishSelector:@selector(signupRequestFinished:)];
	
	[emailSignupRequest addPostValue:email forKey:kAPIEMAIL];
	[emailSignupRequest addPostValue:nickname forKey:kAPINICKNAME];
	[emailSignupRequest addPostValue:password forKey:kAPIPASSWORD];
	[emailSignupRequest setDelegate:self];
	[emailSignupRequest setTimeOutSeconds:DEFAULT_TIMEOUT];
	[emailSignupRequest startAsynchronous];
}
- (void)signupRequestFinished:(ASIHTTPRequest *)request
{
	id res = [self resultFromRequest:request];
	if ([res isKindOfClass:[NSDictionary class]] && ([res objectForKey:kAPIERROR] || [res objectForKey:kAPIERROR_CODE])) return ;
	
	NSNumber *nanbeigeid = [res objectForKey:kAPIID];
	[defaults setObject:nanbeigeid forKey:kNANBEIGEIDKEY];
	if ([self.delegate respondsToSelector:@selector(didEmailSignupWithID:)]) {
		[self.delegate didEmailSignupWithID:nanbeigeid];
	}
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

- (void)renrenSignupWithToken:(NSString *)token
					Nickname:(NSString *)nickname
{
	[defaults setObject:token forKey:kRENRENTOKENKEY];
	[defaults setObject:nickname forKey:kNANBEIGENICKNAMEKEY];
	
	renrenSignupRequest = [ASIFormDataRequest requestWithURL:urlAPIUserRegRenren];
	[renrenSignupRequest setDidFinishSelector:@selector(renrenSignupRequestFinished:)];
	
	[renrenSignupRequest addPostValue:token forKey:kAPITOKEN];
	[renrenSignupRequest addPostValue:nickname forKey:kAPINICKNAME];
	[renrenSignupRequest setDelegate:self];
	[renrenSignupRequest setTimeOutSeconds:DEFAULT_TIMEOUT];
	[renrenSignupRequest startAsynchronous];
}
- (void)renrenSignupRequestFinished:(ASIHTTPRequest *)request
{
	id res = [self resultFromRequest:request];
	if ([res isKindOfClass:[NSDictionary class]] && ([res objectForKey:kAPIERROR] || [res objectForKey:kAPIERROR_CODE])) return ;
	
	NSNumber *nanbeigeid = [res objectForKey:kAPIID];
	[defaults setObject:nanbeigeid forKey:kNANBEIGEIDKEY];
	if ([self.delegate respondsToSelector:@selector(didRenrenSignupWithID:)]) {
		[self.delegate didRenrenSignupWithID:nanbeigeid];
	}
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

- (void)weiboSignupWithToken:(NSString *)token
					Nickname:(NSString *)nickname
{
	[defaults setObject:token forKey:kWEIBOTOKENKEY];
	[defaults setObject:nickname forKey:kNANBEIGENICKNAMEKEY];
	
	weiboSingupRequest = [ASIFormDataRequest requestWithURL:urlAPIUserRegWeibo];
	[weiboSingupRequest setDidFinishSelector:@selector(weiboSignupRequestFinished:)];
	
	[weiboSingupRequest addPostValue:token forKey:kAPITOKEN];
	[weiboSingupRequest addPostValue:nickname forKey:kAPINICKNAME];
	[weiboSingupRequest setDelegate:self];
	[weiboSingupRequest setTimeOutSeconds:DEFAULT_TIMEOUT];
	[weiboSingupRequest startAsynchronous];
}
- (void)weiboSignupRequestFinished:(ASIHTTPRequest *)request
{
	id res = [self resultFromRequest:request];
	if ([res isKindOfClass:[NSDictionary class]] && ([res objectForKey:kAPIERROR] || [res objectForKey:kAPIERROR_CODE])) return ;
	
	NSNumber *nanbeigeid = [res objectForKey:kAPIID];
	[defaults setObject:nanbeigeid forKey:kNANBEIGEIDKEY];
	if ([self.delegate respondsToSelector:@selector(didWeiboSignupWithID:)]) {
		[self.delegate didWeiboSignupWithID:nanbeigeid];
	}
}

- (void)weiboRequestHomeTimeline
{
	if (![self isWeiboSessionValid]) {
		if ([self.delegate respondsToSelector:@selector(didRequest:FailWithError:)]) {
			[self.delegate didRequest:nil FailWithError:@"微博未授权或已过期！"];
		}
	} else {
		NSDictionary *params = nil;
		[weiBoEngine loadRequestWithMethodName:@"statuses/home_timeline.json" httpMethod:@"GET" params:params postDataType:kWBRequestPostDataTypeNone httpHeaderFields:nil];
	}
}

#pragma mark - University API

- (void)requestUniversities
{
	universitiesRequest = [[ASIHTTPRequest alloc] initWithURL:urlAPIUniversity];
	[universitiesRequest setDidFinishSelector:@selector(universitiesRequestFinished:)];
	
	[universitiesRequest setDelegate:self];
	[universitiesRequest setTimeOutSeconds:DEFAULT_TIMEOUT];
	[universitiesRequest startAsynchronous];
}
- (void)universitiesRequestFinished:(ASIHTTPRequest *)request
{
	id res = [self resultFromRequest:request];
	if ([res isKindOfClass:[NSDictionary class]] && ([res objectForKey:kAPIERROR] || [res objectForKey:kAPIERROR_CODE])) return ;
	
	if ([self.delegate respondsToSelector:@selector(didUniversitiesReceived:)]) {
		[self.delegate didUniversitiesReceived:res];
	}
}

- (void)requestUniversityWithID:(NSNumber *)university_id
{
	universityRequest = [[ASIHTTPRequest alloc] initWithURL:[urlAPIUniversity URLByAppendingPathComponent:[NSString stringWithFormat:@"%@/", university_id]]];
	[universityRequest setDidFinishSelector:@selector(universityRequestFinished:)];
	
	universityRequest.tag = [university_id integerValue];
	[universityRequest setDelegate:self];
	[universityRequest setTimeOutSeconds:DEFAULT_TIMEOUT];
	[universityRequest startAsynchronous];
}
- (void)universityRequestFinished:(ASIHTTPRequest *)request
{
	id res = [self resultFromRequest:request];
	if ([res isKindOfClass:[NSDictionary class]] && ([res objectForKey:kAPIERROR] || [res objectForKey:kAPIERROR_CODE])) return ;
	
	[defaults setObject:res forKey:kTEMPUNIVERSITY];
	if ([self.delegate respondsToSelector:@selector(didUniversityReceived:WithID:)]) {
		[self.delegate didUniversityReceived:res WithID:[NSNumber numberWithInteger:request.tag]];
	}
}

- (void)requestBuildingsWithCampusID:(NSNumber *)campus_id
{
	buildingsRequest = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:formatAPIStudyBuildingWithCampus_ID, campus_id]]];
	[buildingsRequest setDidFinishSelector:@selector(buildingsRequestFinished:)];
	
	buildingsRequest.tag = [campus_id integerValue];
	[buildingsRequest setDelegate:self];
	[buildingsRequest setTimeOutSeconds:DEFAULT_TIMEOUT];
	[buildingsRequest startAsynchronous];
}
- (void)buildingsRequestFinished:(ASIHTTPRequest *)request
{
	id res = [self resultFromRequest:request];
	if ([res isKindOfClass:[NSDictionary class]] && ([res objectForKey:kAPIERROR] || [res objectForKey:kAPIERROR_CODE])) return ;
	
	if ([self.delegate respondsToSelector:@selector(didBuildingsReceived:WithCampusID:)]) {
		[self.delegate didBuildingsReceived:res WithCampusID:[NSNumber numberWithInteger:request.tag]];
	}
}

- (void)requestRoomsWithBuildingID:(NSNumber *)building_id
							  Date:(NSDate *)date
{
	if (date) {
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		formatter.dateFormat = @"yyyy-MM-dd";
		roomsRequest = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:formatAPIStudyBuildingRoomWithBuilding_IDAndDate, building_id, [formatter stringFromDate:date]]]];
	} else {
		roomsRequest = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:formatAPIStudyBuildingRoomWithBuilding_ID, building_id]]];
	}
	[roomsRequest setDidFinishSelector:@selector(roomsRequestFinished:)];
		
	roomsRequest.tag = [building_id integerValue];
	[roomsRequest setDelegate:self];
	[roomsRequest setTimeOutSeconds:DEFAULT_TIMEOUT];
	[roomsRequest startAsynchronous];
}
- (void)roomsRequestFinished:(ASIHTTPRequest *)request
{
	id res = [self resultFromRequest:request];
	if ([res isKindOfClass:[NSDictionary class]] && ([res objectForKey:kAPIERROR] || [res objectForKey:kAPIERROR_CODE])) return ;
	
	if ([self.delegate respondsToSelector:@selector(didRoomsReceived:WithBuildingID:)]) {
		[self.delegate didRoomsReceived:res WithBuildingID:[NSNumber numberWithInteger:request.tag]];
	}
}

#pragma mark - Private

- (id)resultFromRequest:(ASIHTTPRequest *)request
{
	NSData *responseData = [request responseData];
	id res = [NSJSONSerialization JSONObjectWithData:responseData
											 options:NSJSONWritingPrettyPrinted
											   error:nil];
	NSLog(@"%@", res);
	
	if ([res isKindOfClass:[NSDictionary class]] && ([res objectForKey:kAPIERROR] || [res objectForKey:kAPIERROR_CODE])) {
		if ([res objectForKey:kAPIERROR]) {
			if ([self.delegate respondsToSelector:@selector(didRequest:FailWithError:)]) {
				[self.delegate didRequest:request FailWithError:[res objectForKey:kAPIERROR]];
			}
		} else if ([res objectForKey:kAPIERROR_CODE]){
			if ([self.delegate respondsToSelector:@selector(didRequest:FailWithErrorCode:)]) {
				[self.delegate didRequest:request FailWithErrorCode:[res objectForKey:kAPIERROR_CODE]];
			}
		}
	}
	return res;
}

#pragma mark - ASIHTTPRequestDelegate

- (void)requestFinished:(ASIHTTPRequest *)request
{
	id res = [self resultFromRequest:request];
	if ([res isKindOfClass:[NSDictionary class]] && ([res objectForKey:kAPIERROR] || [res objectForKey:kAPIERROR_CODE])) return ;
	
	if ([self.delegate respondsToSelector:@selector(didRequest:FailWithError:)]) {
		[self.delegate didRequest:request FailWithError:[[request url] absoluteString]];
	}
}
- (void)requestFailed:(ASIHTTPRequest *)request
{
	NSData *responseData = [request responseData];
	if (responseData) {
		id res = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONWritingPrettyPrinted error:nil];
		NSLog(@"%@", res);
		if ([res objectForKey:kAPIERROR]) {
			if ([self.delegate respondsToSelector:@selector(didRequest:FailWithError:)]) {
				[self.delegate didRequest:request FailWithError:[res objectForKey:kAPIERROR]];
			}
			return ;
		} else if ([res objectForKey:kAPIERROR_CODE]){
			if ([self.delegate respondsToSelector:@selector(didRequest:FailWithErrorCode:)]) {
				[self.delegate didRequest:request FailWithErrorCode:[res objectForKey:kAPIERROR_CODE]];
			}
		}
	}
	
	NSError *error = [request error];
	NSLog(@"%@", error);
	if ([self.delegate respondsToSelector:@selector(didRequest:FailWithError:)]) {
		[self.delegate didRequest:request FailWithError:[error description]];
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
	if ([self.delegate respondsToSelector:@selector(didRequest:FailWithError:)]) {
		[self.delegate didRequest:nil FailWithError:[error description]];
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
	if ([self.delegate respondsToSelector:@selector(didRequest:FailWithError:)]) {
		[self.delegate didRequest:nil FailWithError:@"微博未授权"];
	}
}
- (void)engineAuthorizeExpired:(WBEngine *)engine
{
	if ([self.delegate respondsToSelector:@selector(didRequest:FailWithError:)]) {
		[self.delegate didRequest:nil FailWithError:@"微博授权已过期"];
	}
}
- (void)engine:(WBEngine *)engine requestDidFailWithError:(NSError *)error
{
	if ([self.delegate respondsToSelector:@selector(didRequest:FailWithError:)]) {
		[self.delegate didRequest:nil FailWithError:[error description]];
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
	if ([result isKindOfClass:[NSDictionary class]] && [result objectForKey:kAPISTATUSES]) {
		if ([self.delegate respondsToSelector:@selector(didWeiboHomeTimelineReceived:)]) {
			[self.delegate didWeiboHomeTimelineReceived:[result objectForKey:kAPISTATUSES]];
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
	if ([self.delegate respondsToSelector:@selector(didRequest:FailWithError:)]) {
		[self.delegate didRequest:nil FailWithError:[error localizedDescription]];
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
	if ([self.delegate respondsToSelector:@selector(didRequest:FailWithError:)]) {
		[self.delegate didRequest:nil FailWithError:[error localizedDescription]];
	}
}

@end
