//
//  NanbeigeAppDelegate.m
//  Nanbeige
//
//  Created by Wang Zhongyu on 12-7-9.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import "NanbeigeAppDelegate.h"
#import "Environment.h"
#import <CoreData/CoreData.h>
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "AppUser.h"
#import "SBJson.h"
#import "AppUserDelegateProtocol.h"
#import "SystemHelper.h"
#import "School.h"
#import "Course.h"
#import "ModalAlert.h"

@interface NanbeigeAppDelegate(Private)
- (void)checkVersion;
- (void)checkVersionDone;
- (NSString *)parsedLoginError:(NSString *)loginmessage;
@end

@implementation NanbeigeAppDelegate
@synthesize operationQueue;
@synthesize wifiTester,internetTester,globalTester,freeTester,localTester;
@synthesize netStatus;
@synthesize hasWifi;
@synthesize appUser;
@synthesize progressHub;
@synthesize test_data;
@synthesize window = _window;

#pragma mark - getter and setter Override
- (NSDictionary *)test_data {
    if (test_data == nil) {
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"test_data" ofType:@"plist"]];
        test_data = dict;
    }
    return test_data;
}
#pragma mark Private method

- (NSString *)parsedLoginError:(NSString *)loginmessage {
    if ([loginmessage rangeOfString:@"图形"].location != NSNotFound) {
		//        NSLog(@"%d",[loginmessage rangeOfRegex:@"图形"].location);
        return @"图形验证码错误";
    }
    else if ([loginmessage rangeOfString:@"学号"].location != NSNotFound) {
        return @"综合信息服务帐号错误";
    }
    else if ([loginmessage rangeOfString:@"密码"].location != NSNotFound){
        return @"密码错误";
    }
    else return @"未知错误";
}

- (void)checkVersionDone:(ASIHTTPRequest *)request {
    NSNumber *version = [[[request responseString] JSONValue] objectForKey:@"beta"];
    NSLog(@"checking version");
    if ([version intValue] > iOSVersionNum) {
        if ([ModalAlert ask:@"新的版本可用" withMessage:@"前往网站获取新版本"]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-services://?action=download-manifest&url=http://pkuapp.com/download/iOS/manifest.plist"]];
        } 
    }
}

- (void)checkVersion {
	
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url_iOS_version]];
    
    request.delegate = self;
    
    request.didFinishSelector = @selector(checkVersionDone:);
    
    request.didFailSelector = @selector(checkVersionDone:);
    
    [request startAsynchronous];
}


#pragma mark - UserControl Setup
- (MBProgressHUD *)progressHub {
    if (progressHub == nil) {
        progressHub = [[MBProgressHUD alloc] initWithWindow:self.window];
        progressHub.userInteractionEnabled = NO;
        progressHub.opacity = 0.618;
        progressHub.animationType = MBProgressHUDAnimationZoom;
		progressHub.taskInProgress = NO;
        [self.window addSubview:progressHub];
    }
    return progressHub;
}

-(AppUser *)appUser
{
    if (nil == appUser) {
        //NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        //NSString *username = [defaults stringForKey:@"appUser"];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"AppUser" inManagedObjectContext:self.managedObjectContext];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        fetchRequest.entity = entity;
        
        //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"coursesid == %@",username];
        //fetchRequest.predicate = predicate;
        
        appUser = (AppUser *) [[self.managedObjectContext executeFetchRequest:fetchRequest error:NULL] lastObject];
		
		NSLog(@"get appUser%@",appUser);
		
    }
    return appUser;
}

-(void)logout
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:NO forKey:@"didLogin"];
	
    [NSUserDefaults resetStandardUserDefaults];
    [self.appUser removeCourses:self.appUser.courses];
    self.appUser = nil;
	//    [persistentStoreCoordinator release];
	//    persistentStoreCoordinator = nil;
	//    [managedObjectContext release];
	//    managedObjectContext = nil;
    
}

