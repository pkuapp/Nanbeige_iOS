//
//  CPEventManager.h
//  CP
//
//  Created by ZongZiWang on 12-8-9.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"

@protocol EventManagerDelegate <NSObject>
@optional

- (void)didRequest:(ASIHTTPRequest *)request FailWithError:(NSString *)errorString;
- (void)didRequest:(ASIHTTPRequest *)request FailWithErrorCode:(NSString *)errorCode;

- (void)didEventsReceived:(NSArray *)events;
- (void)didEventCategoriesReceived:(NSArray *)categories;
- (void)didEventReceived:(NSDictionary *)event
			WithEvent_ID:(NSNumber *)event_id;
- (void)didEventFollowedWithEvent_ID:(NSNumber *)event_id;
- (void)didEventFollowingsReceived:(NSArray *)followings;

@end

@interface CPEventManager : NSObject
@property (strong, nonatomic) id<EventManagerDelegate> delegate;

- (void)requestEventsWithKeyword:(NSString *)keyword
					 Category_ID:(NSNumber *)category_id
					   AfterTime:(NSDate *)after
					  BeforeTime:(NSDate *)before
						   Start:(NSNumber *)start;
- (void)requestEventCategories;
- (void)requestEventWithEvent_ID:(NSNumber *)event_id;
- (void)followEventWithEvent_ID:(NSNumber *)event_id;
- (void)requestEventFollowings;

@end
