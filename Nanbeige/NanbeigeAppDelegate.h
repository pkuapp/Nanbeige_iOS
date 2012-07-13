//
//  NanbeigeAppDelegate.h
//  Nanbeige
//
//  Created by Wang Zhongyu on 12-7-9.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PABezelHUDDelegate.h"
#import "AppUserDelegateProtocol.h"
#import "ReachabilityProtocol.h"
#import "Reachability.h"
#import "AppCoreDataProtocol.h"

@class SwitchViewController,NSPersistentStoreCoordinator,NSManagedObjectContext;
@class FirstViewController;
@class MainViewController;
@class WelcomeViewController;
@class AppUser;
@class Course;

@interface NanbeigeAppDelegate : UIResponder <ReachabilityProtocol,UIApplicationDelegate,UINavigationControllerDelegate,AppUserDelegateProtocol,AppUserDelegateProtocol,PABezelHUDDelegate> {
	
	NSManagedObjectContext *managedObjectContext;
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSString *persistentStorePath;
    AppUser *appUser;
    
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain, readonly) NSOperationQueue *operationQueue;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSString *persistentStorePath;

@property (nonatomic, retain)AppUser *appUser;
@property (atomic, retain) Reachability *wifiTester;
@property (atomic, retain) Reachability *internetTester;
@property (atomic, retain) Reachability *globalTester;
@property (atomic, retain) Reachability *freeTester;
@property (atomic, retain) Reachability *localTester;
@property (atomic) PKUNetStatus netStatus;
@property (nonatomic) BOOL hasWifi;
@property (nonatomic, retain)MBProgressHUD *progressHub;

@property (nonatomic, retain, readonly) NSDictionary *test_data;


- (void)logout;
- (BOOL)authUserForAppWithUsername:(NSString *)username password:(NSString *)password deanCode:(NSString *)deanCode sessionid:(NSString *)sid error:(NSString **)stringError;
- (BOOL)refreshAppSession;
- (NSError *)updateAppUserProfile;
- (NSError *)updateServerCourses;
- (void)saveCourse:(Course *)_course withDict:(NSDictionary *)dict;
- (void)netStatusDidChanged:(Reachability *)notice;

@end
