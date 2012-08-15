//
//  Course.h
//  nbg_iOS
//
//  Created by ZongZiWang on 12-8-14.
//  Copyright (c) 2012年 wuhaotian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Lesson, Assignment, Semester, User;

@interface Course : CouchModel

@property (nonatomic, retain) NSString * doc_type;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * semester_id;
@property (nonatomic, retain) NSNumber * credit;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * orig_id;
@property (nonatomic, retain) NSArray * ta;
@property (nonatomic, retain) NSArray * teacher;

@property (nonatomic, retain) NSArray * lessons;
@property (nonatomic, retain) NSArray * assignments;
@property (nonatomic, assign) Semester * semester;

@end