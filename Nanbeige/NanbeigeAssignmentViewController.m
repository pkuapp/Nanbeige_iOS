//
//  NanbeigeAssignmentViewController.m
//  Nanbeige
//
//  Created by Wang Zhongyu on 12-7-17.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import "NanbeigeAssignmentViewController.h"
#import "NanbeigeCreateAssignmentViewController.h"
#import "NanbeigeAssignmentNoImageCell.h"
#import "NanbeigeAssignmentImageCell.h"
#import "Environment.h"

@interface NanbeigeAssignmentViewController () {
	int assignmentSelect;
}

@end

@implementation NanbeigeAssignmentViewController
@synthesize assignments = _assignments;
@synthesize completeAssignments = _completeAssignments;
@synthesize nibsRegistered = _nibsRegistered;
@synthesize assignmentsTableView = _assignmentsTableView;
@synthesize completeAssignmentsTableView = _completeAssignmentsTableView;
@synthesize completeNibsRegistered = _completeNibsRegistered;
@synthesize completeSegmentedControl;

- (NSMutableArray *)assignments
{
	if (_assignments == nil) {
		_assignments = [[NSMutableArray alloc] init];
	}
	return _assignments;
}
- (NSMutableArray *)completeAssignments
{
	if (_completeAssignments == nil) {
		_completeAssignments = [[NSMutableArray alloc] init];
	}
	return _completeAssignments;
}
- (NSMutableDictionary *)nibsRegistered
{
	if (_nibsRegistered == nil) {
		_nibsRegistered = [[NSMutableDictionary alloc] init];
	}
	return _nibsRegistered;
}
- (NSMutableDictionary *)completeNibsRegistered
{
	if (_completeNibsRegistered == nil) {
		_completeNibsRegistered = [[NSMutableDictionary alloc] init];
	}
	return _completeNibsRegistered;
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
#warning 用伪数据测试
	
}

