//
//  CPConfirmLoginViewController.h
//  CP
//
//  Created by ZongZiWang on 12-8-1.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import "QuickDialogController.h"
#import "WBEngine+addon.h"
#import "Renren+addon.h"

@interface CPSigninComfirmViewController : QuickDialogController  <WBEngineDelegate, RenrenDelegate>

@property (nonatomic, strong) WBEngine *weibo;
@property (nonatomic, strong) Renren *renren;

@end
