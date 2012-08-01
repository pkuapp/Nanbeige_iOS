//
//  NanbeigeConfirmLoginViewController.m
//  Nanbeige
//
//  Created by ZongZiWang on 12-8-1.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import "NanbeigeConfirmLoginViewController.h"
#import "Environment.h"
#import "ASIFormDataRequest.h"

@interface NanbeigeConfirmLoginViewController ()

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

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated
{
	NSString *nickname = [[NSUserDefaults standardUserDefaults] objectForKey:kNANBEIGENICKNAME];
	if (!nickname) nickname = @"未命名";
	NSString *university = [[NSUserDefaults standardUserDefaults] objectForKey:kUNIVERSITYNAME];
	
	NSMutableArray *loginaccount = [[NSMutableArray alloc] init];
	NSMutableArray *connectaccount = [[NSMutableArray alloc] init];
	
	if ([[NSUserDefaults standardUserDefaults] objectForKey:kNANBEIGEEMAILKEY])
		[loginaccount addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Email", @"title", [[NSUserDefaults standardUserDefaults] objectForKey:kNANBEIGEEMAILKEY], @"value", nil]];
	else
		[connectaccount addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"连接到南北阁", @"title", nil]];
	
	if ([[NSUserDefaults standardUserDefaults] objectForKey:kRENRENNAMEKEY])
		[loginaccount addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"人人网", @"title", [[NSUserDefaults standardUserDefaults] objectForKey:kRENRENNAMEKEY], @"value", nil]];
	else
		[connectaccount addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"连接到人人网", @"title", nil]];
	
	if ([[NSUserDefaults standardUserDefaults] objectForKey:kWEIBOIDKEY])
		[loginaccount addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"新浪微博", @"title", [[NSUserDefaults standardUserDefaults] objectForKey:kWEIBOIDKEY], @"value", nil]];
	else
		[connectaccount addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"连接到新浪微博", @"title", nil]];
	
	NSDictionary *dict = @{
		@"identity": @[
			@{ @"title" : @"昵称", @"value" : nickname } ,
			@{ @"title" : @"学校", @"value" : university } ] ,
		@"loginaccount" : loginaccount,
		@"connectaccount" : connectaccount};
	[self.root bindToObject:dict];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
	    return YES;
	} else {
	    return (interfaceOrientation == UIInterfaceOrientationPortrait);
	}
}

- (void)onConfirmLogin:(id)sender
{
	if ([[[NSUserDefaults standardUserDefaults] objectForKey:kACCOUNTEDIT] boolValue]) {
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:kACCOUNTEDIT];
		
		[self loading:YES];
		[[[UIApplication sharedApplication] keyWindow] endEditing:YES];
		
		ASIFormDataRequest *editRequest = [[ASIFormDataRequest alloc] initWithURL:urlAPIUserEdit];
		[editRequest setDelegate:self];
		[editRequest setTimeOutSeconds:20];
		if ([[[NSUserDefaults standardUserDefaults] objectForKey:kACCOUNTEDITUNIVERSITY_ID] boolValue]) {
			[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:kACCOUNTEDITUNIVERSITY_ID];
			[editRequest addPostValue:[[NSUserDefaults standardUserDefaults] objectForKey:kUNIVERSITYID] forKey:kAPIUNIVERSITY_ID];
		}
		if ([[[NSUserDefaults standardUserDefaults] objectForKey:kACCOUNTEDITWEIBO_TOKEN] boolValue]) {
			[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:kACCOUNTEDITWEIBO_TOKEN];
			[editRequest addPostValue:[[NSUserDefaults standardUserDefaults] objectForKey:kWEIBOTOKENKEY] forKey:kAPIWEIBO_TOKEN];
		}
		
		[editRequest startAsynchronous];
		[[(QElement *)sender getCellForTableView:self.quickDialogTableView controller:self] setSelected:NO];
	} else {
		[[NSUserDefaults standardUserDefaults] setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kNANBEIGEIDKEY] forKey:kACCOUNTIDKEY];
		[self dismissModalViewControllerAnimated:YES];
	}
}

-(void)showAlert:(NSString*)message{
	[[[UIAlertView alloc] initWithTitle:nil
								message:message
							   delegate:nil
					  cancelButtonTitle:@"确定"
					  otherButtonTitles:nil] show];
}
- (void)requestFinished:(ASIHTTPRequest *)request
{
	[self loading:NO];
	NSData *responseData = [request responseData];
	id res = [NSJSONSerialization JSONObjectWithData:responseData
											 options:NSJSONWritingPrettyPrinted
											   error:nil];
	NSLog(@"%@", res);
	
	[[NSUserDefaults standardUserDefaults] setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kNANBEIGEIDKEY] forKey:kACCOUNTIDKEY];
	[self dismissModalViewControllerAnimated:YES];
}
- (void)requestFailed:(ASIHTTPRequest *)request
{
	[self loading:NO];
	
	NSError *error = [request error];
	NSLog(@"%@", error);
	[self showAlert:[error description]];
}
@end
