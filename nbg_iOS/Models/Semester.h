//
//  Semester.h
//  nbg_iOS
//
//  Created by ZongZiWang on 12-8-15.
//  Copyright (c) 2012年 wuhaotian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class University, Course;

@interface Semester : CouchModel

@property (nonatomic, retain) NSString * doc_type;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * year;
@property (nonatomic, retain) NSDate * week_end;
@property (nonatomic, retain) NSDate * week_start;

@property (nonatomic, assign) University * university;
@property (nonatomic, retain) NSArray * courses;

@end
