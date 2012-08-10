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

@interface CPRequest () {
}
@property (nonatomic,readwrite) CPRequestState state;
@property (nonatomic,readwrite) BOOL isSessionExpired;
@end

@implementation CPRequest

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


- (void)addCompletionHandler:(void(^)(CPRequest*,id))completionHandler {
	[self registerEventHandler:kCPCompletionBlockHandlerKey handler:completionHandler];
}
- (void)addErrorHandler:(void(^)(CPRequest*,NSError *))errorHandler {
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

/**
 * Formulate the NSError
 */
- (id)formError:(NSInteger)code userInfo:(NSDictionary *) errorData {
	return [NSError errorWithDomain:@"facebookErrDomain" code:code userInfo:errorData];
	
}

- (void)connect {
	if( [Coffeepot sharedCoffeepot].requestStarted ) {
		[Coffeepot sharedCoffeepot].requestStarted(self);
	}
	
	[self enumerateEventHandlers:kCPLoadBlockHandlerKey block:^(id _handler) {
		void (^handler)(CPRequest*) = _handler;
		handler(self);
	}];
	
	NSString* url = [[self class] serializeURL:_url params:_params requestMethod:_httpMethod];
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
	
//	_connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
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

@end
