//
//  CPAccountManageDelegate.h
//  nbg_iOS
//
//  Created by wuhaotian on 12-8-11.
//  Copyright (c) 2012年 wuhaotian. All rights reserved.
//

#import <Foundation/Foundation.h>

//user profile keys are defined as adding a prefix 'com.pkuapp' to server-side key returned


@protocol CPUserManageDelegate <NSObject>

- (void)updateAppUserProfileWith:(NSDictionary *)dict;

@end
