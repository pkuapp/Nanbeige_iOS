//
//  Course.h
//  nbg_iOS
//
//  Created by wuhaotian on 12-8-10.
//  Copyright (c) 2012年 wuhaotian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Lesson, User;

@interface Course : NSManagedObject

@property (nonatomic, retain) NSNumber * credit;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * orig_id;
@property (nonatomic, retain) NSNumber * semester_id;
@property (nonatomic, retain) id ta;
@property (nonatomic, retain) id teacher;
@property (nonatomic, retain) NSSet *lessons;
@property (nonatomic, retain) User *user;
@end

@interface Course (CoreDataGeneratedAccessors)

- (void)addLessonsObject:(Lesson *)value;
- (void)removeLessonsObject:(Lesson *)value;
- (void)addLessons:(NSSet *)values;
- (void)removeLessons:(NSSet *)values;

@end