- (BOOL)authUserForAppWithCoursesID:(NSString *)coursesid coursesPassword:(NSString *)coursespassword coursesCode:(NSString *)coursescode sessionID:(NSString *)sid error:(NSString **)stringError
{
    NSString *loginmessage;
	
    if ([coursesid isEqualToString:test_username]) {
        loginmessage = @"0";
    }
    else {
        NSString *urlLogin;
        NSString *usernameKey;
        NSString *passwordKey;
        NSString *validKey;
        NSString *sessionKey;
        if ([SystemHelper getPkuWeeknumberNow] <= 2) {
            urlLogin = urlLoginEle;
            usernameKey = @"username";
            passwordKey = @"passwd";
            validKey = @"valid";
            sessionKey = @"sessionid";
        }
        else {
            urlLogin = urlLoginDean;
            usernameKey = @"sno";
            passwordKey = @"pwd";
            validKey = @"check";
            sessionKey = @"sid";
        }
        
        
        ASIFormDataRequest *requestLogin = [ASIFormDataRequest requestWithURL:[NSURL URLWithString: urlLogin]];
        requestLogin.timeOutSeconds = 30;
        [requestLogin setPostValue:coursesid forKey:usernameKey];
        [requestLogin setPostValue:coursespassword forKey:passwordKey];
        [requestLogin setPostValue:coursescode forKey:validKey];
        [requestLogin setPostValue:sid forKey:sessionKey];
        
        [requestLogin startSynchronous];
        
        loginmessage = [requestLogin responseString]; //[[NSString alloc] initWithData:[requestLogin responseData] encoding:NSStringEncodingConversionAllowLossy];
        if (!requestLogin.isFinished) {
            *stringError = @"连接超时";
            return NO;
        }
        NSLog(@"get login response:%@",loginmessage);
    }
	
    
    
    if ([loginmessage isEqualToString:@"0"]){
        if (appUser == nil) {
            
			appUser = (AppUser *) [NSEntityDescription insertNewObjectForEntityForName:@"AppUser" inManagedObjectContext:self.managedObjectContext];
            NSLog(@"create appUser %@", appUser);
		}
		
		
        appUser.coursesid = coursesid;
        appUser.coursespassword = coursespassword;
        NSError *error;
        if ([self.managedObjectContext save:&error]) {
            return YES;
        }
        else {
            NSString *des = [error description];
            *stringError = des;
        }
    }
    NSString *stringResult = [self parsedLoginError:loginmessage];
    *stringError = stringResult;
    return NO;
}

- (NSError *)updateAppUserProfile{
    
    
    NSError *error = nil;
    
    if ([self.appUser.coursesid isEqualToString:test_username]) {
        self.appUser.coursesname = @"TestAccount";
        return error;
    }
    
    ASIHTTPRequest *requestProfile = [ASIHTTPRequest requestWithURL: [NSURL URLWithString: urlProfile]];
    [requestProfile startSynchronous];
    
    NSString *stringProfile = [requestProfile responseString];
    NSDictionary *dictProfile = [stringProfile JSONValue];
    self.appUser.coursesname = [dictProfile objectForKey:@"realname"];
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"%@",[error localizedDescription]);
    }
    return error;
}

- (void)saveCourse:(Course *)_course withDict:(NSDictionary *)dictCourse {
    for (NSString *key in [dictCourse keyEnumerator]) {
        NSString *localKey = key;
        if ([key isEqualToString:@"cname"]) {
            if ([[dictCourse objectForKey:@"cname"] isEqualToString:@""]) {
                continue;
            }
            localKey = @"name";
        }
        if ([key isEqualToString:@"name"] || [key isEqualToString:@"ename"]) {
            continue;
        }
        NSString *selector = [NSString stringWithFormat:@"setPrimitive%@:",localKey];
        id object = [dictCourse objectForKey:key];
        if (object != [NSNull null]) {
            @try {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                [_course performSelector:sel_getUid([selector UTF8String]) withObject:[dictCourse objectForKey:key]];
#pragma clang diagnostic pop
            }
            @catch (NSException *exception) {
                NSLog(@"Failed to update key %@",key);
            }
            @finally {
                continue;
                NSLog(@"%@",object);
            }
        }
        
    }
    [self.managedObjectContext save:nil];
    
}

