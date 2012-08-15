//
//  Lesson.h
//  nbg_iOS
//
//  Created by ZongZiWang on 12-8-14.
//  Copyright (c) 2012年 wuhaotian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Course, User;

@interface Lesson : CouchModel

@property (nonatomic, retain) NSString * doc_type;
@property (nonatomic, retain) NSNumber * day;
@property (nonatomic, retain) NSNumber * end;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSNumber * start;
@property (nonatomic, retain) NSArray * week;

@property (nonatomic, assign) Course * course;

@end
