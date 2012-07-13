//
//  AppUserDelegateProtocol.h
//  iOSOne
//
//  Created by  on 11-10-6.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class AppUser;

@protocol AppUserDelegateProtocol <NSObject>
@property(nonatomic, retain, readonly) AppUser *appUser;
- (BOOL)authUserForAppWithItsID:(NSString *)itsid itsPassword:(NSString *)itspassword sessionID:(NSString *)sid error:(NSString **)stringError;
- (BOOL)authUserForAppWithCoursesID:(NSString *)coursesid coursesPassword:(NSString *)coursespassword coursesCode:(NSString *)coursescode sessionID:(NSString *)sid error:(NSString **)stringError;
- (BOOL)refreshAppSession;
- (void)updateAppUserProfile;
- (void)updateServerCourses;
- (void)logout;
@end
