//
//  Assignment.h
//  nbg_iOS
//
//  Created by wuhaotian on 12-8-10.
//  Copyright (c) 2012年 wuhaotian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Assignment : NSManagedObject

@property (nonatomic, retain) NSDate * absolute_modified;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSNumber * course_id;
@property (nonatomic, retain) NSDate * due;
@property (nonatomic, retain) NSNumber * id;

@end
