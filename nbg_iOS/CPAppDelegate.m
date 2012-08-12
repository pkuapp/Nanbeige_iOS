//
//  CPAppDelegate.m
//  nbg_iOS
//
//  Created by wuhaotian on 12-8-3.
//  Copyright (c) 2012年 wuhaotian. All rights reserved.
//

#import "CPAppDelegate.h"
#import "MagicalRecord.h"
#import <Objection-iOS/Objection.h>
#import "CPAppModule.h"
#import "Models/Models+addon.h"
@interface CPAppDelegate ()

- (BOOL)needSignin;

@end

@implementation CPAppDelegate

- (void)updateAppUserProfileWith:(NSDictionary *)dict {
    for (NSString* key in [dict allKeys]) {
        [[NSUserDefaults standardUserDefaults] setObject:[dict objectForKey:key] forKey:[NSString stringWithFormat:@"com.pkuapp:%@",key]];
    }
}

- (BOOL)needSignin {
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//	if ([defaults valueForKey:kWEIBOIDKEY] == nil &&
//		[defaults valueForKey:kRENRENIDKEY] == nil &&
//		[defaults valueForKey:kCPEMAILKEY] == nil) {
//		[[NSUserDefaults standardUserDefaults] removeObjectForKey:kACCOUNTIDKEY];
//	}
//	
//	if ([[NSUserDefaults standardUserDefaults] valueForKey:kACCOUNTIDKEY] != nil) {
//        return NO;
//	} else {
//		id workaround51Crash = [[NSUserDefaults standardUserDefaults] objectForKey:@"WebKitLocalStorageDatabasePathPreferenceKey"];
//		NSDictionary *emptySettings = (workaround51Crash != nil)
//		? [NSDictionary dictionaryWithObject:workaround51Crash forKey:@"WebKitLocalStorageDatabasePathPreferenceKey"]
//		: [NSDictionary dictionary];
//		[[NSUserDefaults standardUserDefaults] setPersistentDomain:emptySettings forName:[[NSBundle mainBundle] bundleIdentifier]];
//        return YES;
//	}
    return ![[[NSUserDefaults standardUserDefaults] objectForKey:@"CPIsSignedIn"] boolValue];
}

- (void)configureGlobalAppearance {
//    [[UITableView appearance] setBackgroundColor:[UIColor colorWithRed:214.0/255 green:214.0/255 blue:214.0/255 alpha:1.0]];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    [MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreNamed:@"nbg_iOS"];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    JSObjectionInjector *injector = [JSObjection createInjector:[[CPAppModule alloc] init]];
    [JSObjection setDefaultInjector:injector];

    if (self.needSignin) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"CPSigninFlow" bundle:[NSBundle mainBundle]];
        UINavigationController *rvc = [sb instantiateInitialViewController];
        self.window.rootViewController = rvc;
    }
    else {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"MainStoryBoard_iPhone" bundle:[NSBundle mainBundle]];
        self.window.rootViewController = [sb instantiateInitialViewController];
    }
    
    [self.window makeKeyAndVisible];
    
    return YES;
}


- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [MagicalRecord cleanUp];
}



#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
