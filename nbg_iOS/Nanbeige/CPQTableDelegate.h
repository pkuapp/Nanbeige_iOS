//
//  CPQTableDelegate.h
//  nbg_iOS
//
//  Created by ZongZiWang on 12-8-30.
//  Copyright (c) 2012年 wuhaotian. All rights reserved.
//

#import "QuickDialogTableDelegate.h"
#import "QuickDialogController.h"

@interface CPQTableDelegate : QuickDialogTableDelegate <UIScrollViewDelegate>

- (id<UITableViewDelegate,UIScrollViewDelegate>)initForTableView:(QuickDialogTableView *)tableView
											  scrollViewDelegate:(id<UIScrollViewDelegate>)scrollViewDelegate;

@property (weak, nonatomic) id<UIScrollViewDelegate> scrollViewDelegate;

@end
