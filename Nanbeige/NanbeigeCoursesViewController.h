//
//  NanbeigeCoursesViewController.h
//  Nanbeige
//
//  Created by ZongZiWang on 12-8-8.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SYPaginatorView.h"

@interface NanbeigeCoursesViewController : UIViewController <SYPaginatorViewDataSource, SYPaginatorViewDelegate>

@property (nonatomic, strong) SYPaginatorView *paginatorView;

@end
