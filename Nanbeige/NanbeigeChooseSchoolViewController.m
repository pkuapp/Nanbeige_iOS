//
//  NanbeigeChooseSchoolViewController.m
//  Nanbeige
//
//  Created by ZongZiWang on 12-8-1.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import "NanbeigeChooseSchoolViewController.h"
#import "Environment.h"
#import "ASIHttpRequest.h"

@interface NanbeigeChooseSchoolViewController () {
	NSDictionary *dict;
}

@end

@implementation NanbeigeChooseSchoolViewController

- (void)setQuickDialogTableView:(QuickDialogTableView *)aQuickDialogTableView {
    [super setQuickDialogTableView:aQuickDialogTableView];
    self.quickDialogTableView.backgroundView = nil;
    self.quickDialogTableView.backgroundColor = tableBgColor1;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self) {
		self.root = [[QRootElement alloc] initWithJSONFile:@"chooseSchool"];
	}
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"欢迎" style:UIBarButtonItemStyleBordered target:nil action:nil];
	
	ASIHTTPRequest *universityRequest = [[ASIHTTPRequest alloc] initWithURL:urlAPIUniversity];
	
	[universityRequest setDelegate:self];
	[universityRequest setTimeOutSeconds:DEFAULT_TIMEOUT];
	[universityRequest startAsynchronous];
	
	[self loading:YES];
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

- (void)onChooseSchool:(id)sender
{
	NSUInteger index = [[[sender parentSection] elements] indexOfObject:sender];
	int universityid = [[[[dict objectForKey:@"university"] objectAtIndex:index] objectForKey:kAPIID] intValue];
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:universityid] forKey:kUNIVERSITYIDKEY];
	[[NSUserDefaults standardUserDefaults] setObject:[[[dict objectForKey:@"university"] objectAtIndex:index] objectForKey:kAPINAME] forKey:kUNIVERSITYNAMEKEY];
	
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:kACCOUNTEDIT];
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:kACCOUNTEDITUNIVERSITY_ID];
	[self performSegueWithIdentifier:@"ConfirmLoginSegue" sender:self];
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
	
	dict = @{@"university":res};
	[self.root bindToObject:dict];
    [self.quickDialogTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationBottom];
}
- (void)requestFailed:(ASIHTTPRequest *)request
{
	[self loading:NO];
	
	NSError *error = [request error];
	NSLog(@"%@", error);
	[self showAlert:[error description]];
}

@end
