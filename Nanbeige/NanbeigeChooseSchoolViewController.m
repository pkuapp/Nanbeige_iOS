//
//  NanbeigeChooseSchoolViewController.m
//  Nanbeige
//
//  Created by ZongZiWang on 12-8-1.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import "NanbeigeChooseSchoolViewController.h"
#import "Environment.h"
#import "NanbeigeAccountManager.h"
#import "NanbeigeChooseCampusViewController.h"

@interface NanbeigeChooseSchoolViewController () <AccountManagerDelegate> {
	NSDictionary *dict;
	NanbeigeAccountManager *accountManager;
	NSDictionary *university;
}

@end

@implementation NanbeigeChooseSchoolViewController

#pragma mark - Setter and Getter Methods

- (void)setQuickDialogTableView:(QuickDialogTableView *)aQuickDialogTableView {
    [super setQuickDialogTableView:aQuickDialogTableView];
    self.quickDialogTableView.backgroundView = nil;
    self.quickDialogTableView.backgroundColor = tableBgColor1;
}

#pragma mark - View Lifecycle

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
	
	accountManager = [[NanbeigeAccountManager alloc] initWithViewController:self];
	accountManager.delegate = self;
	[accountManager requestUniversities];
	
	university = nil;
	
	[self loading:YES];
}


- (void)didUniversitiesReceived:(NSArray *)universities
{
	[self loading:NO];
	
	dict = @{@"university":universities};
	[self.root bindToObject:dict];
    [self.quickDialogTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationBottom];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	if ([[NSUserDefaults standardUserDefaults] objectForKey:kACCOUNTIDKEY] && university) {
		[self.navigationController popViewControllerAnimated:YES];
	}
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"ChooseCampusSegue"]) {
		NanbeigeChooseCampusViewController *chooseCampusVC = segue.destinationViewController;
		chooseCampusVC.university = university;
	}
}

#pragma mark - Display

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
	    return YES;
	} else {
	    return (interfaceOrientation == UIInterfaceOrientationPortrait);
	}
}

-(void)showAlert:(NSString*)message{
	[[[UIAlertView alloc] initWithTitle:nil
								message:message
							   delegate:nil
					  cancelButtonTitle:sCONFIRM
					  otherButtonTitles:nil] show];
}

#pragma mark - Button controllerAction

- (void)onChooseSchool:(id)sender
{
	NSUInteger index = [[[sender parentSection] elements] indexOfObject:sender];
	NSNumber *universityid = [[[dict objectForKey:@"university"] objectAtIndex:index] objectForKey:kAPIID];
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:[universityid intValue]] forKey:kUNIVERSITYIDKEY];
	[[NSUserDefaults standardUserDefaults] setObject:[[[dict objectForKey:@"university"] objectAtIndex:index] objectForKey:kAPINAME] forKey:kUNIVERSITYNAMEKEY];
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:kCAMPUSIDKEY];
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:kCAMPUSNAMEKEY];
	
	university = [[dict objectForKey:@"university"] objectAtIndex:index];
	if ([[university objectForKey:kAPICAMPUSES] count] == 1) {
		
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:kACCOUNTEDIT];
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:kACCOUNTEDITCAMPUS_ID];
		
		NSNumber *campus_id = [[[university objectForKey:kAPICAMPUSES] objectAtIndex:0] objectForKey:kAPIID];
		[[NSUserDefaults standardUserDefaults] setObject:campus_id forKey:kCAMPUSIDKEY];
		
		if ([[NSUserDefaults standardUserDefaults] objectForKey:kACCOUNTIDKEY]) {
			[self.navigationController popViewControllerAnimated:YES];
		} else {
			[self performSegueWithIdentifier:@"ConfirmLoginSegue" sender:self];
		}
	} else {
		[self performSegueWithIdentifier:@"ChooseCampusSegue" sender:self];
	}
}

#pragma mark - AccountManagerDelegate Error

- (void)didRequest:(ASIHTTPRequest *)request FailWithError:(NSString *)errorString
{
	[self loading:NO];
	[self showAlert:errorString];
}

@end
