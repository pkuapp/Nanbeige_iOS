//
//  University.h
//  nbg_iOS
//
//  Created by ZongZiWang on 12-8-15.
//  Copyright (c) 2012年 wuhaotian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Semester, User;

@interface University : CouchModel

@property (nonatomic, retain) NSString * doc_type;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * support_import_course;
@property (nonatomic, retain) NSNumber * support_list_course;
@property (nonatomic, retain) NSNumber * support_ta;
@property (nonatomic, retain) NSNumber * lessons_count_evening;
@property (nonatomic, retain) NSNumber * lessons_count_total;
@property (nonatomic, retain) NSNumber * lessons_count_morning;
@property (nonatomic, retain) NSNumber * lessons_count_afternoon;
@property (nonatomic, retain) NSArray * lessons_detail;
@property (nonatomic, retain) NSArray * lessons_separators;
@property (nonatomic, retain) NSArray * campuses;

@property (nonatomic, retain) NSArray * semesters;

@end
