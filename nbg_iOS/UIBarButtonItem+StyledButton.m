//
//  StyledButton+UIBarButtonItem.m
//  nbg_iOS
//
//  Created by wuhaotian on 12-9-8.
//  Copyright (c) 2012年 wuhaotian. All rights reserved.
//

#import "UIBarButtonItem+StyledButton.h"

typedef enum{
    CPBarButtonItemTypePlain = 0,
    CPBarButtonItemTypeBack = 1,
    CPBarButtonItemTypeDefault = 2,
    CPBarButtonItemTypeRed = 3,
} CPBarButtonType;

@implementation UIBarButtonItem (StyledButton)


+ (UIBarButtonItem *)styledBackBarButtonItemWithTitle:(NSString*)title target:(id)target selector:(SEL)selector type:(CPBarButtonType)type {
    UIFont *font = [UIFont boldSystemFontOfSize:13.0f];
    CGSize textSize = [title sizeWithFont:font];
    CGSize buttonSize;
    UIImage *image;
    UIImage *pressed_image;
    UIColor *fontColor = [UIColor whiteColor];
    UIColor *shadowColor = [UIColor colorWithWhite:0 alpha:0.4];
    CGSize shadowSize = CGSizeMake(0, -1);

    switch (type) {
        case CPBarButtonItemTypePlain:
            image = [[UIImage imageNamed:@"btn"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 7, 0, 7)];
            pressed_image = [[UIImage imageNamed:@"btn-pressed"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 9, 0, 9)];
            fontColor = [UIColor colorWithWhite:0.2 alpha:1];
            shadowColor = [UIColor colorWithWhite:1 alpha:0.5];
            shadowSize = CGSizeMake(0, 1);
            buttonSize = CGSizeMake(textSize.width + 14, image.size.height);
            break;
        case CPBarButtonItemTypeBack:
            image = [[UIImage imageNamed:@"btn-back"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 17, 0, 7)];
            pressed_image = [[UIImage imageNamed:@"btn-pressed-back"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 19, 0, 9)];
            fontColor = [UIColor colorWithWhite:0.2 alpha:1];
            shadowColor = [UIColor colorWithWhite:1 alpha:0.5];
            shadowSize = CGSizeMake(0, 1);
            buttonSize = CGSizeMake(textSize.width + 20, image.size.height);
            break;
        case CPBarButtonItemTypeDefault:
            image = [[UIImage imageNamed:@"btn-default"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 7, 0, 7)];
            pressed_image = [[UIImage imageNamed:@"btn-pressed-default"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 9, 0, 9)];
            buttonSize = CGSizeMake(textSize.width + 14, image.size.height);
            break;
        case CPBarButtonItemTypeRed:
            image = [[UIImage imageNamed:@"btn-now"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 7, 0, 7)];
            pressed_image = [[UIImage imageNamed:@"btn-pressed-now"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 9, 0, 9)];
            buttonSize = CGSizeMake(textSize.width + 14, image.size.height);
            break;
        default:
            break;
    }
    CGFloat marginRight = 7.0f;
    buttonSize.width = buttonSize.width >= 48? buttonSize.width : (marginRight = 11.0f ,48);
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, buttonSize.width, buttonSize.height)];
    
    CGFloat marginLeft = button.frame.size.width - textSize.width - marginRight;

    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    [button setBackgroundImage:image forState:UIControlStateNormal];
    [button setBackgroundImage:pressed_image forState:UIControlStateHighlighted];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:fontColor forState:UIControlStateNormal];
    [button setTitleShadowColor:shadowColor forState:UIControlStateNormal];
    button.titleLabel.font = font;
    button.titleLabel.shadowOffset = shadowSize;
        [button setTitleEdgeInsets:UIEdgeInsetsMake(7, marginLeft, 9, marginRight)];
    return [[UIBarButtonItem alloc] initWithCustomView:button];
}


+ (UIBarButtonItem *)styledBackBarButtonItemWithTitle:(NSString*)title target:(id)target selector:(SEL)selector
{
    return [self styledBackBarButtonItemWithTitle:title target:target selector:selector type:CPBarButtonItemTypeBack];
}

+ (UIBarButtonItem *)styledRedBarButtonItemWithTitle:(NSString*)title target:(id)target selector:(SEL)selector
{
    return [self styledBackBarButtonItemWithTitle:title target:target selector:selector type:CPBarButtonItemTypeRed];

}

+ (UIBarButtonItem *)styledPlainBarButtonItemWithTitle:(NSString *)title target:(id)target selector:(SEL)selector
{
    return [self styledBackBarButtonItemWithTitle:title target:target selector:selector type:CPBarButtonItemTypePlain];

}
+ (UIBarButtonItem *)styledBlueBarButtonItemWithTitle:(NSString *)title target:(id)target selector:(SEL)selector
{
    return [self styledBackBarButtonItemWithTitle:title target:target selector:selector type:CPBarButtonItemTypeDefault];

}
@end