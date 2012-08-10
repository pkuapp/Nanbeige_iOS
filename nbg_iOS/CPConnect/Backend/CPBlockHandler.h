//
//  CPRequest.h
//  nbg_iOS
//
//  Created by wuhaotian on 12-8-8.
//  Copyright (c) 2012年 wuhaotian. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CPBlockHandler;

@protocol CPBlockProvider <NSObject>

- (CPBlockHandler*)blockHandler;

@end

@interface CPBlockHandler : NSObject <CPBlockProvider>

- (void)registerEventHandler:(NSString*)event handler:(id)block;
- (void)registerEventHandler:(NSString*)event discard:(BOOL)discard handler:(id)block;
- (void)enumerateEventHandlers:(NSString*)event block:(void(^)(id _handler))block;
- (NSUInteger)eventHandlerCount:(NSString*)event;
- (void)clearEventHandlers:(NSString*)event;

@end
