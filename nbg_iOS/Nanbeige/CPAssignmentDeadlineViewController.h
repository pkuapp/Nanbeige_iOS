//
//  CPAssignmentDeadlineViewController.h
//  CP
//
//  Created by Wang Zhongyu on 12-7-22.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Assignment;

@interface CPAssignmentDeadlineViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource>

@property (weak, nonatomic) IBOutlet UISegmentedControl *modeSegmentedControl;
@property (weak, nonatomic) IBOutlet UILabel *modeLabel;

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UIPickerView *deadlinePicker;

@property (weak, nonatomic) Assignment *assignment;
@property (weak, nonatomic) NSArray *coursesData;
@property (weak, nonatomic) NSArray *weeksData;

- (IBAction)onModeChange:(UISegmentedControl *)sender;

+ (NSString *)displayFromWeekDay:(NSDictionary *)weekDay;
+ (NSString *)displayFromDate:(NSDate *)date;

@end
