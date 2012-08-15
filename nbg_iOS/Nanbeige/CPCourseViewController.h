//
//  CPCourseViewController.h
//  nbg_iOS
//
//  Created by ZongZiWang on 12-8-16.
//  Copyright (c) 2012年 wuhaotian. All rights reserved.
//

#import "QuickDialogController.h"
#import "Models+addon.h"
#import "EGORefreshTableHeaderView.h"

@interface CPCourseViewController : QuickDialogController<UITableViewDelegate, UITableViewDataSource, EGORefreshTableHeaderDelegate> {
	EGORefreshTableHeaderView *_refreshHeaderView;
	//  Reloading var should really be your tableviews datasource
	//  Putting it here for demo purposes
	BOOL _reloading;
}

@property (nonatomic, strong) Course *course;
@property (nonatomic, strong) NSMutableArray *assignments;
@property (nonatomic, strong) NSMutableArray *comments;

@end
