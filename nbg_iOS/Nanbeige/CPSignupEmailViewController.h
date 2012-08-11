//
//  CPEmailSignupViewController.h
//  CP
//
//  Created by ZongZiWang on 12-8-1.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import "QuickDialogController.h"
#import "CPAccountManager.h"

@interface CPSignupEmailViewController : QuickDialogController

@property (strong, nonatomic) id<CPAccountManagerDelegate> accountManagerDelegate;

@end
