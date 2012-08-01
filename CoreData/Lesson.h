//
//  Lesson.h
//  Nanbeige
//
//  Created by ZongZiWang on 12-7-31.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Course;

@interface Lesson : NSManagedObject

@property (nonatomic, retain) NSNumber * start;
@property (nonatomic, retain) NSNumber * end;
@property (nonatomic, retain) NSNumber * day;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) Course *course;

@end
