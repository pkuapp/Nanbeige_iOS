//
//  User+ModelsAddon.h
//  nbg_iOS
//
//  Created by wuhaotian on 12-8-9.
//  Copyright (c) 2012年 wuhaotian. All rights reserved.
//

#import "User.h"
#import "Assignment.h"
#import "Semester.h"
#import "Course.h"
#import "Lesson.h"
#import "University.h"
#import "Weekset.h"
#import "Event.h"

@interface User (addon)

+ (User *)sharedAppUser;
+ (void)updateSharedAppUserProfile:(NSDictionary *)dict;
+ (void)deactiveSharedAppUser;

@end

@interface Course (addon)

+ (CouchDocument *)courseListDocument;
+ (Course *)courseAtIndex:(NSInteger)index
				   courseList:(NSArray *)courseList;
+ (CouchDocument *)userCourseListDocument;
+ (Course *)userCourseAtIndex:(NSInteger)index
				   courseList:(NSArray *)courseList;
+ (Course *)courseWithID:(NSNumber *)course_id;

@end

@interface Event (addon)

+ (CouchDocument *)eventListDocument;
+ (CouchDocument *)eventFollowingListDocument;
+ (Event *)eventAtIndex:(NSInteger)index
			  eventList:(NSArray *)eventList;
+ (Event *)eventWithID:(NSNumber *)event_id;

@end

@interface University (addon)

+ (University *)universityWithID:(NSNumber *)university_id;

@end

@interface Semester (addon)

+ (Semester *)semesterWithID:(NSNumber *)semester_id;
+ (Semester *)semesterAtDate:(NSDate *)date;
+ (NSInteger)weekAtDate:(NSDate *)date;
+ (NSInteger)currentWeek;
+ (NSInteger)totalWeek;

@end

@interface Weekset (addon)

+ (Weekset *)weeksetWithID:(NSNumber *)weekset_id;

@end
