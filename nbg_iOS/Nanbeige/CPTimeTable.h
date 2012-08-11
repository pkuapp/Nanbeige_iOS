//
//  CPTimeTable.h
//  CP
//
//  Created by ZongZiWang on 12-8-8.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import "SYPageView.h"

@interface CPTimeTable : SYPageView

@property (strong, nonatomic) UITableView *timeTable;
@property (strong, nonatomic) NSDate *date;
@property (strong, nonatomic) NSDictionary *university;
@property (strong, nonatomic) NSArray *courses;

- (id)initWithDate:(NSDate *)date;

@end