- (NSError *)updateServerCourses{
    
    NSError *error;
    
    NSArray *jsonCourse;
    
    NSString *stringCourse;
    
    if ([self.appUser.coursesid isEqualToString:test_username]) {
		
        stringCourse = [self.test_data valueForKeyPath:@"user.json_courses"];
        NSLog(@"sdf%@",stringCourse);
		
    }
    
    else {
        ASIHTTPRequest *requestCourse = [ASIHTTPRequest requestWithURL: [NSURL URLWithString: urlCourse]];
        [requestCourse startSynchronous];
        
        stringCourse = [requestCourse responseString];
    }
    jsonCourse = [stringCourse JSONValue];
    
    if (jsonCourse.count == 0) {
		//        error = [[NSError alloc] initWithDomain:@"未获得有效课程" code:0 
        return nil;
    }
    
    NSMutableArray *arrayCourses = [NSMutableArray arrayWithCapacity:5];
    
    NSDictionary *dictCourse;
    
    NSString *stringPredicate;// = [NSMutableString stringWithCapacity:0];
    
	for (int i = 0 ;i < jsonCourse.count; i++){
        dictCourse = [jsonCourse objectAtIndex:i];
        stringPredicate = [NSString stringWithFormat:@"id == %@",[dictCourse objectForKey:@"id"]];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Course" inManagedObjectContext:self.managedObjectContext];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:stringPredicate];
        request.entity = entity;
        request.predicate = predicate;
        NSArray *_array = [self.managedObjectContext executeFetchRequest:request error:&error];
        Course *_course = nil;
        if (!_array.count) {
            _course = (Course *)[NSEntityDescription insertNewObjectForEntityForName:@"Course" inManagedObjectContext:self.managedObjectContext];
            
            [self saveCourse:_course withDict:dictCourse];
			
        }
        else {
            _course = [_array lastObject];
            [self saveCourse:_course withDict:dictCourse];
			
        }
        if (_course) {
            [arrayCourses addObject:_course];
        }
		
    }
    [self.managedObjectContext save:&error];
    
	
    
    NSLog(@"count:%d",arrayCourses.count);
    
    NSSet *courseset = [NSSet setWithArray:arrayCourses];
    
    
    [self.appUser addCourses:courseset];
    
    if (![self.managedObjectContext save:&error]) NSLog(@"SaveError: %@", [error localizedDescription]);
    return error;
}


- (BOOL)refreshAppSession
{
    return YES;
}

#pragma -

- (void)netStatusDidChanged:(NSNotification *)notice {
    Reachability *r = [notice object];
	//    if ([r.key isEqualToString:@"global"]) {
	//        NSLog(@"reachable%d",r.isReachable);
	//        self.netStatus = r.isReachable?PKUNetStatusGlobal:self.netStatus;
	//        
	//    }
	//    else if ([r.key isEqualToString:@"free"]){
	//        if (r.isReachable) {
	//            self.netStatus = self.netStatus < PKUNetStatusFree?PKUNetStatusFree:self.netStatus;
	//        }
	//        else self.netStatus = self.netStatus > PKUNetStatusLocal?PKUNetStatusLocal:self.netStatus;
	//    }
	//    else if ([r.key isEqualToString:@"local"]){
	//        if (r.isReachable) {
	//            self.netStatus = self.netStatus < PKUNetStatusLocal?PKUNetStatusLocal:self.netStatus;
	//        }
	//        else self.netStatus = PKUNetStatusNone;
	//    }
	//    else if ([r.key isEqualToString:@"wifi"]){
	//        self.hasWifi = r.isReachable?YES:NO;
	//    }
    if (r.isReachable) {
        [self checkVersion];
    }
    //[r startNotifier];
	//    NSLog(@"%d",r.currentReachabilityStatus);
    NSLog(@"%d",r.isReachable);
    
}

