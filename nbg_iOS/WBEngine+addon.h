//
//  WBEngine+Customized.h
//  nbg_iOS
//
//  Created by wuhaotian on 12-8-11.
//  Copyright (c) 2012年 wuhaotian. All rights reserved.
//

#import "WBEngine.h"
#import "CPBlockHandler.h"

@interface WBEngine (Customized)

+ (WBEngine *)sharedWBEngine;

- (void)loadRequestWithMethodName:(NSString *)methodName
                       httpMethod:(NSString *)httpMethod
                           params:(NSDictionary *)params
                     postDataType:(WBRequestPostDataType)postDataType
                 httpHeaderFields:(NSDictionary *)httpHeaderFields
                          success:(void (^)(WBRequest *request, id result))success_block
                             fail:(void (^)(WBRequest *request, NSError *error))fail_block;
@end
