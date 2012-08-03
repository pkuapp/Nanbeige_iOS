//
//  NanbeigeEmailLoginViewController.h
//  Nanbeige
//
//  Created by ZongZiWang on 12-8-1.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import "QuickDialogController.h"
#import "NanbeigeAccountManager.h"

@interface NanbeigeEmailLoginViewController : QuickDialogController

@property (strong, nonatomic) id<AccountManagerDelegate> accountManagerDelegate;

@end
