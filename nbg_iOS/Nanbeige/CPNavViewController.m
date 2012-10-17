//
//  CPNavViewController.m
//  nbg_iOS
//
//  Created by ZongZiWang on 12-8-30.
//  Copyright (c) 2012年 wuhaotian. All rights reserved.
//

#import "CPNavViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

@interface CPNavViewController (){
    CALayer *alayer;
}
@end

@implementation CPNavViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
                // Custom initialization
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        UIImage *image = [[UIImage imageNamed:@"mask-corners-top"] resizableImageWithCapInsets:UIEdgeInsetsMake(7, 7, 0, 7)];
        UIImageView *mask_view = [[UIImageView alloc] initWithImage:image];
        mask_view.frame = CGRectMake(0, 0, 320, 50);
        self.navigationBar.layer.mask = mask_view.layer;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	UIImage *shadowImg = [UIImage imageNamed:@"NavigationBar-shadow"];
	UIImageView *shadow_view = [[UIImageView alloc] initWithImage:shadowImg];
	shadow_view.frame = CGRectMake(0, 44, self.view.frame.size.width, shadowImg.size.height);
	shadow_view.layer.shadowOffset = CGSizeMake(0, 100);
	shadow_view.layer.shadowColor = [[UIColor blackColor] CGColor];
	self.navigationBar.clipsToBounds = NO;
	[self.navigationBar addSubview:shadow_view];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
