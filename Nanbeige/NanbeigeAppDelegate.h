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
@property (nonatomic, strong, readonly) NSOperationQueue *operationQueue;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong, readonly) NSString *persistentStorePath;

@property (nonatomic, strong)AppUser *appUser;
@property (atomic, strong) Reachability *wifiTester;
@property (atomic, strong) Reachability *internetTester;
@property (atomic, strong) Reachability *globalTester;
@property (atomic, strong) Reachability *freeTester;
@property (atomic, strong) Reachability *localTester;
@property (atomic) PKUNetStatus netStatus;
@property (nonatomic) BOOL hasWifi;
@property (nonatomic, strong)MBProgressHUD *progressHub;

@property (nonatomic, strong, readonly) NSDictionary *test_data;


- (void)logout;
- (BOOL)authUserForAppWithCoursesID:(NSString *)coursesid coursesPassword:(NSString *)coursespassword coursesCode:(NSString *)coursescode sessionID:(NSString *)sid error:(NSString **)stringError;

- (BOOL)refreshAppSession;
- (NSError *)updateAppUserProfile;
- (NSError *)updateServerCourses;
- (void)saveCourse:(Course *)_course withDict:(NSDictionary *)dict;
- (void)netStatusDidChanged:(Reachability *)notice;

@end
