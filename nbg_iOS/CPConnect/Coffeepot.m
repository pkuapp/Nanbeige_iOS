//
//  Coffeepot.m
//  nbg_iOS
//
//  Created by wuhaotian on 12-8-7.
//  Copyright (c) 2012年 wuhaotian. All rights reserved.
//

#import "Coffeepot.h"
#import <Objection-iOS/Objection.h>
#import "Models+addon.h"


static NSString *kCPSession = @"com.pkuapp:session";
static NSString *kCPSessionExpiredDate = @"com.pkuapp:session_expired_date";

@interface Coffeepot ()

@property (strong, atomic) User *appUser;
@end

static Coffeepot *coffeepotSharedObject = nil;

@implementation Coffeepot

- (Coffeepot *)init {
    self = [super init];
    if (self) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        self.session = [defaults objectForKey:kCPSession];
        self.expirationDate = [defaults objectForKey:kCPSessionExpiredDate];
    }
    return self;
}

+ (Coffeepot *)shared {
    if (!coffeepotSharedObject) {
        coffeepotSharedObject = [[Coffeepot alloc] init];
    }
    return coffeepotSharedObject;
}

//+ (Coffeepot *)bind {
//    User *appUser = [User sharedUser];
//    if (appUser) {
//        Coffeepot *coffeepot = [[Coffeepot alloc] init];
//        coffeepot.appUser = appUser;
//        return coffeepot;
//    }
//    return nil;
//}

- (void)extendSession {
    
}
- (void)extendSessionIfNeeded {
    
}
- (void)logout {

}

- (BOOL)isSessionExpired {
    return !(self.session != nil && self.expirationDate != nil && NSOrderedDescending == [self.expirationDate compare:[NSDate date]]);
}

- (void)addLoginHandler:(void(^)(Coffeepot* coffeepot, CPLoginState state))handler {
    
}
- (void)addExtendTokenHandler:(void(^)(Coffeepot *coffeepot, NSString *token, NSDate *expiresAt))handler {
    
}
- (void)addLogoutHandler:(void(^)(Coffeepot* coffeepot))handler {
    
}
- (void)addSessionInvalidatedHandler:(void(^)(Coffeepot *coffeepot))handler {

}


- (CPRequest *)requestWithMethodPath:(NSString *)method_path
                              params:(NSDictionary *)params
                             success:(void (^)(CPRequest* _req,id collection))success_block
                               error:(void (^)(CPRequest* _req, NSError *error))error_block {
    return [self requestWithMethodPath:method_path params:params requestMethod:@"GET" success:success_block error:error_block];
}

- (CPRequest *)requestWithMethodPath:(NSString *)method_path
                              params:(NSDictionary *)params
                       requestMethod:(NSString *)httpMethod
                             success:(void (^)(CPRequest* _req,id collection))success_block
                               error:(void (^)(CPRequest* _req, NSError *error))error_block {
	return [self openUrl:method_path params:params requestMethod:httpMethod finalize: ^(CPRequest *request) {
								  if( success_block ) {
									  [request addCompletionHandler:success_block];
								  }
								  if( error_block ) {
									  [request addErrorHandler:error_block];
								  }
							  }];
}

- (CPRequest *)requestWithMethodPath:(NSString *)method_path
                              params:(NSDictionary *)params
                       requestMethod:(NSString *)httpMethod
                                 raw:(void (^)(CPRequest* _req, NSData *data))raw_block
                               error:(void (^)(CPRequest*request, NSError *error))error_block {
    return [self openUrl:method_path params:params requestMethod:httpMethod finalize:^(CPRequest *_req) {
        if (raw_block) [_req addRawHandler:raw_block];
        if (error_block) {
            [_req addErrorHandler:error_block];
        }
    }];
}


- (CPRequest *)requestWithMethodPath:(NSString *)method_path
                              params:(NSDictionary *)params
                       requestMethod:(NSString *)httpMethod
                                 raw:(void (^)(CPRequest *_req, NSData *data))raw_block {
    return [self openUrl:method_path params:params requestMethod:httpMethod finalize:^(CPRequest *_req){
        if (raw_block) {
            [_req addRawHandler:raw_block];
        }
    }];

}

- (CPRequest*)openUrl:(NSString *)url
               params:(NSDictionary *)params
		requestMethod:(NSString *)httpMethod
			 finalize:(void(^)(CPRequest*))finalize {

    
//    [self extendAccessTokenIfNeeded];
    
    CPRequest* _request = [CPRequest getRequestWithParameters:params
												requestMethod:httpMethod
												   requestURL:url];
//    [_request addDebugOutputHandlers];
    [_requests addObject:_request];
	
	[_request registerEventHandler:kCPStateChangeBlockHandlerKey handler:^(CPRequest *request, CPRequestState state) {
		if( state == kCPRequestStateComplete ) {
			if( [request isSessionExpired] ) {
//				[self invalidateSession];
				[self _applyCoreHandlers:kCPSessionBlockHandlerKey];
			}
			[_requests removeObject:request];
		}
	}];
	
	if( finalize ) {
		finalize(_request);
	}
	
    [_request connect];
    return _request;
}

- (void)_applyCoreHandlers:(NSString*)event {
	[self enumerateEventHandlers:event block:^(id _handler) {
		void (^handler)(Coffeepot*) = _handler;
		handler(self);
	}];
}
@end
