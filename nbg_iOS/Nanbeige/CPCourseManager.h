//
//  CPCourseManager.h
//  CP
//
//  Created by ZongZiWang on 12-8-9.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"

@protocol CPCourseManagerDelegate <NSObject>
@optional

- (void)didRequest:(ASIHTTPRequest *)request FailWithError:(NSString *)errorString;
- (void)didRequest:(ASIHTTPRequest *)request FailWithErrorCode:(NSString *)errorCode;

- (void)didCoursesReceived:(NSArray *)courses;

- (void)didCourseGrabberReceived:(NSDictionary *)grabber;
- (void)didCourseGrabberCaptchaReceived:(NSData *)captchaImage;
- (void)didCourseGrabberStarted;

- (void)didCommentsReceived:(NSArray *)comments
				  WithStart:(NSNumber *)start;
- (void)didCommentsReceived:(NSArray *)comments
				  WithCourse_ID:(NSNumber *)course_id
					  Start:(NSNumber *)start;
- (void)didCommentsAddedWithCourse_ID:(NSNumber *)course_id;

@end

@interface CPCourseManager : NSObject
@property (strong, nonatomic) id<CPCourseManagerDelegate> delegate;

- (void)requestCourses;

- (void)requestCourseGrabber;
- (void)requestCourseGrabberCaptcha;
- (void)startCourseGrabberWithUsername:(NSString *)username
							  Password:(NSString *)password
							   Captcha:(NSString *)captcha;

- (void)requestCommentsWithStart:(NSNumber *)start;
- (void)requestCommentsWithCourse_ID:(NSNumber *)course_id
							   Start:(NSNumber *)start;
- (void)addCommentWithCourse_ID:(NSNumber *)course_id
						Content:(NSString *)content;

@end