- (void)generateCoreDataBase {
    /**/
    NSFileManager *fmanager = [NSFileManager defaultManager];
    [fmanager removeItemAtPath:pathsql2 error:nil];
    
    NSError *error;
    
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[NSManagedObjectModel mergedModelFromBundles:nil]];
    [coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[NSURL fileURLWithPath:pathsql2] options:nil error:nil];
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
    [context setPersistentStoreCoordinator:coordinator];
    
    ASIHTTPRequest *schoolrq = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:urlCourseCategory]];
    [schoolrq startSynchronous];
    NSString *responseString = [schoolrq responseString];
    NSArray *tempArray = [responseString JSONValue];
    tempArray = [tempArray objectAtIndex:5];
    NSMutableDictionary *schoolDict = [[NSMutableDictionary alloc] initWithCapacity:0];
    for (NSDictionary *dict in tempArray) {
        School *school = [NSEntityDescription insertNewObjectForEntityForName:@"School" inManagedObjectContext:context];
        school.name = [dict objectForKey:@"name"];
        school.code = [dict objectForKey:@"code"];
        if (![context save:&error]) NSLog(@"%@",[error localizedDescription]);
        [schoolDict setObject:school forKey:school.code];
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"School" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    //NSFetchedResultsController *frc = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:@"school"];
    //[frc performFetch:&error];
    //NSArray *schoolArray = frc.fetchedObjects;
    
    
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:urlCourseAll]];
    [request startSynchronous];
    responseString = [request responseString];
    
    
    NSArray *array = [responseString JSONValue];
    for (NSDictionary *dict in array) {
        if (0 == [(NSString *)[dict objectForKey:@"name"] length] ||
			![[(NSString *)[dict objectForKey:@"name"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]) {//isEmptyOrWhitespace]) {
            continue;
        }
        
        Course *ccourse = (Course *)[NSEntityDescription insertNewObjectForEntityForName:@"Course" inManagedObjectContext:context];
        for (NSString *_key in [dict keyEnumerator]) {
			NSString *key = _key;
            id object = [dict objectForKey:key];
            if ([key isEqualToString:@"cname"]) {
                key = @"name";
                object = [dict objectForKey:@"cname"];
            }
            NSString *selector = [NSString stringWithFormat:@"setPrimitive%@:",key];
            if (object != [NSNull null]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                [ccourse performSelector:sel_getUid([selector UTF8String]) withObject:object];
#pragma clang diagnostic pop
            }
            
        }
        //NSLog(@"%@",ccourse.name);
        ccourse.school = [schoolDict objectForKey:ccourse.SchoolCode];
        
    }
    if (![context save:&error]) NSLog(@"%@",[error localizedDescription]);/**/
}

#pragma mark - Core Data Setup

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (persistentStoreCoordinator == nil) {
        NSURL *storeUrl = [NSURL fileURLWithPath:self.persistentStorePath];
        persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[NSManagedObjectModel mergedModelFromBundles:nil]];
        NSError *error = nil;
        NSPersistentStore *persistentStore = [persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error];
        if (persistentStore == nil) {
            
        }
        NSAssert3(persistentStore != nil, @"Unhandled error %s at line %d: %@", __FUNCTION__, __LINE__, [error localizedDescription]);
    }
    return persistentStoreCoordinator;
}

- (NSManagedObjectContext *)managedObjectContext {
    
    if (managedObjectContext == nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
    }
    return managedObjectContext;
}

