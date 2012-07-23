//
//  NanbeigeCreateAssignmentViewController.h
//  Nanbeige
//
//  Created by Wang Zhongyu on 12-7-21.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface NanbeigeCreateAssignmentViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate>
- (IBAction)onCancel:(id)sender;
- (IBAction)onConfirm:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *assignmentTableView;
@property (strong, nonatomic) NSMutableArray *assignments;
@property (strong, nonatomic) NSMutableDictionary *assignment;
@property (strong, nonatomic) NSArray *weeksData;
@property (strong, nonatomic) NSArray *coursesData;
@property (nonatomic) int assignmentIndex;
@property (nonatomic) BOOL initWithCamera;

@property (weak, nonatomic) IBOutlet UIPickerView *coursesPicker;
@property (weak, nonatomic) IBOutlet UIToolbar *coursesToolbar;

@property (strong, nonatomic) MPMoviePlayerController *moviePlayerController;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSURL *movieURL;
@property (copy, nonatomic) NSString *lastChosenMediaType;
@property (assign, nonatomic) CGRect imageFrame;
@property (assign, nonatomic) BOOL imagePickerUsed;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end
