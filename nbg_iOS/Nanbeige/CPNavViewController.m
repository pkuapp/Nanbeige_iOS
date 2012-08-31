//
//  CPNavViewController.m
//  nbg_iOS
//
//  Created by ZongZiWang on 12-8-30.
//  Copyright (c) 2012年 wuhaotian. All rights reserved.
//

#import "CPNavViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface CPNavViewController ()

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

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	
	CGFloat navigationBarBottom = self.navigationBar.frame.origin.y + self.navigationBar.frame.size.height;
	UIImage *shadowImg = [UIImage imageNamed:@"NavigationBar-shadow"];
	CALayer *shadowLayer = [CALayer layer];
	shadowLayer.frame = CGRectMake(0, navigationBarBottom, self.view.frame.size.width, shadowImg.size.height);
	shadowLayer.contents = (id)shadowImg.CGImage;
	shadowLayer.zPosition = 1;
	[self.view.layer addSublayer:shadowLayer];
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
