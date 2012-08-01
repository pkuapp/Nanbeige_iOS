//
//  AppUser.h
//  Nanbeige
//
//  Created by ZongZiWang on 12-8-1.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Course;

@interface AppUser : NSManagedObject

@property (nonatomic, retain) NSString * appuserid;
@property (nonatomic, retain) NSString * nickname;
@property (nonatomic, retain) NSSet *courseset;
@end

@interface AppUser (CoreDataGeneratedAccessors)

- (void)addCoursesetObject:(Course *)value;
- (void)removeCoursesetObject:(Course *)value;
- (void)addCourseset:(NSSet *)values;
- (void)removeCourseset:(NSSet *)values;

@end
