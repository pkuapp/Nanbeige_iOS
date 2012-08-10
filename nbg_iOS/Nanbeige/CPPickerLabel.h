//
//  NanbeigePickerLabel.h
//  Nanbeige
//
//  Created by Wang Zhongyu on 12-7-25.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CPAssignmentCreateViewController.h"

@interface CPPickerLabel : UILabel <UIKeyInput, UIPopoverControllerDelegate>

@property (strong, nonatomic) UIView *inputView;
@property (strong, nonatomic) UIView *inputAccessoryView;
@property (strong, nonatomic) UIPopoverController *popoverController;
@property (weak, nonatomic) id delegate;

@end
