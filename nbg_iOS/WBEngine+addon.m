//
//  WBEngine+Customized.m
//  nbg_iOS
//
//  Created by wuhaotian on 12-8-11.
//  Copyright (c) 2012年 wuhaotian. All rights reserved.
//

#import "WBEngine+addon.h"


static NSString *kWBSDKDemoAppKey = @"1362082242";
static NSString *kWBSDKDemoAppSecret = @"26a3e4f3e784bd183aeac3d58440f19f";
static NSString *kWBRequestSuccess = @"WBRequestStrat";
static NSString *kWBRequestFail = @"WBRequestFail";
static WBEngine *sharedWBEngineOject = nil;

@implementation WBEngine (Customized)



+ (WBEngine *)sharedWBEngine {
    if (!sharedWBEngineOject) {
        sharedWBEngineOject = [[WBEngine alloc] initWithAppKey:kWBSDKDemoAppKey appSecret:kWBSDKDemoAppSecret];
    }
    return sharedWBEngineOject;
}

- (void)loadRequestWithMethodName:(NSString *)methodName
                       httpMethod:(NSString *)httpMethod
                           params:(NSDictionary *)params
                     postDataType:(WBRequestPostDataType)postDataType
                 httpHeaderFields:(NSDictionary *)httpHeaderFields
                          success:(void (^)(WBRequest *request, id result))success_block
                             fail:(void (^)(WBRequest *request, NSError *error))fail_block
{
    if (!self.handler) {
        self.handler = [[CPBlockHandler alloc] init];
    }
    [self.handler registerEventHandler:kWBRequestSuccess discard:YES handler:success_block];
    [self.handler registerEventHandler:kWBRequestFail discard:YES handler:fail_block];
    
    [self loadRequestWithMethodName:methodName httpMethod:httpMethod params:params postDataType:postDataType httpHeaderFields:httpHeaderFields];
}

#warning all Weibo requests shared one block handler now, event may be mis-dispatched, ensure only one block-callback-type request make at one time

- (void)request:(WBRequest *)_req didFinishLoadingWithResult:(id)result
{

    [self.handler enumerateEventHandlers:kWBRequestSuccess block:^(id _handler) {
        void (^block1)(WBRequest *, id) = _handler;
        block1(_req, result);
    }];
    
    if ([delegate respondsToSelector:@selector(engine:requestDidSucceedWithResult:)])
    {
        [delegate engine:self requestDidSucceedWithResult:result];
    }
}

- (void)request:(WBRequest *)_req didFailWithError:(NSError *)error
{
    [self.handler enumerateEventHandlers:kWBRequestSuccess block:^(id _handler) {
        void (^block2)(WBRequest *, NSError*) = _handler;
        block2(_req, error);
    }];
    
    if ([delegate respondsToSelector:@selector(engine:requestDidFailWithError:)])
    {
        [delegate engine:self requestDidFailWithError:error];
    }
}
@end
