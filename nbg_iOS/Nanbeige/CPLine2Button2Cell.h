//
//  CPLine2Button2Cell.h
//  CP
//
//  Created by Wang Zhongyu on 12-7-13.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CPLine2Button2DelegateProtocol <NSObject>

- (void)onButton1Pressed:(id)sender;

@end

@interface CPLine2Button2Cell : UITableViewCell
@property (retain, nonatomic) IBOutlet UILabel *nameLabel;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *image;
@property (strong, nonatomic) id<CPLine2Button2DelegateProtocol> delegate;
- (IBAction)onButton1Pressed:(id)sender;

@end
