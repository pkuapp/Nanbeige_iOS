//
//  NanbeigeTabBarController.m
//  Nanbeige
//
//  Created by Wang Zhongyu on 12-7-27.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import "NanbeigeTabBarController.h"
#import "NanbeigeSplitViewBarButtonItemPresenter.h"
#import "Environment.h"

@interface NanbeigeTabBarController ()

@end

@implementation NanbeigeTabBarController

#pragma mark - UISplitViewControllerDelegate
- (void)awakeFromNib
{
	[super awakeFromNib];
	self.splitViewController.delegate = self;
}
- (id <NanbeigeSplitViewBarButtonItemPresenter>)splitViewBarButtonItemPresenter
{
	id detailVC = [self.splitViewController.viewControllers lastObject];
	if (![detailVC conformsToProtocol:@protocol(NanbeigeSplitViewBarButtonItemPresenter)]) {
		detailVC = nil;
	}
	return detailVC;
}
- (BOOL)splitViewController:(UISplitViewController *)svc
   shouldHideViewController:(UIViewController *)vc
			  inOrientation:(UIInterfaceOrientation)orientation
{
	return [self splitViewBarButtonItemPresenter] ? UIInterfaceOrientationIsPortrait(orientation) : NO;
}
- (void)splitViewController:(UISplitViewController *)svc
	 willHideViewController:(UIViewController *)aViewController
		  withBarButtonItem:(UIBarButtonItem *)barButtonItem
	   forPopoverController:(UIPopoverController *)pc
{
	barButtonItem.title = @"仪表盘";//[[(UINavigationController *)[self selectedViewController] topViewController] title];
	[self splitViewBarButtonItemPresenter].splitViewBarButtonItem = barButtonItem;
}
- (void)splitViewController:(UISplitViewController *)svc
	 willShowViewController:(UIViewController *)aViewController
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
	[self splitViewBarButtonItemPresenter].splitViewBarButtonItem = nil;
}

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
	[super viewDidAppear:animated];
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		if ([defaults valueForKey:kWEIBOIDKEY] == nil && 
			[defaults valueForKey:kRENRENIDKEY] == nil &&
			[defaults valueForKey:kNANBEIGEEMAILKEY] == nil) {
			NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
			[[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];;
		}
		
		if ([[NSUserDefaults standardUserDefaults] valueForKey:kACCOUNTIDKEY] == nil) {
			[self performSegueWithIdentifier:@"LoginSegue" sender:self];	
		}
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
