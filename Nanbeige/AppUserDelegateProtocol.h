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
- (BOOL)refreshAppSession;
- (void)updateAppUserProfile;
- (void)updateServerCourses;

- (void)logout;
- (BOOL)authUserForAppWithItsID:(NSString *)itsid itsPassword:(NSString *)itspassword sessionID:(NSString *)sid error:(NSString **)stringError;
- (BOOL)authUserForAppWithCoursesID:(NSString *)coursesid coursesPassword:(NSString *)coursespassword coursesCode:(NSString *)coursescode sessionID:(NSString *)sid error:(NSString **)stringError;
- (BOOL)authUserForAppWithRenrenID:(NSString *)renrenid renrenName:(NSString *)renrenname error:(NSString **)stringError;
- (BOOL)authUserForAppWithWeiboID:(NSString *)weiboid weiboName:(NSString *)weiboname error:(NSString **)stringError;
-(BOOL)updateDefaultMainFunctionOrder:(NSMutableArray *)newFunctionOrder error:(NSString **)stringError;
-(NSArray *)defaultMainFunctionOrder;

@end
