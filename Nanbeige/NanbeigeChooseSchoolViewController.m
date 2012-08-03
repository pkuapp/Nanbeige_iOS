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

@interface NanbeigeChooseSchoolViewController () <AccountManagerDelegate> {
	NSDictionary *dict;
	NanbeigeAccountManager *accountManager;
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
	
	accountManager = [[NanbeigeAccountManager alloc] initWithViewController:self];
	accountManager.delegate = self;
	[accountManager requestUniversities];
	
	[self loading:YES];
}
- (void)didUniversitiesReceived:(NSArray *)universities
{
	[self loading:NO];
	
	dict = @{@"university":universities};
	[self.root bindToObject:dict];
    [self.quickDialogTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationBottom];
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
	NSNumber *universityid = [[[dict objectForKey:@"university"] objectAtIndex:index] objectForKey:kAPIID];
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:[universityid intValue]] forKey:kUNIVERSITYIDKEY];
	[[NSUserDefaults standardUserDefaults] setObject:[[[dict objectForKey:@"university"] objectAtIndex:index] objectForKey:kAPINAME] forKey:kUNIVERSITYNAMEKEY];
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:kCAMPUSIDKEY];
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:kCAMPUSNAMEKEY];
	
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:kACCOUNTEDIT];
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:kACCOUNTEDITUNIVERSITY_ID];
	
	[accountManager requestUniversitie:[[[dict objectForKey:kAPIUNIVERSITY] objectAtIndex:index] objectForKey:kAPIID]];
}
- (void)didUniversityReceived:(NSDictionary *)university
{
	if ([university isKindOfClass:[NSDictionary class]] && [[university objectForKey:kAPICAMPUSES] count] > 1) {
		
		self.root = [[QRootElement alloc] initWithJSONFile:@"chooseCampus"];
		[self.root bindToObject:university];
		[self.quickDialogTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationBottom];
	} else {
		if ([[NSUserDefaults standardUserDefaults] objectForKey:kACCOUNTIDKEY]) {
			[self.navigationController popViewControllerAnimated:YES];
		} else {
			[self performSegueWithIdentifier:@"ConfirmLoginSegue" sender:self];
		}
	}
}

- (void)onChooseCampus:(id)sender
{
	[[NSUserDefaults standardUserDefaults] setObject:[sender title] forKey:kCAMPUSNAMEKEY];
	if ([[NSUserDefaults standardUserDefaults] objectForKey:kACCOUNTIDKEY]) {
		[self.navigationController popViewControllerAnimated:YES];
	} else {
		[self performSegueWithIdentifier:@"ConfirmLoginSegue" sender:self];
	}
}

-(void)showAlert:(NSString*)message{
	[[[UIAlertView alloc] initWithTitle:nil
								message:message
							   delegate:nil
					  cancelButtonTitle:@"确定"
					  otherButtonTitles:nil] show];
}
- (void)requestError:(NSString *)errorString
{
	[self loading:NO];
	[self showAlert:errorString];
}

@end
