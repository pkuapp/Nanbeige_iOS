//
//  CPAssignmentCourseViewController.h
//  nbg_iOS
//
//  Created by ZongZiWang on 12-8-13.
//  Copyright (c) 2012年 wuhaotian. All rights reserved.
//

#import "QuickDialogController.h"

@class Assignment;

@interface CPAssignmentCourseViewController : QuickDialogController

@property (weak, nonatomic) Assignment *assignment;
@property (weak, nonatomic) NSArray *coursesData;

@end
