//
//  CPAppDelegate.h
//  nbg_iOS
//
//  Created by wuhaotian on 12-8-3.
//  Copyright (c) 2012年 wuhaotian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CPUserManageDelegate.h"

// The name of the database the app will use.
#define kDatabaseName @"assignments_3"

// The default remote database URL to sync with, if the user hasn't set a different one as a pref.
#define kDefaultSyncDbURL @"https://zongziwang.cloudant.com/assignments_3"
#define kDefaultHostName @"zongziwang.cloudant.com"
#define kDefaultUsername @"lsonedivelesedsireveredi"
#define kDefaultPassword @"DpjcGHR6yDsYhk0r5q5IuK0H"

// Define this to use a server at a specific URL, instead of the embedded Couchbase Mobile.
// This can be useful for debugging, since you can use the admin console (futon) to inspect
// or modify the database contents.
//#define USE_REMOTE_SERVER @"http://localhost:5984/"

@interface CPAppDelegate : UIResponder <UIApplicationDelegate, CPUserManageDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, retain) CouchDatabase *database;

- (NSURL *)applicationDocumentsDirectory;
- (void)updateAppUserProfileWith:(NSDictionary *)dict;

@end
