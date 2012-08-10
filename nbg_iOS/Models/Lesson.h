//
//  Lesson.h
//  nbg_iOS
//
//  Created by wuhaotian on 12-8-10.
//  Copyright (c) 2012年 wuhaotian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Course;

@interface Lesson : NSManagedObject

@property (nonatomic, retain) NSNumber * day;
@property (nonatomic, retain) NSNumber * end;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSNumber * start;
@property (nonatomic, retain) id weeks;
@property (nonatomic, retain) Course *course;

@end
