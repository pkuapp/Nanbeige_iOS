//
//  CPLine3Button2Cell.h
//  CP
//
//  Created by Wang Zhongyu on 12-7-13.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CPItsWidgetDelegateProtocol <NSObject>

- (void)connectFree:(id)sender;
- (void)connectGlobal:(id)sender;
- (void)disconnectAll:(id)sender;
- (void)detailGateInfo:(id)sender;

@end

@interface CPLine3Button2Cell : UITableViewCell
@property (retain, nonatomic) IBOutlet UIImageView *imageView;
@property (retain, nonatomic) IBOutlet UILabel *nameLabel;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *image;
@property (weak, nonatomic) id<CPItsWidgetDelegateProtocol> delegate;

- (IBAction)connectFree:(id)sender;
- (IBAction)connectGlobal:(id)sender;
- (IBAction)disconnectAll:(id)sender;
- (IBAction)detailGateInfo:(id)sender;
@property (retain, nonatomic) IBOutlet UILabel *statusLabel;
@property (retain, nonatomic) IBOutlet UILabel *detailStatusLabel;
@property (retain, nonatomic) IBOutlet UIButton *statusBackground;

@end
