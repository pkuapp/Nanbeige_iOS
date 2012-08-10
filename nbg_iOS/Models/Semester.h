//
//  Semester.h
//  nbg_iOS
//
//  Created by wuhaotian on 12-8-10.
//  Copyright (c) 2012年 wuhaotian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Semester : NSManagedObject

@property (nonatomic, retain) NSNumber * university_id;
@property (nonatomic, retain) NSDate * week_end;
@property (nonatomic, retain) NSDate * week_start;

@end
