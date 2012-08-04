//
//  NanbeigeChooseCampusViewController.m
//  Nanbeige
//
//  Created by ZongZiWang on 12-8-5.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import "NanbeigeChooseCampusViewController.h"
#import "Environment.h"

@interface NanbeigeChooseCampusViewController ()

@end

@implementation NanbeigeChooseCampusViewController

- (void)setQuickDialogTableView:(QuickDialogTableView *)aQuickDialogTableView {
    [super setQuickDialogTableView:aQuickDialogTableView];
    self.quickDialogTableView.backgroundView = nil;
    self.quickDialogTableView.backgroundColor = tableBgColor1;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self) {
		self.root = [[QRootElement alloc] initWithJSONFile:@"chooseCampus"];
	}
	return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	
	[self.root bindToObject:self.university];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)onChooseCampus:(id)sender
{
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:kACCOUNTEDIT];
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:kACCOUNTEDITCAMPUS_ID];
	
	NSUInteger index = [[[sender parentSection] elements] indexOfObject:sender];
	NSNumber *campus_id = [[[self.university objectForKey:kAPICAMPUSES] objectAtIndex:index] objectForKey:kAPIID];
	[[NSUserDefaults standardUserDefaults] setObject:campus_id forKey:kCAMPUSIDKEY];
	[[NSUserDefaults standardUserDefaults] setObject:[[[self.university objectForKey:kAPICAMPUSES] objectAtIndex:index] objectForKey:kAPINAME] forKey:kCAMPUSNAMEKEY];
	
	if ([[NSUserDefaults standardUserDefaults] objectForKey:kACCOUNTIDKEY]) {
		[self.navigationController popViewControllerAnimated:YES];
	} else {
		[self performSegueWithIdentifier:@"ConfirmLoginSegue" sender:self];
	}
}

@end
