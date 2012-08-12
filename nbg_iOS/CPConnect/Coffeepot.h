//
//  Coffeepot.h
//  nbg_iOS
//
//  Created by wuhaotian on 12-8-7.
//  Copyright (c) 2012年 wuhaotian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CPRequest.h"

#define kCPMethodPost   @"POST"
#define kCPMethodGet    @"GET"
#define kCPMethodDelete @"DELETE"

#define kCPLoginBlockHandlerKey @"login"
#define kCPExtendTokenBlockHandlerKey @"extend"
#define kCPLogoutBlockHandlerKey @"logout"
#define kCPSessionBlockHandlerKey @"session"

typedef enum {
    kCPLoginSuccess,
	kCPLoginCancelled,
	kCPLoginFailed,
	kCPLoginRevoked
}CPLoginState;

@interface Coffeepot : CPBlockHandler {
    NSMutableSet* _requests;
    
}
@property (nonatomic, copy) NSString* session;
@property (strong, nonatomic) NSDate* expirationDate;
@property (copy) void (^requestStarted)(CPRequest*);
@property (copy) void (^requestFinished)(CPRequest*);

+ (Coffeepot *)shared;
//+ (Coffeepot *)authorizeWithEmail:(NSString *)email Password:(NSString *)password;
//+ (Coffeepot *)authorizeWithSianWeiboToken:(NSString* )token;

- (void)extendSession;
- (void)extendSessionIfNeeded;
- (void)logout;
- (BOOL)isSessionExpired;

- (void)addLoginHandler:(void(^)(Coffeepot* coffeepot, CPLoginState state))handler;
- (void)addExtendTokenHandler:(void(^)(Coffeepot *coffeepot, NSString *token, NSDate *expiresAt))handler;
- (void)addLogoutHandler:(void(^)(Coffeepot* coffeepot))handler;
- (void)addSessionInvalidatedHandler:(void(^)(Coffeepot *coffeepot))handler;


- (CPRequest *)requestWithMethodPath:(NSString *)method_path
                               params:(NSDictionary *)params
                              success:(void (^)(CPRequest*request,id collection))success_block
                                error:(void (^)(CPRequest*request,id collection, NSError *error))error_block;

- (CPRequest *)requestWithMethodPath:(NSString *)method_path
                              params:(NSDictionary *)params
                       requestMethod:(NSString *)httpMethod
                             success:(void (^)(CPRequest*request,id collection))success_block
                               error:(void (^)(CPRequest*request,id collection, NSError *error))error_block;



@end
