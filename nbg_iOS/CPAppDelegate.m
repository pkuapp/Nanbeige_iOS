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

@implementation CPAppDelegate

- (void)configureGlobalAppearance {
//    [[UITableView appearance] setBackgroundColor:[UIColor colorWithRed:214.0/255 green:214.0/255 blue:214.0/255 alpha:1.0]];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
//    [MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreNamed:@"nbg_iOS"];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    JSObjectionInjector *injector = [JSObjection createInjector:[[CPAppModule alloc] init]];
    [JSObjection setDefaultInjector:injector];
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"CPSignInFlow" bundle:[NSBundle mainBundle]];
    UINavigationController *rvc = [sb instantiateInitialViewController];
    
    self.window.rootViewController = rvc;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
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
