//
//  NanbeigeStreamViewController.h
//  Nanbeige
//
//  Created by Wang Zhongyu on 12-7-9.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WBSendView.h"

@interface NanbeigeStreamViewController : UITableViewController <WBEngineDelegate, WBSendViewDelegate> {
	WBEngine *engine;
	UIActivityIndicatorView *indicatorView;
}
- (IBAction)onSendButtonPressed:(id)sender;

@end
