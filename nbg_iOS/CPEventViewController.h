//
//  CPEventViewController.h
//  nbg_iOS
//
//  Created by ZongZiWang on 12-9-1.
//  Copyright (c) 2012年 wuhaotian. All rights reserved.
//

#import "QuickDialogController.h"
#import "Models+addon.h"
#import "EGORefreshTableHeaderView.h"
#import "CPQTableDelegate.h"

@interface CPEventViewController : QuickDialogController<UITableViewDelegate, UITableViewDataSource, EGORefreshTableHeaderDelegate> {
	EGORefreshTableHeaderView *_refreshHeaderView;
	//  Reloading var should really be your tableviews datasource
	//  Putting it here for demo purposes
	BOOL _reloading;
}

@property (nonatomic, strong) CPQTableDelegate *qTableDelegate;
@property (nonatomic, strong) Event *event;
@property (nonatomic, strong) NSMutableArray *comments;

@end
