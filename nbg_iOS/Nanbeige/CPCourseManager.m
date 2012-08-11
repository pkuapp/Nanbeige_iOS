//
//  CPCourseManager.m
//  CP
//
//  Created by ZongZiWang on 12-8-9.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import "CPCourseManager.h"
#import "ASIFormDataRequest.h"
#import "ASIHTTPRequest.h"

@implementation CPCourseManager

- (void)requestCourses
{
	ASIHTTPRequest *coursesRequest = [[ASIHTTPRequest alloc] initWithURL:urlAPICourse];
	[coursesRequest setDidFinishSelector:@selector(courseRequestFinished:)];
	
	[coursesRequest setDelegate:self];
	[coursesRequest setTimeOutSeconds:DEFAULT_TIMEOUT];
	[coursesRequest startAsynchronous];
}
- (void)courseRequestFinished:(ASIHTTPRequest *)request
{
	id res = [self resultFromRequest:request];
	if ([res isKindOfClass:[NSDictionary class]] && ([res objectForKey:kAPIERROR] || [res objectForKey:kAPIERROR_CODE])) return ;
	
	if ([self.delegate respondsToSelector:@selector(didCoursesReceived:)]) {
		[self.delegate didCoursesReceived:res];
	}
}

- (void)requestCourseGrabber
{
	ASIFormDataRequest *grabberRequest = [[ASIFormDataRequest alloc] initWithURL:urlAPICourseGrabber];
	[grabberRequest setDidFinishSelector:@selector(grabberRequestFinished:)];
	
	[grabberRequest setRequestMethod:@"POST"];
	[grabberRequest setDelegate:self];
	[grabberRequest setTimeOutSeconds:DEFAULT_TIMEOUT];
	[grabberRequest startAsynchronous];
}
- (void)grabberRequestFinished:(ASIHTTPRequest *)request
{
	id res = [self resultFromRequest:request];
	if ([res isKindOfClass:[NSDictionary class]] && ([res objectForKey:kAPIERROR] || [res objectForKey:kAPIERROR_CODE])) return ;
	
	if ([self.delegate respondsToSelector:@selector(didCourseGrabberReceived:)]) {
		[self.delegate didCourseGrabberReceived:res];
	}
}


- (void)requestCourseGrabberCaptcha
{
	ASIHTTPRequest *captchaRequest = [[ASIHTTPRequest alloc] initWithURL:urlAPICourseGrabberCaptcha];
	[captchaRequest setDidFinishSelector:@selector(captchaRequestFinished:)];
	
	[captchaRequest setDelegate:self];
	[captchaRequest setTimeOutSeconds:DEFAULT_TIMEOUT];
	[captchaRequest startAsynchronous];
}
- (void)captchaRequestFinished:(ASIHTTPRequest *)request
{
	id res = [self resultFromRequest:request];
	if ([res isKindOfClass:[NSDictionary class]] && ([res objectForKey:kAPIERROR] || [res objectForKey:kAPIERROR_CODE])) return ;
	
	NSData *captchaData = [request responseData];
	
	if ([self.delegate respondsToSelector:@selector(didCourseGrabberCaptchaReceived:)]) {
		[self.delegate didCourseGrabberCaptchaReceived:captchaData];
	}
}

- (void)startCourseGrabberWithUsername:(NSString *)username
							  Password:(NSString *)password
							   Captcha:(NSString *)captcha
{
	ASIFormDataRequest *startGrabberRequest = [[ASIFormDataRequest alloc] initWithURL:urlAPICourseGrabberStart];
	[startGrabberRequest setDidFinishSelector:@selector(startGrabberRequestFinished:)];
	
	[startGrabberRequest addPostValue:username forKey:kAPIUSERNAME];
	[startGrabberRequest addPostValue:password forKey:kAPIPASSWORD];
	if (captcha) [startGrabberRequest addPostValue:captcha forKey:kAPICAPTCHA];
	[startGrabberRequest setDelegate:self];
	[startGrabberRequest setTimeOutSeconds:DEFAULT_TIMEOUT];
	[startGrabberRequest startAsynchronous];
}
- (void)startGrabberRequestFinished:(ASIHTTPRequest *)request
{
	id res = [self resultFromRequest:request];
	if ([res isKindOfClass:[NSDictionary class]] && ([res objectForKey:kAPIERROR] || [res objectForKey:kAPIERROR_CODE])) return ;
	
	if ([self.delegate respondsToSelector:@selector(didCourseGrabberStarted)]) {
		[self.delegate didCourseGrabberStarted];
	}
}


- (void)requestCommentsWithStart:(NSNumber *)start
{
	
}
- (void)requestCommentsWithCourse_ID:(NSNumber *)course_id
							   Start:(NSNumber *)start
{
	
}
- (void)addCommentWithCourse_ID:(NSNumber *)course_id
						Content:(NSString *)content
{
	
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
