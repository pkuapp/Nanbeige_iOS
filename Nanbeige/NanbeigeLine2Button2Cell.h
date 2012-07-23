//
//  NanbeigeLine2Button2Cell.h
//  Nanbeige
//
//  Created by Wang Zhongyu on 12-7-13.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NanbeigeLine2Button2DelegateProtocol <NSObject>

- (void)onButton1Pressed:(id)sender;
- (void)onButton2Pressed:(id)sender;

@end

@interface NanbeigeLine2Button2Cell : UITableViewCell
@property (retain, nonatomic) IBOutlet UIImageView *imageView;
@property (retain, nonatomic) IBOutlet UILabel *nameLabel;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *image;
@property (strong, nonatomic) id<NanbeigeLine2Button2DelegateProtocol> delegate;
- (IBAction)onButton1Pressed:(id)sender;
- (IBAction)onButton2Pressed:(id)sender;

@end
