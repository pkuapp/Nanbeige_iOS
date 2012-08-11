//
//  CPAssignmentManager.h
//  CP
//
//  Created by ZongZiWang on 12-8-9.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"

@protocol CPAssignmentManagerDelegate <NSObject>
@optional

- (void)didRequest:(ASIHTTPRequest *)request FailWithError:(NSString *)errorString;
- (void)didRequest:(ASIHTTPRequest *)request FailWithErrorCode:(NSString *)errorCode;

- (void)didAssignmentsReceived:(NSArray *)assignments;
- (void)didAssignmentFinishedWithID:(NSNumber *)assignment_id;
- (void)didAssignmentUnfinishedWithID:(NSNumber *)assignment_id;
- (void)didAssignmentDeletedWithID:(NSNumber *)assignment_id;
- (void)didAssignmentModifiedWithID:(NSNumber *)assignment_id;
- (void)didAssignmentAdded:(NSNumber *)assignment_id;

@end

@interface CPAssignmentManager : NSObject
@property (strong, nonatomic) id<CPAssignmentManagerDelegate> delegate;

- (void)requestAssignments;
- (void)finishAssignmentWithID:(NSNumber *)assignment_id
					  Finished:(NSNumber *)finished;
- (void)deleteAssignmentWithID:(NSNumber *)assignment_id;
- (void)modifyAssignmentWithID:(NSNumber *)assignment_id
					 Course_ID:(NSNumber *)course_id
					   DueTime:(NSDate *)due
					   Content:(NSString *)content
					  Finished:(NSNumber *)finished;
- (void)addAssignmentWithCourse_ID:(NSNumber *)course_id
						   DueTime:(NSDate *)due
						   Content:(NSString *)content;

@end
