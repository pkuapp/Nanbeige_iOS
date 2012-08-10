//
//  NanbeigeAssignmentManager.m
//  Nanbeige
//
//  Created by ZongZiWang on 12-8-9.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import "NanbeigeAssignmentManager.h"
#import "ASIFormDataRequest.h"
#import "ASIHTTPRequest.h"

@implementation NanbeigeAssignmentManager

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
