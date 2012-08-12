//
//  CPAppDelegate.h
//  nbg_iOS
//
//  Created by wuhaotian on 12-8-3.
//  Copyright (c) 2012年 wuhaotian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CPUserDefaultDelegate.h"

@interface CPAppDelegate : UIResponder <UIApplicationDelegate, CPUserManageDelegate>

@property (strong, nonatomic) UIWindow *window;

- (NSURL *)applicationDocumentsDirectory;
- (void)updateAppUserProfileWith:(NSDictionary *)dict;

@end
