//
//  NanbeigeAccountManageViewController.h
//  Nanbeige
//
//  Created by ZongZiWang on 12-8-2.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import "QuickDialogController.h"
#import "Renren.h"
#import "WBEngine.h"

@interface NanbeigeAccountManageViewController : QuickDialogController <UIActionSheetDelegate, WBEngineDelegate, RenrenDelegate>

@property (strong, nonatomic) WBEngine *weiBoEngine;
@property (strong, nonatomic) Renren *renrenEngine;

@end
