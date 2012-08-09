//
//  NanbeigeRoomsViewController.h
//  Nanbeige
//
//  Created by ZongZiWang on 12-8-9.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"

@interface NanbeigeRoomsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, EGORefreshTableHeaderDelegate> {
	EGORefreshTableHeaderView *_refreshHeaderView;
	//  Reloading var should really be your tableviews datasource
	//  Putting it here for demo purposes
	BOOL _reloading;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (strong, nonatomic) NSArray *buildings;
@property (strong, nonatomic) NSMutableArray *rooms;

@end
