//
//  CPTabBarController.m
//  nbg_iOS
//
//  Created by ZongZiWang on 12-8-16.
//  Copyright (c) 2012年 wuhaotian. All rights reserved.
//

#import "CPTabBarController.h"
#import <QuartzCore/QuartzCore.h>

@interface CPTabBarController ()

@end

@implementation CPTabBarController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	
//	UIImage *shadowImg = [UIImage imageNamed:@"TabBar-shadow"];
//	CGFloat tabBarTop = self.tabBar.frame.origin.y - shadowImg.size.height;
//	CALayer *shadowLayer = [CALayer layer];
//	shadowLayer.frame = CGRectMake(0, tabBarTop, self.view.frame.size.width, shadowImg.size.height);
//	shadowLayer.contents = (id)shadowImg.CGImage;
//	shadowLayer.zPosition = 1;
//	[self.view.layer addSublayer:shadowLayer];
	
	[self setSelectedIndex:1];
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
