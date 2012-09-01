//
//  CPEventAllViewController.h
//  nbg_iOS
//
//  Created by ZongZiWang on 12-9-1.
//  Copyright (c) 2012年 wuhaotian. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EGORefreshTableHeaderView.h"

@interface CPEventAllViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, EGORefreshTableHeaderDelegate> {
	EGORefreshTableHeaderView *_refreshHeaderView;
	//  Reloading var should really be your tableviews datasource
	//  Putting it here for demo purposes
	BOOL _reloading;
}

@property (strong, nonatomic) NSMutableArray *events;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
