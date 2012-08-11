//
//  CPAssignmentManager.m
//  CP
//
//  Created by ZongZiWang on 12-8-9.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import "CPAssignmentManager.h"
#import "ASIFormDataRequest.h"
#import "ASIHTTPRequest.h"

@implementation CPAssignmentManager

- (void)requestAssignments
{
	ASIHTTPRequest *assignmentsRequest = [[ASIHTTPRequest alloc] initWithURL:urlAPICourseAssignment];
	[assignmentsRequest setDidFinishSelector:@selector(assignmentsRequestFinished:)];
	
	[assignmentsRequest setDelegate:self];
	[assignmentsRequest setTimeOutSeconds:DEFAULT_TIMEOUT];
	[assignmentsRequest startAsynchronous];
}
- (void)assignmentsRequestFinished:(ASIHTTPRequest *)request
{
	id res = [self resultFromRequest:request];
	if ([res isKindOfClass:[NSDictionary class]] && ([res objectForKey:kAPIERROR] || [res objectForKey:kAPIERROR_CODE])) return ;
	
	if ([self.delegate respondsToSelector:@selector(didAssignmentsReceived:)]) {
		[self.delegate didAssignmentsReceived:res];
	}
}

- (void)finishAssignmentWithID:(NSNumber *)assignment_id
					  Finished:(NSNumber *)finished
{
	ASIFormDataRequest *finishRequest = [[ASIFormDataRequest alloc] initWithURL:urlAPICourseAssignmentFinishWithID(assignment_id)];
	[finishRequest setDidFinishSelector:@selector(finishRequestFinished:)];
	if (finished && ![finished boolValue]) [finishRequest setDidFinishSelector:@selector(unfinishRequestFinished:)];
	
	finishRequest.tag = [assignment_id integerValue];
	if (finished) [finishRequest addPostValue:finished forKey:kAPIFINISHED];
	[finishRequest setDelegate:self];
	[finishRequest setTimeOutSeconds:DEFAULT_TIMEOUT];
	[finishRequest startAsynchronous];
}
- (void)finishRequestFinished:(ASIHTTPRequest *)request
{
	id res = [self resultFromRequest:request];
	if ([res isKindOfClass:[NSDictionary class]] && ([res objectForKey:kAPIERROR] || [res objectForKey:kAPIERROR_CODE])) return ;
	
	if ([self.delegate respondsToSelector:@selector(didAssignmentFinishedWithID:)]) {
		[self.delegate didAssignmentFinishedWithID:[NSNumber numberWithInteger:request.tag]];
	}
}
- (void)unfinishRequestFinished:(ASIHTTPRequest *)request
{
	id res = [self resultFromRequest:request];
	if ([res isKindOfClass:[NSDictionary class]] && ([res objectForKey:kAPIERROR] || [res objectForKey:kAPIERROR_CODE])) return ;
	
	if ([self.delegate respondsToSelector:@selector(didAssignmentUnfinishedWithID:)]) {
		[self.delegate didAssignmentUnfinishedWithID:[NSNumber numberWithInteger:request.tag]];
	}
}

- (void)deleteAssignmentWithID:(NSNumber *)assignment_id
{
	ASIFormDataRequest *deleteRequest = [[ASIFormDataRequest alloc] initWithURL:urlAPICourseAssignmentDeleteWithID(assignment_id)];
	[deleteRequest setDidFinishSelector:@selector(deleteRequestFinished:)];
	
	deleteRequest.tag = [assignment_id integerValue];
	[deleteRequest setDelegate:self];
	[deleteRequest setTimeOutSeconds:DEFAULT_TIMEOUT];
	[deleteRequest startAsynchronous];
}
- (void)deleteRequestFinished:(ASIHTTPRequest *)request
{
	id res = [self resultFromRequest:request];
	if ([res isKindOfClass:[NSDictionary class]] && ([res objectForKey:kAPIERROR] || [res objectForKey:kAPIERROR_CODE])) return ;
	
	if ([self.delegate respondsToSelector:@selector(didAssignmentDeletedWithID:)]) {
		[self.delegate didAssignmentDeletedWithID:[NSNumber numberWithInteger:request.tag]];
	}
}

- (void)modifyAssignmentWithID:(NSNumber *)assignment_id
					 Course_ID:(NSNumber *)course_id
					   DueTime:(NSDate *)due
					   Content:(NSString *)content
					  Finished:(NSNumber *)finished
{
	ASIFormDataRequest *modifyRequest = [[ASIFormDataRequest alloc] initWithURL:urlAPICourseAssignmentModifyWithID(assignment_id)];
	[modifyRequest setDidFinishSelector:@selector(modifyRequestFinished:)];
	
	modifyRequest.tag = [assignment_id integerValue];
	if (course_id) [modifyRequest addPostValue:course_id forKey:kAPICOURSE_ID];
	if (due) [modifyRequest addPostValue:due forKey:kAPIDUE];
	if (content) [modifyRequest addPostValue:content forKey:kAPICONTENT];
	if (finished) [modifyRequest addPostValue:finished forKey:kAPIFINISHED];
	[modifyRequest setDelegate:self];
	[modifyRequest setTimeOutSeconds:DEFAULT_TIMEOUT];
	[modifyRequest startAsynchronous];
}
- (void)modifyRequestFinished:(ASIHTTPRequest *)request
{
	id res = [self resultFromRequest:request];
	if ([res isKindOfClass:[NSDictionary class]] && ([res objectForKey:kAPIERROR] || [res objectForKey:kAPIERROR_CODE])) return ;
	
	if ([self.delegate respondsToSelector:@selector(didAssignmentModifiedWithID:)]) {
		[self.delegate didAssignmentModifiedWithID:[NSNumber numberWithInteger:request.tag]];
	}
}

- (void)addAssignmentWithCourse_ID:(NSNumber *)course_id
						   DueTime:(NSDate *)due
						   Content:(NSString *)content
{
	ASIFormDataRequest *addRequest = [[ASIFormDataRequest alloc] initWithURL:urlAPICourseAssignmentAdd];
	[addRequest setDidFinishSelector:@selector(addRequestFinished:)];
	
	if (course_id) [addRequest addPostValue:course_id forKey:kAPICOURSE_ID];
	if (due) [addRequest addPostValue:due forKey:kAPIDUE];
	if (content) [addRequest addPostValue:content forKey:kAPICONTENT];
	[addRequest setDelegate:self];
	[addRequest setTimeOutSeconds:DEFAULT_TIMEOUT];
	[addRequest startAsynchronous];
}
- (void)addRequestFinished:(ASIHTTPRequest *)request
{
	id res = [self resultFromRequest:request];
	if ([res isKindOfClass:[NSDictionary class]] && ([res objectForKey:kAPIERROR] || [res objectForKey:kAPIERROR_CODE])) return ;
	
	NSNumber *assignment_id = [res objectForKey:kAPIID];
	if ([self.delegate respondsToSelector:@selector(didAssignmentAdded:)]) {
		[self.delegate didAssignmentAdded:assignment_id];
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
