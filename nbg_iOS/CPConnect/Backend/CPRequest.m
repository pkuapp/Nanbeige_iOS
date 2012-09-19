//
//  CPRequest.m
//  nbg_iOS
//
//  Created by wuhaotian on 12-8-8.
//  Copyright (c) 2012年 wuhaotian. All rights reserved.
//

#import "CPRequest.h"
#import "Coffeepot.h"

static NSString* kUserAgent = @"CoffepotOniOS";
static NSString* kAPIVersion = @"2.0";
static const NSTimeInterval kTimeoutInterval = 180.0;
static NSString* kStringBoundary = @"3i2ndDfv2rTHiSisAbouNdArYfORhtTPEefj3q2f";
static NSString* pAPIProtocol = @"https";
static NSString* pAPIDomain = @"api.pkuapp.com";
static NSString* pAPIPort = @"443";
static NSString* pIPGateProtocol = @"https";
static NSString* pIPGateDomain = @"its.pku.edu.cn";
static NSString* pIPGatePort = @"5428";
static NSString* pIPGatePage = @"ipgatewayofpku";

@interface CPRequest () {
}
@property (nonatomic,readwrite) CPRequestState state;
@property (nonatomic,readwrite) BOOL isSessionExpired;
@end

@implementation CPRequest

- (BOOL)loading {
	return !!_connection;
}

/**
 * Formulate the NSError
 */
- (id)formError:(NSInteger)code userInfo:(NSDictionary *) errorData {
	return [NSError errorWithDomain:@"CoffeepotErrDomain" code:code userInfo:errorData];
	
}

/**
 * parse the response data
 */
- (id)parseJsonResponse:(NSData *)data error:(NSError **)error {
	
	NSString* responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

	
	NSError *inplaceError = nil;
	
	id result = [NSJSONSerialization JSONObjectWithData:[responseString dataUsingEncoding:NSUTF8StringEncoding]
												options:NSJSONReadingAllowFragments
												  error:&inplaceError];

	if( inplaceError ) {
		NSLog(@"%s: %d: Unable to decode JSON: %@", __FILE__, __LINE__, responseString);
		result = nil;
	}
	
    *error = inplaceError;
    
	if (result == nil) {
		return responseString;
	}
	
	if ([result isKindOfClass:[NSDictionary class]]) {
		if ([result objectForKey:@"error_code"] || (error != nil && self.status_code >= 400)) {
			*error = [self formError:self.status_code userInfo:result];
			return nil;
		}
	}
	
	return result;
	
}

- (void)_reportError:(NSError*)error {

	[self enumerateEventHandlers:kCPErrorBlockHandlerKey block:^(id _handler) {
		void (^handler)(CPRequest*, NSError *) = _handler;
		handler(self, error);
	}];
}

- (void)failWithError:(NSError *)error {
	
	[self _reportError:error];
}

/*
 * private helper function: handle the response data
 */
- (void)handleResponseData:(NSData *)data {
	if( [self eventHandlerCount:kCPRawBlockHandlerKey] > 0 ) {
        if( self.error ) {
			[self _reportError:self.error];
		}
		[self enumerateEventHandlers:kCPRawBlockHandlerKey block:^(id _handler) {
			void (^handler)(CPRequest*,NSData *) = _handler;
			handler(self, data);
		}];
	}
	else {
		NSError* error = nil;
		id result = [self parseJsonResponse:data error:&error];
        
        if (error) {
            self.error = error;
        }
		
		if( self.error ) {
			//TODO
			if (self.error.code == 403 && [[self.error.userInfo objectForKey:@"error_code"] isEqualToString:@"NotLoggedIn"]) {
				[[[UIAlertView alloc] initWithTitle:@"未登录或登录过期" message:@"确认以重新登录" delegate:nil cancelButtonTitle:sCONFIRM otherButtonTitles:nil, nil] show];
				UIStoryboard *sb = [UIStoryboard storyboardWithName:@"CPSigninFlow" bundle:[NSBundle mainBundle]];
				[UIApplication sharedApplication].delegate.window.rootViewController = [sb instantiateInitialViewController];
			} else {
				[self _reportError:self.error];
			}
		}
		else {
			[self enumerateEventHandlers:kCPCompletionBlockHandlerKey block:^(id _handler) {
				void (^handler)(CPRequest*,id) = _handler;
				handler(self, result);
			}];
		}
	}
}

// class public

+ (CPRequest *)getRequestWithParameters:(NSDictionary *) params
						  requestMethod:(NSString *) httpMethod
							 requestURL:(NSString *) url {
	
	CPRequest* request = [[CPRequest alloc] init];
	request.url = [NSString stringWithFormat:@"%@://%@:%@/%@",pAPIProtocol,pAPIDomain,pAPIPort,url];
	request.httpMethod = httpMethod;
	request.params = [NSMutableDictionary dictionaryWithDictionary: params];
	request.connection = nil;
	request.responseText = nil;
	
	return request;
}

