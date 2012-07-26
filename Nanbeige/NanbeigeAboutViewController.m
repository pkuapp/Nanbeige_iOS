//
//  NanbeigeAboutViewController.m
//  Nanbeige
//
//  Created by Wang Zhongyu on 12-7-27.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import "NanbeigeAboutViewController.h"
#import "Environment.h"

@interface NanbeigeAboutViewController ()

@end

@implementation NanbeigeAboutViewController

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
	self.title = TITLE_ABOUT;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
	    return YES;
	} else {
	    return (interfaceOrientation == UIInterfaceOrientationPortrait);
	}
}

@end
