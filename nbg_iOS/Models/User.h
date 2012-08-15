//
//  User.h
//  nbg_iOS
//
//  Created by ZongZiWang on 12-8-15.
//  Copyright (c) 2012年 wuhaotian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Assignment, Course, Lesson, University;

@interface User : NSManagedObject

@property (nonatomic, retain) NSNumber * campus_id;
@property (nonatomic, retain) NSString * campus_name;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * nickname;
@property (nonatomic, retain) NSString * realname;
@property (nonatomic, retain) NSString * renren_name;
@property (nonatomic, retain) NSString * renren_token;
@property (nonatomic, retain) NSNumber * university_id;
@property (nonatomic, retain) NSString * university_name;
@property (nonatomic, retain) NSString * weibo_name;
@property (nonatomic, retain) NSString * weibo_token;
@property (nonatomic, retain) NSSet *courses;
@property (nonatomic, retain) NSSet *lessons;
@property (nonatomic, retain) University *university;
@property (nonatomic, retain) NSSet *assignments;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)addCoursesObject:(Course *)value;
- (void)removeCoursesObject:(Course *)value;
- (void)addCourses:(NSSet *)values;
- (void)removeCourses:(NSSet *)values;

- (void)addLessonsObject:(Lesson *)value;
- (void)removeLessonsObject:(Lesson *)value;
- (void)addLessons:(NSSet *)values;
- (void)removeLessons:(NSSet *)values;

- (void)addAssignmentsObject:(Assignment *)value;
- (void)removeAssignmentsObject:(Assignment *)value;
- (void)addAssignments:(NSSet *)values;
- (void)removeAssignments:(NSSet *)values;

@end
