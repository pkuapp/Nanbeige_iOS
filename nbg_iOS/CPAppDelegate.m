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
#import "Coffeepot.h"
#import <QuartzCore/CALayer.h>

@interface CPAppDelegate ()

- (BOOL)needSignin;

@end

@implementation CPAppDelegate

- (MBProgressHUD *)progressHud
{
	if (_progressHud == nil) {
		_progressHud = [[MBProgressHUD alloc] initWithWindow:self.window];
		[self.window addSubview:_progressHud];
		_progressHud.userInteractionEnabled = NO;
		_progressHud.opacity = 0.618;
		_progressHud.animationType = MBProgressHUDAnimationZoom;
	}
	return _progressHud;
}

- (void)showProgressHud:(NSString *)title
{
	self.progressHud.mode = MBProgressHUDModeIndeterminate;
	self.progressHud.transform = CGAffineTransformIdentity;
	self.progressHud.labelText = title;
	self.progressHud.taskInProgress = YES;
	[self.progressHud show:YES];
}

- (void)hideProgressHud
{
	[self.progressHud hide:YES];
}

- (void)hideProgressHudAfterDelay:(NSTimeInterval)time
{
	[self.progressHud hide:YES afterDelay:time];
}

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
    return ![[[NSUserDefaults standardUserDefaults] objectForKey:@"CPIsSignedIn"] boolValue] || ![[User sharedAppUser].id integerValue];

}

- (void)configureGlobalAppearance {
//    [[UITableView appearance] setBackgroundColor:[UIColor colorWithRed:214.0/255 green:214.0/255 blue:214.0/255 alpha:1.0]];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
	
	UIImage *overlayImg = [UIImage imageNamed:@"corners"];
	CALayer *overlay = [CALayer layer];
	overlay.frame = CGRectMake(0, 20, overlayImg.size.width, overlayImg.size.height);
	overlay.contents = (id)overlayImg.CGImage;
	overlay.zPosition = 1;
	[self.window.layer addSublayer:overlay];
	
	[[UIBarButtonItem appearance] setBackButtonBackgroundImage:[[UIImage imageNamed:@"btn-back"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 17, 0, 7)] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:[[UIImage imageNamed:@"btn-pressed-back"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 19, 0, 9)] forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
    
    [[UIBarButtonItem appearance] setBackgroundImage:[[UIImage imageNamed:@"btn"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 7, 0, 7)] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    [[UIBarButtonItem appearance] setBackgroundImage:[[UIImage imageNamed:@"btn-pressed"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 9, 0, 9)] forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
	
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"NavigationBar"] forBarMetrics:UIBarMetricsDefault];
	
	NSDictionary *titleTextAttributes = @{ UITextAttributeTextColor : navBarTextColor1, UITextAttributeTextShadowOffset : [NSValue valueWithUIOffset:UIOffsetMake(0, 0)] };
	[[UINavigationBar appearance] setTitleTextAttributes:titleTextAttributes];
	
	[[UITabBar appearance] setBackgroundImage:[UIImage imageNamed:@"TabBar"]];
	[[UITabBar appearance] setSelectionIndicatorImage:[[UIImage imageNamed:@"TabBar-selected"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 6, 0, 6)]];
	
//	[[UITableView appearance] setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg-TableView"]]];
	
//    [[UIToolbar appearance] setBackgroundImage:[UIImage imageNamed:@"toolbar.png"] forToolbarPosition:UIToolbarPositionBottom barMetrics:UIBarMetricsDefault];
//    [[UISegmentedControl appearance] setBackgroundImage:[[UIImage imageNamed:@"btn-normal.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)]  forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
//    
//    [[UISegmentedControl appearance] setBackgroundImage:[[UIImage imageNamed:@"btn-pressed.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)] forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
//    
//    [[UISegmentedControl appearance] setDividerImage:[UIImage imageNamed:@"btn-segmented-divider.png"] forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    [MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreNamed:@"nbg_iOS"];
	
    JSObjectionInjector *injector = [JSObjection createInjector:[[CPAppModule alloc] init]];
    [JSObjection setDefaultInjector:injector];
	
	// Start the Couchbase Mobile server:
    gCouchLogLevel = 1;
#ifdef USE_REMOTE_SERVER
    self.server = [[CouchTouchDBServer alloc] initWithURL: [NSURL URLWithString: USE_REMOTE_SERVER]];
#else
    self.server = [[CouchTouchDBServer alloc] init];
#endif
    
    if (self.server.error) {
        [self showAlert: @"Couldn't start Couchbase." error: self.server.error fatal: YES];
        return YES;
    }
    
#ifdef kDefaultSyncDbURL
    // Register the default value of the pref for the remote database URL to sync with:
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *appdefaults = [NSDictionary dictionaryWithObject:kDefaultSyncDbURL
                                                            forKey:@"syncpoint"];
    [defaults registerDefaults:appdefaults];
    [defaults synchronize];
	
	NSURLCredential* cred;
	cred = [NSURLCredential credentialWithUser: kDefaultUsername
									  password: kDefaultPassword
								   persistence: NSURLCredentialPersistencePermanent];
	NSURLProtectionSpace* space;
	space = [[NSURLProtectionSpace alloc] initWithHost: kDefaultHostName
												  port: 443
											  protocol: @"https"
												 realm: @"Cloudant Private Database"
								  authenticationMethod: NSURLAuthenticationMethodDefault];
	[[NSURLCredentialStorage sharedCredentialStorage] setDefaultCredential: cred forProtectionSpace: space];
#endif
#ifdef kDatabaseName
    self.database = [self.server databaseNamed: kDatabaseName];
    self.database.tracksChanges = YES;
#if !INSTALL_CANNED_DATABASE && !defined(USE_REMOTE_SERVER)
    // Create the database on the first run of the app.
    NSError* error;
    if (![self.database ensureCreated: &error]) {
        [self showAlert: @"Couldn't create local database." error: error fatal: YES];
        return YES;
    }
#endif
#endif
	
	self.localDatabase = [self.server databaseNamed:kLocalDatabaseName];
	self.localDatabase.tracksChanges = YES;
    
#if !INSTALL_CANNED_DATABASE && !defined(USE_REMOTE_SERVER)
    // Create the database on the first run of the app.
    NSError* localError;
	if (![self.localDatabase ensureCreated: &localError]) {
        [self showAlert: @"Couldn't create local database." error: localError fatal: YES];
        return YES;
    }
#endif

    if (self.needSignin) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"CPSigninFlow" bundle:[NSBundle mainBundle]];
        UINavigationController *rvc = [sb instantiateInitialViewController];
        self.window.rootViewController = rvc;
    }
    else {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:[NSBundle mainBundle]];
        self.window.rootViewController = [sb instantiateInitialViewController];
    }
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

// Display an error alert, without blocking.
// If 'fatal' is true, the app will quit when it's pressed.
- (void)showAlert: (NSString*)message error: (NSError*)error fatal: (BOOL)fatal {
    if (error) {
        message = [NSString stringWithFormat: @"%@\n\n%@", message, error.localizedDescription];
    }
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle: (fatal ? @"Fatal Error" : @"Error")
                                                    message: message
                                                   delegate: (fatal ? self : nil)
                                          cancelButtonTitle: (fatal ? @"Quit" : @"Sorry")
                                          otherButtonTitles: nil];
    [alert show];
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
