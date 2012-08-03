//
//  NanbeigeAccountManager.h
//  Nanbeige
//
//  Created by ZongZiWang on 12-8-3.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol AccountManagerDelegate <NSObject>

@optional

- (void)requestError:(NSString *)errorString;

- (void)didWeiboLoginWithUserID:(NSString *)user_id
					   UserName:(NSString *)user_name
					 WeiboToken:(NSString *)weibo_token;
- (void)didWeiboLogout;

- (void)didRenrenLoginWithUserID:(NSNumber *)user_id
					   UserName:(NSString *)user_name
					 RenrenToken:(NSString *)renren_token;
- (void)didRenrenLogout;

- (void)didEmailLoginWithID:(NSNumber *)ID
			  Nickname:(NSString *)nickname
		  UniversityID:(NSNumber *)university_id
		UniversityName:(NSString *)university_name;
- (void)didEmailLogout;
- (void)didEmailEdit;
- (void)didEmailSignupWithID:(NSNumber *)ID;

- (void)didUniversitiesReceived:(NSArray *)universities;

@end

@interface NanbeigeAccountManager : NSObject

@property (strong, nonatomic) id<AccountManagerDelegate> delegate;

- (id)initWithViewController:(UIViewController *)viewController;

- (void)emailLoginWithEmail:(NSString *)email
			  Password:(NSString *)password;
- (void)emailLoginWithWeiboToken:(NSString *)weibo_token;
- (void)emailEditWithPassword:(NSString *)password
				Nickname:(NSString *)nickname
			UniversityID:(NSNumber *)university_id
			  WeiboToken:(NSString *)weibo_token;
- (void)emailLogout;
- (void)emailSignupWithEmail:(NSString *)email
					Password:(NSString *)password
					Nickname:(NSString *)nickname;

- (void)weiboLogin;
- (void)weiboLogout;
- (BOOL)isWeiboSessionValid;

- (void)renrenLogin;
- (void)renrenLogout;
- (BOOL)isRenrenSessionValid;

- (void)requestUniversities;

@end
