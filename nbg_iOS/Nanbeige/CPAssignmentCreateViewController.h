//
//  CPCreateAssignmentViewController.h
//  CP
//
//  Created by Wang Zhongyu on 12-7-21.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Models+addon.h"

@interface CPAssignmentCreateViewController : QuickDialogController <UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) CouchDatabase *localDatabase;
@property (strong, nonatomic) Assignment *assignment;
@property (strong, nonatomic) Course *course;
@property (strong, nonatomic) NSArray *weeksData;
@property (strong, nonatomic) NSArray *coursesData;

@property (strong, nonatomic) NSNumber *courseIdFilter;
@property (nonatomic) BOOL bCreate;
@property (nonatomic) BOOL bInitWithCamera;

@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIImage *image;
@property (assign, nonatomic) CGRect imageFrame;
@property (assign, nonatomic) BOOL imagePickerUsed;
@property (copy, nonatomic) NSString *lastChosenMediaType;

@end