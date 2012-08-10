//
//  NanbeigeWikiManager.h
//  Nanbeige
//
//  Created by ZongZiWang on 12-8-9.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"

@protocol WikiManagerDelegate <NSObject>
@optional

- (void)didRequest:(ASIHTTPRequest *)request FailWithError:(NSString *)errorString;
- (void)didRequest:(ASIHTTPRequest *)request FailWithErrorCode:(NSString *)errorCode;

- (void)didWikiesReceived:(NSArray *)wikies
	   WithUniversity_ID:(NSNumber *)university_id;
- (void)didWikiReceived:(NSDictionary *)wiki
			WithNode_ID:(NSNumber *)node_id;

@end

@interface NanbeigeWikiManager : NSObject
@property (strong, nonatomic) id<WikiManagerDelegate> delegate;

- (void)requestWikiesWithUniversity_ID:(NSNumber *)university_id;
- (void)requestWikiWithNode_ID:(NSNumber *)node_id;

@end
