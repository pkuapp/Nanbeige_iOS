//
//  StyledButton+UIBarButtonItem.h
//  nbg_iOS
//
//  Created by wuhaotian on 12-9-8.
//  Copyright (c) 2012年 wuhaotian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (StyledButton)
+ (UIBarButtonItem *)styledBackBarButtonItemWithTitle:(NSString *)title target:(id)target selector:(SEL)selector;
+ (UIBarButtonItem *)styledPlainBarButtonItemWithTitle:(NSString *)title target:(id)target selector:(SEL)selector;
+ (UIBarButtonItem *)styledBlueBarButtonItemWithTitle:(NSString *)title target:(id)target selector:(SEL)selector;
+ (UIBarButtonItem *)styledRedBarButtonItemWithTitle:(NSString *)title target:(id)target selector:(SEL)selector;
@end
