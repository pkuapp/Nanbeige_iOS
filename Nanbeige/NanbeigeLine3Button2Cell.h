//
//  NanbeigeLine3Button2Cell.h
//  Nanbeige
//
//  Created by Wang Zhongyu on 12-7-13.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NanbeigeLine3Button2Cell : UITableViewCell
@property (retain, nonatomic) IBOutlet UIImageView *imageView;
@property (retain, nonatomic) IBOutlet UILabel *nameLabel;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *image;

- (IBAction)connectFree:(id)sender;
- (IBAction)connectGlobal:(id)sender;
- (IBAction)disconnectAll:(id)sender;
@property (retain, nonatomic) IBOutlet UILabel *statusLabel;
@property (retain, nonatomic) IBOutlet UILabel *detailStatusLabel;
@property (retain, nonatomic) IBOutlet UIButton *statusBackground;

@end
