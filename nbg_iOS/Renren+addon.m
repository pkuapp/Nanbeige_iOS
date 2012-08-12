//
//  Renren+addon.m
//  nbg_iOS
//
//  Created by ZongZiWang on 12-8-12.
//  Copyright (c) 2012年 wuhaotian. All rights reserved.
//

#import "Renren+addon.h"

static NSString *kRenrenRequestSuccess = @"RenrenRequestSuccess";
static NSString *kRenrenRequestFail = @"RenrenRequestFail";

@implementation Renren (addon)

- (void)requestWithParam:(RORequestParam *)param
			 andDelegate:(id <RenrenDelegate>)delegate
				 success:(void (^)(RORequest *request, id result))success_block
					fail:(void (^)(RORequest *request, ROError *error))fail_block
{
	if (!self.handler) {
        self.handler = [[CPBlockHandler alloc] init];
    }
    [self.handler registerEventHandler:kRenrenRequestSuccess discard:NO handler:success_block];
    [self.handler registerEventHandler:kRenrenRequestFail discard:NO handler:fail_block];
	
	self.renrenDelegate = delegate;
	return [self requestWithParam:param andDelegate:self];
}

#pragma mark - RORequestDelegate -

/**
 * Handle the auth.ExpireSession api call failure
 */
- (void)request:(RORequest *)request didFailWithError:(NSError*)error{
    NSLog(@"Failed to expire the session");
}

- (void)request:(RORequest *)request didFailWithROError:(ROError *)error{
	
	[self.handler enumerateEventHandlers:kRenrenRequestFail block:^(id _handler) {
        void (^block2)(RORequest *, ROError*) = _handler;
        block2(request, error);
    }];
    
	//password flow授权错误的处理
	if([request.requestParamObject isKindOfClass:[ROPasswordFlowRequestParam class]])
	{
		if ([self.renrenDelegate respondsToSelector:@selector(renren:loginFailWithError:)]) {
			[self.renrenDelegate renren:self loginFailWithError:error];
		}else{
			// 默认错误处理。
			NSString *title = [NSString stringWithFormat:@"Error code:%d", [error code]];
			NSString *description = [NSString stringWithFormat:@"%@", [error localizedDescription]];
			UIAlertView *alertView =[[UIAlertView alloc] initWithTitle:title message:description delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
			[alertView show];
		}
		return;
	}
	
	if (self.renrenDelegate && [self.renrenDelegate respondsToSelector:@selector(renren:requestFailWithError:)]) {
        [self.renrenDelegate renren:self requestFailWithError:error];
    }else{
        // 默认错误处理。
        NSString *title = [NSString stringWithFormat:@"Error code:%d", [error code]];
        NSString *description = [NSString stringWithFormat:@"%@", [error localizedDescription]];
        UIAlertView *alertView =[[UIAlertView alloc] initWithTitle:title message:description delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [alertView show];
    }
    
    return;
}

- (void)request:(RORequest *)request didLoad:(id)result{
	
	
    [self.handler enumerateEventHandlers:kRenrenRequestSuccess block:^(id _handler) {
        void (^block1)(RORequest *, id) = _handler;
        block1(request, result);
    }];
	
	//password flow授权请求的处理
	if([request.requestParamObject isKindOfClass:[ROPasswordFlowRequestParam class]])
	{
		NSString *token = [request.responseObject.rootObject objectForKey:@"access_token"];
		NSString *date = [request.responseObject.rootObject objectForKey:@"expires_in"];
		
		self.accessToken = [request.responseObject.rootObject objectForKey:@"access_token"];;
		self.expirationDate = [ROUtility getDateFromString:date];
		self.secret=[self getSecretKeyByToken:token];
		self.sessionKey=[self getSessionKeyByToken:token];
		//用户信息保存到本地
		[self saveUserSessionInfo];
        [self getLoggedInUserId];
		if ([self.renrenDelegate respondsToSelector:@selector(renrenDidLogin:)]) {
			[self.renrenDelegate renrenDidLogin:self];
		}
		return;
	}
    if ([request.requestParamObject.method isEqualToString:@"users.getLoggedInUser"]) {
        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
        NSNumber *uid = [(NSDictionary*)result objectForKey:@"uid"];
        if (uid) {
            [defaults setObject:[uid stringValue] forKey:@"session_UserId"];
            [defaults synchronize];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"kNotificationDidGetLoggedInUserId" object:nil];
        }
        
        return;
    }
	
    if(self.renrenDelegate && [self.renrenDelegate respondsToSelector:@selector(renren:requestDidReturnResponse:)]){
        [self.renrenDelegate renren:self requestDidReturnResponse:request.responseObject];
    }else{
        // 默认请求成功时的处理。
        
    }
    
    return;
}

@end
