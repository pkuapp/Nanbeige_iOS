//
//  NanbeigeAssignmentNoImageCell.h
//  Nanbeige
//
//  Created by Wang Zhongyu on 12-7-17.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NanbeigeAssignmentCellDelegate <NSObject>

- (void)changeComplete:(id)sender;

@end

@interface NanbeigeAssignmentNoImageCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *assignmentName;
@property (weak, nonatomic) IBOutlet UILabel *courseName;
@property (weak, nonatomic) IBOutlet UILabel *assignmentTime;
@property (weak, nonatomic) id<NanbeigeAssignmentCellDelegate> delegate;
@property (nonatomic) int assignmentIndex;
@property (weak, nonatomic) IBOutlet UIButton *changeCompleteButton;
- (IBAction)changeComplete:(id)sender;

@end