+ (CPRequest *)getIPGateRequestWithGate_ID:(NSString *)gate_id
							 Gate_Password:(NSString *)gate_password
									 Range:(NSString *)range
								 Operation:(NSString *)operation
{
	
	CPRequest* request = [[CPRequest alloc] init];
	request.url = [NSString stringWithFormat:@"%@://%@:%@/%@?uid=%@&password=%@&timeout=2&range=%@&operation=%@",pIPGateProtocol,pIPGateDomain,pIPGatePort,pIPGatePage,gate_id,gate_password,range,operation];
	request.httpMethod = @"GET";
	request.connection = nil;
	request.responseText = nil;
	
	return request;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
// private

+ (NSString *)serializeURL:(NSString *)baseUrl
					params:(NSDictionary *)params {
	return [self serializeURL:baseUrl params:params requestMethod:@"GET"];
}

/**
 * Generate get URL
 */
+ (NSString*)serializeURL:(NSString *)baseUrl
				   params:(NSDictionary *)params
			requestMethod:(NSString *)httpMethod {
	
	NSURL* parsedURL = [NSURL URLWithString:baseUrl];
	NSString* queryPrefix = parsedURL.query ? @"&" : @"?";
	
	NSMutableArray* pairs = [NSMutableArray array];
	for (NSString* key in [params keyEnumerator]) {
		if (([[params objectForKey:key] isKindOfClass:[UIImage class]])
			||([[params objectForKey:key] isKindOfClass:[NSData class]])) {
			if ([httpMethod isEqualToString:@"GET"]) {
				NSLog(@"can not use GET to upload a file");
			}
			continue;
		}
		
		NSString* escaped_value = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(
																										NULL, /* allocator */
																										(__bridge CFStringRef)[params objectForKey:key],
																										NULL, /* charactersToLeaveUnescaped */
																										(CFStringRef)@"!*'();:@&=+$,/?%#[]",
																										kCFStringEncodingUTF8);
		
		[pairs addObject:[NSString stringWithFormat:@"%@=%@", key, escaped_value]];
	}
	NSString* query = [pairs componentsJoinedByString:@"&"];
	
	return [NSString stringWithFormat:@"%@%@%@", baseUrl, queryPrefix, query];
}


- (void)addCompletionHandler:(void(^)(CPRequest* req, id collection))completionHandler {
	[self registerEventHandler:kCPCompletionBlockHandlerKey handler:completionHandler];
}
- (void)addErrorHandler:(void(^)(CPRequest*, NSError *))errorHandler {
	[self registerEventHandler:kCPErrorBlockHandlerKey handler:errorHandler];
}
- (void)addLoadHandler:(void(^)(CPRequest*))loadHandler {
	[self registerEventHandler:kCPLoadBlockHandlerKey handler:loadHandler];
}
- (void)addRawHandler:(void(^)(CPRequest*,NSData*))rawHandler {
	[self registerEventHandler:kCPRawBlockHandlerKey handler:rawHandler];
}
- (void)addResponseHandler:(void(^)(CPRequest*,NSURLResponse*))responseHandler{
	[self registerEventHandler:kCPResponseBlockHandlerKey handler:responseHandler];
}

- (void)addDebugOutputHandlers {
	[self addResponseHandler:^(CPRequest *request, NSURLResponse *response) {
		NSLog(@"CPRequest: Response: %@: %@", request.url, response);
	}];
	[self addCompletionHandler:^(CPRequest *request, id result) {
		NSLog(@"CPRequest: Success: %@: %@", request.url, result);
	}];
	[self addErrorHandler:^(CPRequest *request, NSError *error) {
		NSLog(@"CPRequest: Error: %@: %@", request.url, error);
	}];
}

/**
 * Body append for POST method
 */
- (void)utfAppendBody:(NSMutableData *)body data:(NSString *)data {
	[body appendData:[data dataUsingEncoding:NSUTF8StringEncoding]];
}

/**
 * Generate body for POST method
 */
- (NSMutableData *)generatePostBody {
	NSMutableData *body = [NSMutableData data];
	NSString *endLine = [NSString stringWithFormat:@"\r\n--%@\r\n", kStringBoundary];
	NSMutableDictionary *dataDictionary = [NSMutableDictionary dictionary];
	
	[self utfAppendBody:body data:[NSString stringWithFormat:@"--%@\r\n", kStringBoundary]];
	
	for (id key in [_params keyEnumerator]) {
		
		if (([[_params objectForKey:key] isKindOfClass:[UIImage class]])
			||([[_params objectForKey:key] isKindOfClass:[NSData class]])) {
			
			[dataDictionary setObject:[_params objectForKey:key] forKey:key];
			continue;
			
		}
		
		[self utfAppendBody:body
					   data:[NSString
							 stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",
							 key]];
        if (![[_params objectForKey:key] isKindOfClass:[NSString class]])
            [self utfAppendBody:body data:[[_params objectForKey:key] description] ];
		else
            [self utfAppendBody:body data:[_params objectForKey:key]];
		
		[self utfAppendBody:body data:endLine];
	}
	
	if ([dataDictionary count] > 0) {
		for (id key in dataDictionary) {
			NSObject *dataParam = [dataDictionary objectForKey:key];
			if ([dataParam isKindOfClass:[UIImage class]]) {
				NSData* imageData = UIImagePNGRepresentation((UIImage*)dataParam);
				[self utfAppendBody:body
							   data:[NSString stringWithFormat:
									 @"Content-Disposition: form-data; filename=\"%@\"\r\n", key]];
				[self utfAppendBody:body
							   data:@"Content-Type: image/png\r\n\r\n"];
				[body appendData:imageData];
			} else {
				NSAssert([dataParam isKindOfClass:[NSData class]],
						 @"dataParam must be a UIImage or NSData");
				[self utfAppendBody:body
							   data:[NSString stringWithFormat:
									 @"Content-Disposition: form-data; filename=\"%@\"\r\n", key]];
				[self utfAppendBody:body
							   data:@"Content-Type: content/unknown\r\n\r\n"];
				[body appendData:(NSData*)dataParam];
			}
			[self utfAppendBody:body data:endLine];
			
		}
	}
	
	return body;
}



- (void)connect {
	if( [Coffeepot shared].requestStarted ) {
		[Coffeepot shared].requestStarted(self);
	}
	
	[self enumerateEventHandlers:kCPLoadBlockHandlerKey block:^(id _handler) {
		void (^handler)(CPRequest*) = _handler;
		handler(self);
	}];
    
    NSString *url = self.url;
    
	if ([self.httpMethod isEqualToString:@"GET"]) {
        url = [[self class] serializeURL:_url params:_params requestMethod:_httpMethod];

    }
    
	NSMutableURLRequest* request =
	[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
							cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
						timeoutInterval:kTimeoutInterval];
	
	[request setValue:kUserAgent forHTTPHeaderField:@"User-Agent"];
	[request setHTTPMethod:self.httpMethod];
	
	if ([self.httpMethod isEqualToString: @"POST"]) {
		NSString* contentType = [NSString
								 stringWithFormat:@"multipart/form-data; boundary=%@", kStringBoundary];
		[request setValue:contentType forHTTPHeaderField:@"Content-Type"];
		
		[request setHTTPBody:[self generatePostBody]];
	}
	
	_connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	self.state = kCPRequestStateLoading;
	self.isSessionExpired = NO;
}

- (void)setState:(CPRequestState)_ {
	_state = _;
	
	[self enumerateEventHandlers:kCPStateChangeBlockHandlerKey block:^(id _handler) {
		void (^handler)(CPRequest *, CPRequestState) = _handler;
		handler(self, _);
	}];
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// NSURLConnectionDelegate

#pragma mark - NSURLConnection Delegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	_responseText = [NSMutableData data];
	
	NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
	
	[self enumerateEventHandlers:kCPResponseBlockHandlerKey block:^(id _handler) {
		void (^handler)(CPRequest*,NSURLResponse*) = _handler;
		handler(self, httpResponse);
	}];
    if ([response respondsToSelector:@selector(statusCode)])
    {
        int statusCode = [((NSHTTPURLResponse *)response) statusCode];
        if (statusCode >= 400)
        {
            NSDictionary *errorInfo
            = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:
                                                  NSLocalizedString(@"Server returned status code %d",@""),
                                                  statusCode]
                                          forKey:NSLocalizedDescriptionKey];
            NSError *statusError = [NSError errorWithDomain:[NSString stringWithFormat:@"%@",httpResponse.URL]
                                  code:statusCode
                              userInfo:errorInfo];
            self.error = statusError;
            self.status_code = statusCode;
        }
    }

}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[_responseText appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
				  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
	return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	if( [Coffeepot shared].requestFinished ) {
		[Coffeepot shared].requestFinished(self);
	}
    
	[self handleResponseData:_responseText];
	
	self.responseText = nil;
	self.connection = nil;
	self.state = kCPRequestStateComplete;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	if( [Coffeepot shared].requestFinished ) {
		[Coffeepot shared].requestFinished(self);
	}

	[self failWithError:error];
	
	self.responseText = nil;
	self.connection = nil;
	self.state = kCPRequestStateComplete;
}

@end
