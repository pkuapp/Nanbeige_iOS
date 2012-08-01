//
//  Course.h
//  Nanbeige
//
//  Created by ZongZiWang on 12-8-1.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AppUser, Lesson;

@interface Course : NSManagedObject

@property (nonatomic, retain) NSNumber * semester_id;
@property (nonatomic, retain) NSNumber * credit;
@property (nonatomic, retain) NSNumber * courseid;
@property (nonatomic, retain) NSString * ta;
@property (nonatomic, retain) NSNumber * week;
@property (nonatomic, retain) NSString * teacher;
@property (nonatomic, retain) NSString * orig_id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *lessonset;
@property (nonatomic, retain) AppUser *appuser;
@end

@interface Course (CoreDataGeneratedAccessors)

- (void)addLessonsetObject:(Lesson *)value;
- (void)removeLessonsetObject:(Lesson *)value;
- (void)addLessonset:(NSSet *)values;
- (void)removeLessonset:(NSSet *)values;

@end
