//
//  CPChooseLoginViewController.h
//  CP
//
//  Created by ZongZiWang on 12-8-1.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import "QuickDialogController.h"
#import "WBEngine+addon.h"

@protocol WBEngineDelegate;

@interface CPSignViewController : QuickDialogController  <WBEngineDelegate>
@property (nonatomic, strong) WBEngine *weibo;
@end
