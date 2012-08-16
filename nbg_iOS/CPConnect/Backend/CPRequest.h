//
//  CPRequest.h
//  nbg_iOS
//
//  Created by wuhaotian on 12-8-8.
//  Copyright (c) 2012年 wuhaotian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CPBlockHandler.h"

typedef enum
{
    kCPRequestStateReady,
    kCPRequestStateLoading,
    kCPRequestStateComplete,
    kCPRequestStateError
}CPRequestState;

#define kCPCompletionBlockHandlerKey @"completion"
#define kCPErrorBlockHandlerKey @"error"
#define kCPLoadBlockHandlerKey @"load"
#define kCPRawBlockHandlerKey @"raw"
#define kCPResponseBlockHandlerKey @"response"
#define kCPStateChangeBlockHandlerKey @"state"

@interface CPRequest : CPBlockHandler
@property (nonatomic, copy) NSString* url;
@property (nonatomic, copy) NSString* httpMethod;
@property (weak, nonatomic) NSMutableDictionary* params;
@property (nonatomic, readonly) CPRequestState state;
@property (nonatomic, readonly) BOOL isSessionExpired;
@property (nonatomic, strong) NSError* error;
@property (nonatomic) NSInteger status_code;
@property(nonatomic) NSURLConnection* connection;
@property(nonatomic) NSMutableData* responseText;

+ (CPRequest *)getRequestWithParameters:(NSDictionary *) params
						  requestMethod:(NSString *) httpMethod
							 requestURL:(NSString *) url;

- (void)addCompletionHandler:(void(^)(CPRequest*request,id collection))completionHandler;
- (void)addErrorHandler:(void(^)(CPRequest*request, NSError *error))errorHandler;
- (void)addLoadHandler:(void(^)(CPRequest*request))loadHandler;
- (void)addRawHandler:(void(^)(CPRequest*request,NSData*raw))rawHandler;
- (void)addResponseHandler:(void(^)(CPRequest*request,NSURLResponse*response))responseHandler;
- (void)addDebugOutputHandlers;

- (BOOL) loading;
- (void) connect;
@end
