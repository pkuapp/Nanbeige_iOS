//
//  CPIPGateViewController.m
//  nbg_iOS
//
//  Created by ZongZiWang on 12-9-18.
//  Copyright (c) 2012年 wuhaotian. All rights reserved.
//

#import "CPIPGateViewController.h"
#import "Models+addon.h"
#import "Coffeepot.h"

@interface CPIPGateViewController () {
	BOOL bViewDidLoad;
}

@end

@implementation CPIPGateViewController

#pragma mark - Setter and Getter Methods

- (void)setQuickDialogTableView:(QuickDialogTableView *)aQuickDialogTableView {
    [super setQuickDialogTableView:aQuickDialogTableView];
	[self.quickDialogTableView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg-TableView"]]];
}

#pragma mark - View Lifecycle

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self) {
		self.root = [[QRootElement alloc] initWithJSONFile:@"IPGate"];
		self.resizeWhenKeyboardPresented = YES;
	}
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	NSArray *vcarray = self.navigationController.viewControllers;
    NSString *back_title = [[vcarray objectAtIndex:vcarray.count-2] title];
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem styledBackBarButtonItemWithTitle:back_title target:self.navigationController selector:@selector(popViewControllerAnimated:)];
	
	bViewDidLoad = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	if (bViewDidLoad && ([User sharedAppUser].gate_id == nil || [[User sharedAppUser].gate_id length] == 0)) {
		[self performSegueWithIdentifier:@"IPGateLoginSegue" sender:self];
		bViewDidLoad = NO;
	}
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

- (void)onConnectFree:(id)sender
{
	[[Coffeepot shared] requestIPGateWithGate_ID:[User sharedAppUser].gate_id Gate_Password:[User sharedAppUser].gate_password Range:@"2" Operation:@"connect" success:^(CPRequest *request, id collection) {
		;
	} error:^(CPRequest *request, NSError *error) {
		;
	}];
}

- (void)onChangeAccount:(id)sender
{
	[self performSegueWithIdentifier:@"IPGateLoginSegue" sender:self];
}

@end
