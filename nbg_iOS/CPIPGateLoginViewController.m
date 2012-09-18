//
//  CPIPGateLoginViewController.m
//  nbg_iOS
//
//  Created by ZongZiWang on 12-9-18.
//  Copyright (c) 2012年 wuhaotian. All rights reserved.
//

#import "CPIPGateLoginViewController.h"
#import "Models+addon.h"

@interface CPIPGateLoginViewController ()

@end

@implementation CPIPGateLoginViewController

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
		self.root = [[QRootElement alloc] initWithJSONFile:@"IPGateLogin"];
		self.resizeWhenKeyboardPresented = YES;
	}
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem styledPlainBarButtonItemWithTitle:sCANCEL target:self selector:@selector(dismissModalViewControllerAnimated:)];
	self.navigationItem.rightBarButtonItem = [UIBarButtonItem styledBlueBarButtonItemWithTitle:sCONFIRM target:self selector:@selector(onConfirm:)];
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

- (void)onConfirm:(id)sender
{
	NSMutableDictionary *IPGateInfo = [[NSMutableDictionary alloc] init];
    [self.root fetchValueUsingBindingsIntoObject:IPGateInfo];
	NSString *gate_id = [IPGateInfo objectForKey:@"gate_id"];
	NSString *gate_password = [IPGateInfo objectForKey:@"gate_password"];
	if (!gate_id) gate_id = @"";
	if (!gate_password) gate_password = @"";
	
	[User updateSharedAppUserProfile:@{ @"gate_id" : gate_id, @"gate_password" : gate_password }];
	[self dismissModalViewControllerAnimated:YES];
}

@end
