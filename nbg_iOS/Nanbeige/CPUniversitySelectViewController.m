//
//  CPChooseSchoolViewController.m
//  CP
//
//  Created by ZongZiWang on 12-8-1.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import "CPUniversitySelectViewController.h"
#import "Environment.h"
#import "Coffeepot.h"
#import "Models+addon.h"

@interface CPUniversitySelectViewController () {
	NSMutableArray *campuses;
}

@end

@implementation CPUniversitySelectViewController

#pragma mark - Setter and Getter Methods

- (void)setQuickDialogTableView:(QuickDialogTableView *)aQuickDialogTableView {
    [super setQuickDialogTableView:aQuickDialogTableView];
    self.quickDialogTableView.backgroundView = nil;
    self.quickDialogTableView.backgroundColor = tableBgColor1;
	self.quickDialogTableView.deselectRowWhenViewAppears = YES;
}

#pragma mark - View Lifecycle

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self) {
		self.root = [[QRootElement alloc] initWithJSONFile:@"universitySelect"];
	}
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"欢迎" style:UIBarButtonItemStyleBordered target:nil action:nil];
	
	[[Coffeepot shared] requestWithMethodPath:@"university/" params:nil requestMethod:@"GET" success:^(CPRequest *_req, NSArray *collection) {
		
		campuses = [[NSMutableArray alloc] init];
		for (NSDictionary *university in collection) {
			for (NSDictionary *campus in [university objectForKey:@"campuses"]) {
				NSDictionary *displayCampus = @{
				@"campus" : @{
					@"id" : [campus objectForKey:@"id"],
					@"name" : [campus objectForKey:@"name"]},
				@"university" : @{
					@"id" : [university objectForKey:@"id"],
					@"name" : [university objectForKey:@"name"]},
				@"display_name" : [[university objectForKey:@"name"] stringByAppendingFormat:@" %@", [campus objectForKey:@"name"]]};
				[campuses addObject:displayCampus];
			}
		}
		
		NSDictionary *dict = @{@"campuses":campuses};
		[self.root bindToObject:dict];
		[self.quickDialogTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationBottom];
		
	} error:^(CPRequest *_req,NSDictionary *collection, NSError *error) {
		if ([collection objectForKey:@"error"]) {
			raise(-1);
		}
	}];
	
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
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
	NSDictionary *campus = [campuses objectAtIndex:index];
	[User updateSharedAppUserProfile:campus];
	
	if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"CPIsSignedIn"] boolValue]) [self dismissModalViewControllerAnimated:YES];
	[self performSegueWithIdentifier:@"signinConfirmSegue" sender:self];
}

@end
