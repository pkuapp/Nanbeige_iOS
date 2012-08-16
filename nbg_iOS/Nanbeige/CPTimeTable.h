//
//  CPTimeTable.h
//  CP
//
//  Created by ZongZiWang on 12-8-8.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import "SYPageView.h"
#import "Models+addon.h"

@protocol CPTimeTableDelegate <NSObject>

@optional

- (void)didChangeIfShowTime:(BOOL)isShowTime;

@end

@interface CPTimeTable : SYPageView

@property (strong, nonatomic) id<CPTimeTableDelegate> delegate;
@property (strong, nonatomic) UITableView *timeTable;
@property (strong, nonatomic) NSDate *date;
@property (strong, nonatomic) University *university;
@property (strong, nonatomic) NSArray *courses;

- (id)initWithDate:(NSDate *)date;
- (void)refreshDisplay;

@end
