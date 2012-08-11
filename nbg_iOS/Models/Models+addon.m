//
//  User+ModelsAddon.m
//  nbg_iOS
//
//  Created by wuhaotian on 12-8-9.
//  Copyright (c) 2012年 wuhaotian. All rights reserved.
//

#import "ModelsAddon.h"
#import <CoreData/CoreData.h>

static User *sharedAppUserObject = nil;

@implementation User (ModelsAddon)

+ (User *)sharedAppUser{
    if (!sharedAppUserObject) {
        sharedAppUserObject = [User findAll].count ? [[User findAll] objectAtIndex:1] : nil;
    }
    return sharedAppUserObject;
}
@end
