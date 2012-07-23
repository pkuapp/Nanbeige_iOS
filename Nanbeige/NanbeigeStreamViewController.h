//
//  NanbeigeStreamViewController.h
//  Nanbeige
//
//  Created by Wang Zhongyu on 12-7-9.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"

@interface NanbeigeStreamViewController : UITableViewController <EGORefreshTableHeaderDelegate> {
	EGORefreshTableHeaderView *_refreshHeaderView;	
	//  Reloading var should really be your tableviews datasource
	//  Putting it here for demo purposes 
	BOOL _reloading;
}
	
- (IBAction)renrenPost:(id)sender;
- (IBAction)weiboPost:(id)sender;

@end
