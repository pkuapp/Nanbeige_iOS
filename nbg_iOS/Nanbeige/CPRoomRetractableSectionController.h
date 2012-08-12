//
//  CPRoomRetractableSectionController.h
//  nbg_iOS
//
//  Created by ZongZiWang on 12-8-13.
//  Copyright (c) 2012年 wuhaotian. All rights reserved.
//

#import "GCRetractableSectionController.h"

@interface CPRoomRetractableSectionController : GCRetractableSectionController

@property (nonatomic, copy, readwrite) NSString* title;

- (id)initWithArray:(NSArray*) array viewController:(UIViewController *)givenViewController;

@end