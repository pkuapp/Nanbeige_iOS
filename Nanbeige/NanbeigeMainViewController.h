//
//  NanbeigeMainViewController.h
//  Nanbeige
//
//  Created by Wang Zhongyu on 12-7-7.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NanbeigeMainViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSArray * functionArray;

@end
