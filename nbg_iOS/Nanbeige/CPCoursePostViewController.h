//
//  CPCoursePostViewController.h
//  nbg_iOS
//
//  Created by ZongZiWang on 12-8-30.
//  Copyright (c) 2012年 wuhaotian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WBEngine+addon.h"
#import "Renren+addon.h"

@interface CPCoursePostViewController : UIViewController <WBEngineDelegate>

@property (strong, nonatomic) NSNumber *course_id;
@property (strong, nonatomic) WBEngine *weibo;
@property (strong, nonatomic) Renren *renren;
@property (retain, nonatomic) IBOutlet UITextView *textToPost;

@end
