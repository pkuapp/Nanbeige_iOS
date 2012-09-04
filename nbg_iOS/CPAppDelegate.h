//
//  CPAppDelegate.h
//  nbg_iOS
//
//  Created by wuhaotian on 12-8-3.
//  Copyright (c) 2012年 wuhaotian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CPUserDefaultDelegate.h"
#import "MBProgressHUD.h"

// The name of the database the app will use.
//#define kDatabaseName @"assignments_3"
#define kDatabaseNameWithID(id) [NSString stringWithFormat:@"user_sync_db_%@", (id)]
#define kLocalDatabaseName @"nbg_db"

// The default remote database URL to sync with, if the user hasn't set a different one as a pref.
//#define kDefaultSyncDbURL @"https://zongziwang.cloudant.com/assignments_3"
#define kSyncDbURLWithID(id) [NSString stringWithFormat:@"http://api.pkuapp.com:5984/user_sync_db_%@", (id)]
//#define kDefaultHostName @"zongziwang.cloudant.com"
#define kSyncDbHostNameWithID(id) @"api.pkuapp.com"
//#define kDefaultUsername @"lsonedivelesedsireveredi"
#define kSyncDbUsername [[NSUserDefaults standardUserDefaults] objectForKey:@"sync_db_username"]
//#define kDefaultPassword @"DpjcGHR6yDsYhk0r5q5IuK0H"
#define kSyncDbPassword [[NSUserDefaults standardUserDefaults] objectForKey:@"sync_db_password"]

// Define this to use a server at a specific URL, instead of the embedded Couchbase Mobile.
// This can be useful for debugging, since you can use the admin console (futon) to inspect
// or modify the database contents.
//#define USE_REMOTE_SERVER @"http://localhost:5984/"

@interface CPAppDelegate : UIResponder <UIApplicationDelegate, CPUserManageDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, retain) CouchTouchDBServer *server;
@property (nonatomic, retain) CouchDatabase *database;
@property (nonatomic, retain) CouchDatabase *localDatabase;

@property (nonatomic, strong) MBProgressHUD *progressHud;

- (void)showProgressHud:(NSString *)title;
- (void)hideProgressHud;
- (void)hideProgressHudAfterDelay:(NSTimeInterval)time;
- (void)showProgressHudModeAnnularDeterminate:(NSString *)title;
- (void)setProgressHudProgress:(float)progress;

- (NSURL *)applicationDocumentsDirectory;
- (void)updateAppUserProfileWith:(NSDictionary *)dict;

@end
