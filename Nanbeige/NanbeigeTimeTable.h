//
//  NanbeigeTimeTable.h
//  Nanbeige
//
//  Created by ZongZiWang on 12-8-8.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import "SYPageView.h"

@interface NanbeigeTimeTable : SYPageView

@property (strong, nonatomic) UITableView *timeTable;
@property (strong, nonatomic) NSDate *date;
@property (strong, nonatomic) NSDictionary *university;
@property (strong, nonatomic) NSArray *courses;

@end