- (NSString *)persistentStorePath {
    if (persistentStorePath == nil) {
        persistentStorePath = pathSQLCore;
    }
    return persistentStorePath;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	//    NSLog(@"%@",[[NSBundle mainBundle] bundleIdentifier] );
    /*[self generateCoreDataBase];
	
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSFileManager *fm = [NSFileManager defaultManager];
    
    //[[UIBarButtonItem appearance] setBackButtonBackgroundImage:[[UIImage imageNamed:@"btn-back-normal.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 13, 0, 5)] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    //[[UIBarButtonItem appearance] setBackButtonBackgroundImage:[[UIImage imageNamed:@"btn-back-pressed.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 13, 0, 5)] forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
    
	//    [[UIBarButtonItem appearance] setBackgroundImage:[UIImage imageNamed:@"btn-blue-normal.png"] forState:UIControlStateApplication barMetrics:UIBarMetricsDefault];
    
    //[[UIBarButtonItem appearance] setBackgroundImage:[[UIImage imageNamed:@"btn-normal"] stretchableImageWithLeftCapWidth:5 topCapHeight:0] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    //[[UIBarButtonItem appearance] setBackgroundImage:[[UIImage imageNamed:@"btn-pressed.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)] forState:UIControlEventTouchUpInside barMetrics:UIBarMetricsDefault];
    
    //[[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"navbar.png"] forBarMetrics:UIBarMetricsDefault];
    
    //[[UIToolbar appearance] setBackgroundImage:[UIImage imageNamed:@"toolbar.png"] forToolbarPosition:UIToolbarPositionBottom barMetrics:UIBarMetricsDefault];
    //[[UISegmentedControl appearance] setBackgroundImage:[[UIImage imageNamed:@"btn-normal.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)]  forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    //[[UISegmentedControl appearance] setBackgroundImage:[[UIImage imageNamed:@"btn-pressed.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)] forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    
    //[[UISegmentedControl appearance] setDividerImage:[UIImage imageNamed:@"btn-segmented-divider.png"] forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
	////    [[UIView appearance] setBackgroundColor:tableBgColor];
	////    [[UIView appearanceWhenContainedIn:[UIViewController class], nil] setBackgroundColor:tableBgColor];
	//    
    if (![fm fileExistsAtPath:pathSQLCore]) {
        NSString *defaultSQLPath = [[NSBundle mainBundle] pathForResource:@"coredata" ofType:@"sqlite"];
        if (defaultSQLPath) {
            [fm copyItemAtPath:defaultSQLPath toPath:pathSQLCore error:NULL];
        }
    }
    //[self showwithMainView];
	
	if ([userDefaults boolForKey:@"didLogin"]){
        
        if ([userDefaults integerForKey:@"VersionReLogin"] == VersionReLogin) {
            //[self showWithLoginView];
			
        }
        else{
            [fm removeItemAtPath:pathUserPlist error:nil];
            [fm removeItemAtPath:pathSQLCore error:nil];
            NSString *defaultSQLPath = [[NSBundle mainBundle] pathForResource:@"coredata" ofType:@"sqlite"];
            if (defaultSQLPath) {
                [fm copyItemAtPath:defaultSQLPath toPath:pathSQLCore error:NULL];
            }
            //[self showWithLoginView];
			
        }
        
	}
    else {
        //[self showWithLoginView];
    }
    
	//    self.globalTester = [Reachability reachabilityWithHostName: @"www.apple.com"];
	//    self.globalTester.key = @"global";
	//	[self.globalTester startNotifier];
	//	
	//    self.freeTester = [Reachability reachabilityWithHostName:@"renren.com"];
	//    self.freeTester.key = @"free";
	//    [self.freeTester startNotifier];
    
    self.internetTester = [Reachability reachabilityForInternetConnection];
    self.internetTester.key = @"internet";
	[self.internetTester startNotifier];
    
    self.wifiTester = [Reachability reachabilityForLocalWiFi];
    self.wifiTester.key = @"wifi";
	[self.wifiTester startNotifier];
	//    
	//    self.localTester = [Reachability reachabilityWithHostName:@"its.pku.edu.cn"];
	//    self.localTester.key = @"local";
	//    [self.localTester startNotifier];
	//    
    // Override point for customization after application launch.
	//    [self generateCoreDataBase];
    [self.window makeKeyAndVisible];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(netStatusDidChanged:) name:kReachabilityChangedNotification object:nil];
    
    [self checkVersion];
    */return YES;
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
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
