//
//  CPAssignmentDeadlineViewController.h
//  CP
//
//  Created by Wang Zhongyu on 12-7-22.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CPAssignmentDeadlineViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource>

@property (weak, nonatomic) IBOutlet UISegmentedControl *modeSegmentedControl;
@property (weak, nonatomic) IBOutlet UILabel *modeLabel;

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UIPickerView *deadlinePicker;

@property (weak, nonatomic) NSMutableDictionary *assignment;
@property (weak, nonatomic) NSArray *coursesData;
@property (weak, nonatomic) NSArray *weeksData;

- (IBAction)onModeChange:(UISegmentedControl *)sender;
- (IBAction)onConfirm:(id)sender;

@end
