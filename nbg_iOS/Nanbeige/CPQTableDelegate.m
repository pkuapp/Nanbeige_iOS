//
//  CPQTableDelegate.m
//  nbg_iOS
//
//  Created by ZongZiWang on 12-8-30.
//  Copyright (c) 2012年 wuhaotian. All rights reserved.
//

#import "CPQTableDelegate.h"

@implementation CPQTableDelegate

- (id<UITableViewDelegate,UIScrollViewDelegate>)initForTableView:(QuickDialogTableView *)tableView
scrollViewDelegate:(id<UIScrollViewDelegate>)scrollViewDelegate
{
	if (self = [super initForTableView:tableView]) {
		self.scrollViewDelegate = scrollViewDelegate;
	}
	return self;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	
	if ([self.scrollViewDelegate respondsToSelector:@selector(scrollViewDidScroll:)])
		[self.scrollViewDelegate scrollViewDidScroll:scrollView];
	
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
	if ([self.scrollViewDelegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)])
		[self.scrollViewDelegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
	
}

@end
