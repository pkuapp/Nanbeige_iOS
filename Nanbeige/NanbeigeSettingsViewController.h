//
//  NanbeigeSettingsViewController.h
//  Nanbeige
//
//  Created by Wang Zhongyu on 12-7-9.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WBEngine.h"

@interface NanbeigeSettingsViewController : UITableViewController <WBEngineDelegate> {
	
    WBEngine *weiBoEngine;
    UIActivityIndicatorView *indicatorView;
	
}

@property (nonatomic, retain) WBEngine *weiBoEngine;

@end
