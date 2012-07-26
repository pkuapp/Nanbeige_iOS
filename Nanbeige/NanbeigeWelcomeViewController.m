//
//  NanbeigeWelcomeViewController.m
//  Nanbeige
//
//  Created by Wang Zhongyu on 12-7-15.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import "NanbeigeWelcomeViewController.h"
#import "Environment.h"

@interface NanbeigeWelcomeViewController ()

@end

@implementation NanbeigeWelcomeViewController

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
}

- (void)viewDidAppear:(BOOL)animated
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	if ([defaults valueForKey:kWEIBOIDKEY] == nil && 
		[defaults valueForKey:kRENRENIDKEY] == nil &&
		[defaults valueForKey:kNANBEIGEIDKEY] == nil) {
		NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
		[[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];;
	}
	
	if ([[NSUserDefaults standardUserDefaults] valueForKey:kACCOUNTIDKEY] != nil) {
		[self performSegueWithIdentifier:@"HasLoginSegue" sender:self];
	} else {
		[self performSegueWithIdentifier:@"LoginSegue" sender:self];	
	}
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
