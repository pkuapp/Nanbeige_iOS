//
//  User.h
//  nbg_iOS
//
//  Created by wuhaotian on 12-8-10.
//  Copyright (c) 2012年 wuhaotian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Course;

@interface User : NSManagedObject

@property (nonatomic, retain) NSString * campus;
@property (nonatomic, retain) NSNumber * campus_id;
@property (nonatomic, retain) NSString * nickname;
@property (nonatomic, retain) NSString * realname;
@property (nonatomic, retain) NSString * university;
@property (nonatomic, retain) NSNumber * university_id;
@property (nonatomic, retain) NSNumber * weibo_id;
@property (nonatomic, retain) NSSet *courses;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)addCoursesObject:(Course *)value;
- (void)removeCoursesObject:(Course *)value;
- (void)addCourses:(NSSet *)values;
- (void)removeCourses:(NSSet *)values;

@end
