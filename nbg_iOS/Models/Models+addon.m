//
//  User+ModelsAddon.m
//  nbg_iOS
//
//  Created by wuhaotian on 12-8-9.
//  Copyright (c) 2012年 wuhaotian. All rights reserved.
//

#import "Models+addon.h"
#import <CoreData/CoreData.h>
#import "MagicalRecord.h"

static User *sharedAppUserObject = nil;

@implementation User (addon)

+ (User *)sharedAppUser{
    @synchronized(sharedAppUserObject){
        if (!sharedAppUserObject) {
            sharedAppUserObject = [User findAll].count ? [[User findAll] objectAtIndex:0] : nil;
            if (!sharedAppUserObject) {
                sharedAppUserObject = [User createEntity];
                [[NSManagedObjectContext defaultContext] save];
            }
        }
    }
    return sharedAppUserObject;
}

+ (void)updateSharedAppUserProfile:(NSDictionary *)dict {
    User *user = [self sharedAppUser];
    
    if ([dict objectForKey:@"id"]) {
        user.id = [dict objectForKey:@"id"];
    }
	if ([dict objectForKey:@"nickname"]) {
        user.nickname = [dict objectForKey:@"nickname"];
    }
	
    if ([dict objectForKey:@"email"]) {
        user.email = [dict objectForKey:@"email"];
    }
    if ([dict objectForKey:@"weibo_token"]) {
        user.weibo_token = [dict objectForKey:@"weibo_token"];
    }
    if ([dict objectForKey:@"renren_token"]) {
        user.renren_token = [dict objectForKey:@"renren_token"];
    }
	if ([dict objectForKey:@"weibo_name"]) {
		user.weibo_name = [dict objectForKey:@"weibo_name"];
	}
	if ([dict objectForKey:@"renren_name"]) {
		user.renren_name = [dict objectForKey:@"renren_name"];
	}
	
    if ([dict objectForKey:@"university"] && ![[dict objectForKey:@"university"] isKindOfClass:[NSNull class]]) {
        user.university_name = [[dict objectForKey:@"university"] objectForKey:@"name"];
        user.university_id = [[dict objectForKey:@"university"] objectForKey:@"id"];
    }
	
    if ([dict objectForKey:@"campus"] && ![[dict objectForKey:@"campus"] isKindOfClass:[NSNull class]]) {
        user.campus_name = [[dict objectForKey:@"campus"] objectForKey:@"name"];
        user.campus_id = [[dict objectForKey:@"campus"] objectForKey:@"id"];
    }
	
    [[NSManagedObjectContext defaultContext] save];
}

+ (void)deactiveSharedAppUser
{
	@synchronized(sharedAppUserObject){
        if (sharedAppUserObject) {
            [sharedAppUserObject deleteEntity];
			sharedAppUserObject = nil;
			[[NSManagedObjectContext defaultContext] save];
        }
    }
}

@end