- (void)viewDidUnload
{
	[self setAssignmentsTableView:nil];
	[self setCompleteSegmentedControl:nil];
	[self setCompleteAssignmentsTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}
- (void)viewWillAppear:(BOOL)animated
{
	self.assignments = [[[NSUserDefaults standardUserDefaults] objectForKey:kASSIGNMENTS] mutableCopy];
	self.completeAssignments = [[[NSUserDefaults standardUserDefaults] objectForKey:kCOMPLETEASSIGNMENTS] mutableCopy];
}
- (void)viewDidAppear:(BOOL)animated
{
	if ([self.completeSegmentedControl selectedSegmentIndex] == 0) {
		[self.assignmentsTableView reloadData];
	} else {
		[self.completeAssignmentsTableView reloadData];
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark Table View Attributes Methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSUInteger row = [indexPath row];
	NSString *nibName = @"NanbeigeAssignmentNoImageCell";
	NSString *identifier = @"NoImageCellIdentifier";
	
	if ([tableView isEqual:self.assignmentsTableView]) {
		if ([[[self.assignments objectAtIndex:row] objectForKey:kASSIGNMENTHASIMAGE] boolValue]) {
			nibName = @"NanbeigeAssignmentImageCell";
			identifier = @"ImageCellIdentifier";
		}
		
		if (![[self.nibsRegistered objectForKey:nibName] isEqualToString:@"YES"]) {
			UINib *nib = [UINib nibWithNibName:nibName bundle:nil];
			[tableView registerNib:nib forCellReuseIdentifier:identifier];
			[self.nibsRegistered setValue:@"YES" forKey:nibName];
		}
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
		
		return cell.frame.size.height;
	} else {
		if ([[[self.completeAssignments objectAtIndex:row] objectForKey:kASSIGNMENTHASIMAGE] boolValue]) {
			nibName = @"NanbeigeAssignmentImageCell";
			identifier = @"ImageCellIdentifier";
		}
		
		if (![[self.completeNibsRegistered objectForKey:nibName] isEqualToString:@"YES"]) {
			UINib *nib = [UINib nibWithNibName:nibName bundle:nil];
			[tableView registerNib:nib forCellReuseIdentifier:identifier];
			[self.completeNibsRegistered setValue:@"YES" forKey:nibName];
		}
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
		
		return cell.frame.size.height;
	}
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if ([tableView isEqual:self.assignmentsTableView])
		return [self.assignments count];
	else 
		return [self.completeAssignments count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	
	NSUInteger row = [indexPath row];
	NSString *nibName = @"NanbeigeAssignmentNoImageCell";
	NSString *identifier = @"NoImageCellIdentifier";
	
	if ([tableView isEqual:self.assignmentsTableView]) {
		if ([[[self.assignments objectAtIndex:row] objectForKey:kASSIGNMENTHASIMAGE] boolValue]) {
			nibName = @"NanbeigeAssignmentImageCell";
			identifier = @"ImageCellIdentifier";
		}
		
		if (![[self.nibsRegistered objectForKey:nibName] isEqualToString:@"YES"]) {
			UINib *nib = [UINib nibWithNibName:nibName bundle:nil];
			[tableView registerNib:nib forCellReuseIdentifier:identifier];
			[self.nibsRegistered setValue:@"YES" forKey:nibName];
		}
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
		
		[(id)cell courseName].text = [[self.assignments objectAtIndex:row] objectForKey:kASSIGNMENTCOURSE];
		[(id)cell assignmentName].text = [[self.assignments objectAtIndex:row] objectForKey:kASSIGNMENTDESCRIPTION];
		[(id)cell assignmentTime].text = [[self.assignments objectAtIndex:row] objectForKey:kASSIGNMENTDDLSTR];
		if ([nibName isEqualToString:@"NanbeigeAssignmentImageCell"]) {
			//[[(NanbeigeAssignmentImageCell *)cell assignmentImage] setBackgroundImage:[UIImage imageNamed:@"assignment_image"] forState:UIControlStateNormal];
		}
		
		[[(id)cell changeCompleteButton] setBackgroundColor:notCompleteAssignmentCellColor];
		[(id)cell setDelegate:self];
		[(id)cell setAssignmentIndex:row];
		
		return cell;
	} else {
		if ([[[self.completeAssignments objectAtIndex:row] objectForKey:kASSIGNMENTHASIMAGE] boolValue]) {
			nibName = @"NanbeigeAssignmentImageCell";
			identifier = @"ImageCellIdentifier";
		}
		
		if (![[self.completeNibsRegistered objectForKey:nibName] isEqualToString:@"YES"]) {
			UINib *nib = [UINib nibWithNibName:nibName bundle:nil];
			[tableView registerNib:nib forCellReuseIdentifier:identifier];
			[self.completeNibsRegistered setValue:@"YES" forKey:nibName];
		}
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
		
		[(id)cell courseName].text = [[self.completeAssignments objectAtIndex:row] objectForKey:kASSIGNMENTCOURSE];
		[(id)cell assignmentName].text = [[self.completeAssignments objectAtIndex:row] objectForKey:kASSIGNMENTDESCRIPTION];
		[(id)cell assignmentTime].text = [[self.completeAssignments objectAtIndex:row] objectForKey:kASSIGNMENTDDLSTR];
		if ([nibName isEqualToString:@"NanbeigeAssignmentImageCell"]) {
			//[[(NanbeigeAssignmentImageCell *)cell assignmentImage] setBackgroundImage:[UIImage imageNamed:@"assignment_image"] forState:UIControlStateNormal];
		}
		
		[[(id)cell changeCompleteButton] setBackgroundColor:completeAssignmentCellColor];
		[(id)cell setDelegate:self];
		[(id)cell setAssignmentIndex:row];
		
		return cell;
	}
}

- (void)changeComplete:(id)sender
{
	if ([completeSegmentedControl selectedSegmentIndex] == NOTCOMPLETE) {
		[self.completeAssignments addObject:[self.assignments objectAtIndex:[sender assignmentIndex]]];
		[self.assignments removeObjectAtIndex:[sender assignmentIndex]];
		[[NSUserDefaults standardUserDefaults] setObject:self.assignments forKey:kASSIGNMENTS];
		[[NSUserDefaults standardUserDefaults] setObject:self.completeAssignments forKey:kCOMPLETEASSIGNMENTS];
		[self.assignmentsTableView reloadData];
	} else if ([completeSegmentedControl selectedSegmentIndex] == COMPLETE) {
		[self.assignments addObject:[self.completeAssignments objectAtIndex:[sender assignmentIndex]]];
		[self.completeAssignments removeObjectAtIndex:[sender assignmentIndex]];
		[[NSUserDefaults standardUserDefaults] setObject:self.assignments forKey:kASSIGNMENTS];
		[[NSUserDefaults standardUserDefaults] setObject:self.completeAssignments forKey:kCOMPLETEASSIGNMENTS];
		[self.completeAssignmentsTableView reloadData];
	}
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }   
 }
 */

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	UINavigationController *nc = segue.destinationViewController;
	NanbeigeCreateAssignmentViewController *ncavc = (NanbeigeCreateAssignmentViewController *)(nc.topViewController);
#warning 传递课表
	ncavc.coursesData = TEMPCOURSES;
	ncavc.initWithCamera = NO;
	if ([segue.identifier isEqualToString:@"ModifyAssignmentSegue"]) {
		ncavc.assignmentIndex = assignmentSelect;
		ncavc.bComplete = ([completeSegmentedControl selectedSegmentIndex] == COMPLETE);
	} else {
		ncavc.assignmentIndex = -1;
	}
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
	assignmentSelect = [indexPath row];
	[self performSegueWithIdentifier:@"ModifyAssignmentSegue" sender:self];
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (IBAction)onAssignmentCompleteChanged:(id)sender {
	if ([completeSegmentedControl selectedSegmentIndex] == NOTCOMPLETE) {
		[self.assignmentsTableView reloadData];
		[self.assignmentsTableView setHidden:NO];
		[self.completeAssignmentsTableView setHidden:YES];
	} else {
		[self.completeAssignmentsTableView reloadData];
		[self.completeAssignmentsTableView setHidden:NO];
		[self.assignmentsTableView setHidden:YES];
	}
}
		
@end
