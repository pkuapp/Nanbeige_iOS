//
//  CPRenrenPostViewController.h
//  CP
//
//  Created by Wang Zhongyu on 12-7-10.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Renren.h"

@interface CPRenrenPostViewController : UIViewController <RenrenDelegate> {
	Renren * renren;
    BOOL _isKeyboardHidden;
	UIActivityIndicatorView *indicatorView;
}

- (IBAction)onPostButtonPressed:(id)sender;
- (IBAction)onCancelButtonPressed:(id)sender;
@property (retain, nonatomic) IBOutlet UITextView *textToPost;

@end
