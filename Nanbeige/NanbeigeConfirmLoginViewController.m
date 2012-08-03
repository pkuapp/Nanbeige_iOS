//
//  NanbeigeConfirmLoginViewController.m
//  Nanbeige
//
//  Created by ZongZiWang on 12-8-1.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import "NanbeigeConfirmLoginViewController.h"
#import "NanbeigeAccountManager.h"
#import "Environment.h"

@interface NanbeigeConfirmLoginViewController () <AccountManagerDelegate> {
	NanbeigeAccountManager *accountManager;
	NSMutableDictionary *actionSheetDict;
}

@end

@implementation NanbeigeConfirmLoginViewController

- (void)setQuickDialogTableView:(QuickDialogTableView *)aQuickDialogTableView {
    [super setQuickDialogTableView:aQuickDialogTableView];
    self.quickDialogTableView.backgroundView = nil;
    self.quickDialogTableView.backgroundColor = tableBgColor1;
    self.quickDialogTableView.bounces = YES;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self) {
		self.root = [[QRootElement alloc] initWithJSONFile:@"confirmLogin"];
	}
	return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
	    return YES;
	} else {
	    return (interfaceOrientation == UIInterfaceOrientationPortrait);
	}
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	
	accountManager = [[NanbeigeAccountManager alloc] initWithViewController:self];
	accountManager.delegate = self;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated
{
	[self refreshDisplay];
}

- (void)refreshDataSource
{
	NSString *nickname = [[NSUserDefaults standardUserDefaults] objectForKey:kACCOUNTNICKNAMEKEY];
	if (!nickname) nickname = sDEFAULTNICKNAME;
	NSString *university = [[NSUserDefaults standardUserDefaults] objectForKey:kUNIVERSITYNAMEKEY];
	if (!university) university = sDEFAULTUNIVERSITY;
	NSString *campus = [[NSUserDefaults standardUserDefaults] objectForKey:kCAMPUSNAMEKEY];
	if (campus) university = [university stringByAppendingFormat:@" %@", campus];
	
	NSMutableArray *loginaccount = [[NSMutableArray alloc] init];
	NSMutableArray *connectaccount = [[NSMutableArray alloc] init];
	
	if ([[NSUserDefaults standardUserDefaults] objectForKey:kNANBEIGEEMAILKEY])
		[loginaccount addObject:[NSDictionary dictionaryWithObjectsAndKeys:sEMAIL, @"title", [[NSUserDefaults standardUserDefaults] objectForKey:kNANBEIGEEMAILKEY], @"value", nil]];
	else
		[connectaccount addObject:[NSDictionary dictionaryWithObjectsAndKeys:sCONNECTEMAIL, @"title", @"onEmailLogin:", @"controllerAction", nil]];
	
	if ([[NSUserDefaults standardUserDefaults] objectForKey:kRENRENNAMEKEY])
		[loginaccount addObject:[NSDictionary dictionaryWithObjectsAndKeys:sRENREN, @"title", [[NSUserDefaults standardUserDefaults] objectForKey:kRENRENNAMEKEY], @"value", nil]];
	else
		[connectaccount addObject:[NSDictionary dictionaryWithObjectsAndKeys:sCONNECTRENREN, @"title", @"onRenrenLogin:", @"controllerAction", nil]];
	
	if ([[NSUserDefaults standardUserDefaults] objectForKey:kWEIBONAMEKEY])
		[loginaccount addObject:[NSDictionary dictionaryWithObjectsAndKeys:sWEIBO, @"title", [[NSUserDefaults standardUserDefaults] objectForKey:kWEIBONAMEKEY], @"value", nil]];
	else
		[connectaccount addObject:[NSDictionary dictionaryWithObjectsAndKeys:sCONNECTWEIBO, @"title", @"onWeiboLogin:", @"controllerAction", nil]];
	
	NSDictionary *dict = @{
	@"identity": @[
	@{ @"title" : sNICKNAME, @"value" : nickname } ,
	@{ @"title" : sUNIVERSITY, @"value" : university } ] ,
	@"loginaccount" : loginaccount,
	@"connectaccount" : connectaccount};
	[self.root bindToObject:dict];
	
}
- (void)refreshDisplay
{
	[self refreshDataSource];
	[self.quickDialogTableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 3)] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)onEmailLogin:(id)sender
{
	[self performSegueWithIdentifier:@"EmailLoginSegue" sender:self];
}
- (void)onWeiboLogin:(id)sender
{
	[self.quickDialogTableView deselectRowAtIndexPath:[self.quickDialogTableView indexForElement:sender] animated:YES];
	[accountManager weiboLogin];
}
- (void)didWeiboLoginWithUserID:(NSString *)user_id UserName:(NSString *)user_name WeiboToken:(NSString *)weibo_token
{
	NSLog(@"id:%@, name:%@, token:%@", user_id, user_name, weibo_token);
	[self refreshDisplay];
}
- (void)onRenrenLogin:(id)sender
{
	[self.quickDialogTableView deselectRowAtIndexPath:[self.quickDialogTableView indexForElement:sender] animated:YES];
	[accountManager renrenLogin];
}
- (void)didRenrenLoginWithUserID:(NSNumber *)user_id UserName:(NSString *)user_name RenrenToken:(NSString *)renren_token
{
	NSLog(@"id:%@, name:%@, token:%@", user_id, user_name, renren_token);
	[self refreshDisplay];
}

- (void)onConfirmLogin:(id)sender
{
	[self.quickDialogTableView deselectRowAtIndexPath:[self.quickDialogTableView indexForElement:sender] animated:YES];
	if ([[[NSUserDefaults standardUserDefaults] objectForKey:kACCOUNTEDIT] boolValue]) {
		
		[self loading:YES];
		[[[UIApplication sharedApplication] keyWindow] endEditing:YES];
		
		[accountManager emailEditWithPassword:nil Nickname:nil UniversityID:nil WeiboToken:nil];
		
	} else {
		[[NSUserDefaults standardUserDefaults] setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kNANBEIGEIDKEY] forKey:kACCOUNTIDKEY];
		[[NSUserDefaults standardUserDefaults] setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kNANBEIGENICKNAMEKEY] forKey:kACCOUNTNICKNAMEKEY];
		[self dismissModalViewControllerAnimated:YES];
	}
}

- (void)didEmailEdit {
	[self loading:NO];
	[[NSUserDefaults standardUserDefaults] setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kNANBEIGEIDKEY] forKey:kACCOUNTIDKEY];
	[[NSUserDefaults standardUserDefaults] setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kNANBEIGENICKNAMEKEY] forKey:kACCOUNTNICKNAMEKEY];
	[self dismissModalViewControllerAnimated:YES];
}

-(void)showAlert:(NSString*)message{
	[[[UIAlertView alloc] initWithTitle:nil
								message:message
							   delegate:nil
					  cancelButtonTitle:sCONFIRM
					  otherButtonTitles:nil] show];
}
- (void)requestError:(NSString *)errorString
{
	[self loading:NO];
	[self showAlert:errorString];
}

@end
