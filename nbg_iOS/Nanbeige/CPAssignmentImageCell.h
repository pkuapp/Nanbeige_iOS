//
//  NanbeigeAssignmentImageCell.h
//  Nanbeige
//
//  Created by Wang Zhongyu on 12-7-17.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CPAssignmentNoImageCell.h"

@interface CPAssignmentImageCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *courseName;
@property (weak, nonatomic) IBOutlet UILabel *assignmentName;
@property (weak, nonatomic) IBOutlet UIButton *assignmentImage;
@property (weak, nonatomic) IBOutlet UILabel *assignmentTime;
@property (weak, nonatomic) id<CPAssignmentCellDelegate> delegate;
@property (nonatomic) int assignmentIndex;
@property (weak, nonatomic) IBOutlet UIButton *changeCompleteButton;
- (IBAction)changeComplete:(id)sender;

@end
