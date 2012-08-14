//
//  Assignment.h
//  nbg_iOS
//
//  Created by ZongZiWang on 12-8-14.
//  Copyright (c) 2012年 wuhaotian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <CouchCocoa/CouchCocoa.h>


@interface Assignment : CouchModel

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * doc_type;
@property (nonatomic, retain) NSNumber * finished;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSNumber * course_id;
@property (nonatomic, retain) NSString * course_name;
@property (nonatomic, retain) NSString * due_display;
@property (nonatomic, retain) NSString * due_type;
@property (nonatomic, retain) NSDate * due_date;
@property (nonatomic, retain) NSDictionary *due_lesson;
@property (nonatomic, retain) NSNumber * has_image;
@property (nonatomic, retain) NSData * image_data;

@end
