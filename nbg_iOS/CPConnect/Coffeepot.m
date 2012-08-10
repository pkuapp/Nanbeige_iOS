//
//  Coffeepot.m
//  nbg_iOS
//
//  Created by wuhaotian on 12-8-7.
//  Copyright (c) 2012年 wuhaotian. All rights reserved.
//

#import "Coffeepot.h"
#import <Objection-iOS/Objection.h>
#import "ModelsAddon.h"

static NSString *pURLPrefix = @"http://api.pkuapp.com:433/";

@interface Coffeepot ()

@property (strong, atomic) User *appUser;
@end

static Coffeepot *coffeepotSharedObject = nil;

@implementation Coffeepot


+ (Coffeepot *)sharedCoffeepot {
    if (!coffeepotSharedObject) {
        return [self bind];
    }
    return coffeepotSharedObject;
}

+ (Coffeepot *)bind {
    User *appUser = [User sharedUser];
    if (appUser) {
        Coffeepot *coffeepot = [[Coffeepot alloc] init];
        coffeepot.appUser = appUser;
        return coffeepot;
    }
    return nil;
}
+ (Coffeepot *)authorizeWithEmail:(NSString *)email Password:(NSString *)password{
    return [self bind];
}
+ (Coffeepot *)authorizeWithSianWeiboToken:(NSString* )token {
    return [self bind];
}

- (void)extendSession {
    
}
- (void)extendSessionIfNeeded {
    
}
- (void)logout {

}
- (BOOL)isSessionExpired {
    
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
                        responseType:(Class)class_name
                             success:(void (^)(id collection))success_block
                               error:(void (^)(id collection, NSError *error))error_block {

}

- (CPRequest *)requestWithMethodPath:(NSString *)method_path
                              params:(NSDictionary *)params
                       requestMethod:(NSString *)httpMethod
                        responseType:(Class)class_name
                             success:(void (^)(id))success_block
                               error:(void (^)(id, NSError *))error_block {

}


@end
