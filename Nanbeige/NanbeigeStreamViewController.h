//
//  NanbeigeStreamViewController.h
//  Nanbeige
//
//  Created by Wang Zhongyu on 12-7-9.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Renren.h"
#import "WBSendView.h"

@interface NanbeigeStreamViewController : UITableViewController <WBEngineDelegate, WBSendViewDelegate, RenrenDelegate> {
	WBEngine *engine;
	Renren *renren;
	UIActivityIndicatorView *indicatorView;
}
- (IBAction)onSendButtonPressed:(id)sender;
- (IBAction)onRenrenSendButtonPressed:(id)sender;

@end
