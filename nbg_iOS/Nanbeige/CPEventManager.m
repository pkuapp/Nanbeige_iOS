//
//  CPEventManager.m
//  CP
//
//  Created by ZongZiWang on 12-8-9.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import "CPEventManager.h"
#import "ASIFormDataRequest.h"
#import "ASIHTTPRequest.h"

@implementation CPEventManager

- (void)requestEventsWithKeyword:(NSString *)keyword
					 Category_ID:(NSNumber *)category_id
					   AfterTime:(NSDate *)after
					  BeforeTime:(NSDate *)before
						   Start:(NSNumber *)start
{
	ASIFormDataRequest *eventsRequest = [[ASIFormDataRequest alloc] initWithURL:urlAPIEvent];
	[eventsRequest setDidFinishSelector:@selector(eventsRequestFinished:)];
	
	if (keyword) [eventsRequest addPostValue:keyword forKey:kAPIKEYWORD];
	if (category_id) [eventsRequest addPostValue:category_id forKey:kAPICATEGORY_ID];
	if (after) [eventsRequest addPostValue:after forKey:kAPIAFTER];
	if (before) [eventsRequest addPostValue:before forKey:kAPIBEFORE];
	if (start) [eventsRequest addPostValue:start forKey:kAPISTART];
	
	[eventsRequest setRequestMethod:@"POST"];
	[eventsRequest setDelegate:self];
	[eventsRequest setTimeOutSeconds:DEFAULT_TIMEOUT];
	[eventsRequest startAsynchronous];
}
- (void)eventsRequestFinished:(ASIHTTPRequest *)request
{
	id res = [self resultFromRequest:request];
	if ([res isKindOfClass:[NSDictionary class]] && ([res objectForKey:kAPIERROR] || [res objectForKey:kAPIERROR_CODE])) return ;
	
	if ([self.delegate respondsToSelector:@selector(didEventsReceived:)]) {
		[self.delegate didEventsReceived:res];
	}
}
- (void)requestEventCategories
{
	ASIHTTPRequest *categoriesRequest = [[ASIHTTPRequest alloc] initWithURL:urlAPIEventCategory];
	[categoriesRequest setDidFinishSelector:@selector(categoriesRequestFinished:)];
	
	[categoriesRequest setDelegate:self];
	[categoriesRequest setTimeOutSeconds:DEFAULT_TIMEOUT];
	[categoriesRequest startAsynchronous];
}
- (void)categoriesRequestFinished:(ASIHTTPRequest *)request
{
	id res = [self resultFromRequest:request];
	if ([res isKindOfClass:[NSDictionary class]] && ([res objectForKey:kAPIERROR] || [res objectForKey:kAPIERROR_CODE])) return ;
	
	if ([self.delegate respondsToSelector:@selector(didEventCategoriesReceived:)]) {
		[self.delegate didEventCategoriesReceived:res];
	}
}

- (void)requestEventWithEvent_ID:(NSNumber *)event_id;
{
	ASIHTTPRequest *eventRequest = [[ASIHTTPRequest alloc] initWithURL:urlAPIEventWithID(event_id)];
	[eventRequest setDidFinishSelector:@selector(eventRequestFinished:)];
	
	eventRequest.tag = [event_id integerValue];
	[eventRequest setDelegate:self];
	[eventRequest setTimeOutSeconds:DEFAULT_TIMEOUT];
	[eventRequest startAsynchronous];
}
- (void)eventRequestFinished:(ASIHTTPRequest *)request
{
	id res = [self resultFromRequest:request];
	if ([res isKindOfClass:[NSDictionary class]] && ([res objectForKey:kAPIERROR] || [res objectForKey:kAPIERROR_CODE])) return ;
	
	if ([self.delegate respondsToSelector:@selector(didEventReceived:WithEvent_ID:)]) {
		[self.delegate didEventReceived:res WithEvent_ID:[NSNumber numberWithInteger:request.tag]];
	}
}

- (void)followEventWithEvent_ID:(NSNumber *)event_id
{
	ASIFormDataRequest *followRequest = [[ASIFormDataRequest alloc] initWithURL:urlAPIEventFollowWithID(event_id)];
	[followRequest setDidFinishSelector:@selector(followRequestFinished:)];
	
	followRequest.tag = [event_id integerValue];
	[followRequest setDelegate:self];
	[followRequest setTimeOutSeconds:DEFAULT_TIMEOUT];
	[followRequest startAsynchronous];
}
- (void)followRequestFinished:(ASIHTTPRequest *)request
{
	id res = [self resultFromRequest:request];
	if ([res isKindOfClass:[NSDictionary class]] && ([res objectForKey:kAPIERROR] || [res objectForKey:kAPIERROR_CODE])) return ;
	
	if ([self.delegate respondsToSelector:@selector(didEventFollowedWithEvent_ID:)]) {
		[self.delegate didEventFollowedWithEvent_ID:[NSNumber numberWithInteger:request.tag]];
	}
}
- (void)requestEventFollowings
{
	ASIHTTPRequest *followingsRequest = [[ASIHTTPRequest alloc] initWithURL:urlAPIEventFollowing];
	[followingsRequest setDidFinishSelector:@selector(followingsRequestFinished:)];
	
	[followingsRequest setDelegate:self];
	[followingsRequest setTimeOutSeconds:DEFAULT_TIMEOUT];
	[followingsRequest startAsynchronous];
}
- (void)followingsRequestFinished:(ASIHTTPRequest *)request
{
	id res = [self resultFromRequest:request];
	if ([res isKindOfClass:[NSDictionary class]] && ([res objectForKey:kAPIERROR] || [res objectForKey:kAPIERROR_CODE])) return ;
	
	if ([self.delegate respondsToSelector:@selector(didEventFollowingsReceived:)]) {
		[self.delegate didEventFollowingsReceived:res];
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

@end
