//
//  NanbeigeAccountManager.h
//  Nanbeige
//
//  Created by ZongZiWang on 12-8-3.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"

@protocol CPAccountManagerDelegate <NSObject>

@optional

- (void)didRequest:(ASIHTTPRequest *)request FailWithError:(NSString *)errorString;
- (void)didRequest:(ASIHTTPRequest *)request FailWithErrorCode:(NSString *)errorCode;

- (void)didWeiboLoginWithUserID:(NSString *)user_id
					   UserName:(NSString *)user_name
					 WeiboToken:(NSString *)weibo_token;
- (void)didWeiboLogout;
- (void)didWeiboSignupWithID:(NSNumber *)ID;
- (void)didWeiboHomeTimelineReceived:(NSArray *)home_timeline;

- (void)didRenrenLoginWithUserID:(NSNumber *)user_id
					   UserName:(NSString *)user_name
					 RenrenToken:(NSString *)renren_token;
- (void)didRenrenLogout;
- (void)didRenrenSignupWithID:(NSNumber *)ID;

- (void)didEmailLoginWithID:(NSNumber *)ID
				   Nickname:(NSString *)nickname
			   UniversityID:(NSNumber *)university_id
			 UniversityName:(NSString *)university_name
				   CampusID:(NSNumber *)campus_id
				 CampusName:(NSString *)campus_name;
- (void)didEmailLoginWithEmail:(NSString *)email
					WeiboToken:(NSString *)weibo_token
					 WeiboName:(NSString *)weibo_name
				   RenrenToken:(NSString *)renren_token
					RenrenName:(NSString *)renren_name
				CourseImported:(BOOL)course_imported
					FirstLogin:(BOOL)first_login;
- (void)didEmailLogout;
- (void)didEmailEdit;
- (void)didEmailSignupWithID:(NSNumber *)ID;

- (void)didUniversitiesReceived:(NSArray *)universities;
- (void)didUniversityReceived:(NSDictionary *)university
					   WithID:(NSNumber *)university_id;
- (void)didBuildingsReceived:(NSArray *)buildings
				WithCampusID:(NSNumber *)campus_id;
- (void)didRoomsReceived:(NSArray *)rooms
		  WithBuildingID:(NSNumber *)building_id;

@end

@interface CPAccountManager : NSObject

@property (strong, nonatomic) id<CPAccountManagerDelegate> delegate;

- (id)initWithViewController:(UIViewController *)viewController;

- (void)emailLoginWithEmail:(NSString *)email
			  Password:(NSString *)password;
- (void)emailLoginWithWeiboToken:(NSString *)weibo_token;
- (void)emailLoginWithRenrenToken:(NSString *)renren_token;
- (void)emailEditWithPassword:(NSString *)password
					 Nickname:(NSString *)nickname
					 CampusID:(NSNumber *)campus_id
				   WeiboToken:(NSString *)weibo_token;
- (void)emailLogout;
- (void)emailSignupWithEmail:(NSString *)email
					Password:(NSString *)password
					Nickname:(NSString *)nickname;

- (void)weiboLogin;
- (void)weiboLogout;
- (BOOL)isWeiboSessionValid;
- (void)weiboSignupWithToken:(NSString *)token
					Nickname:(NSString *)nickname;
- (void)weiboRequestHomeTimeline;

- (void)renrenLogin;
- (void)renrenLogout;
- (BOOL)isRenrenSessionValid;
- (void)renrenSignupWithToken:(NSString *)token
					 Nickname:(NSString *)nickname;

- (void)requestUniversities;
- (void)requestUniversityWithID:(NSNumber *)university_id;
- (void)requestBuildingsWithCampusID:(NSNumber *)campus_id;
- (void)requestRoomsWithBuildingID:(NSNumber *)building_id
							  Date:(NSDate *)date;

@end
