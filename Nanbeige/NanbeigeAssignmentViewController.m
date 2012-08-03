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
#import "JTTableViewGestureRecognizer.h"
#import "UIColor+JTGestureBasedTableViewHelper.h"

@interface NanbeigeAssignmentViewController () <JTTableViewGestureEditingRowDelegate>
{
	int assignmentSelect;
}
@property (nonatomic, strong) JTTableViewGestureRecognizer *assignmentsTableViewRecognizer;
@property (nonatomic, strong) JTTableViewGestureRecognizer *completeAssignmentsTableViewRecognizer;
@property (nonatomic, strong) id grabbedObject;

@end

@implementation NanbeigeAssignmentViewController
@synthesize assignments = _assignments;
@synthesize completeAssignments = _completeAssignments;
@synthesize nibsRegistered = _nibsRegistered;
@synthesize assignmentsTableView = _assignmentsTableView;
@synthesize completeAssignmentsTableView = _completeAssignmentsTableView;
@synthesize completeNibsRegistered = _completeNibsRegistered;
@synthesize completeSegmentedControl;
@synthesize assignmentsTableViewRecognizer;
@synthesize completeAssignmentsTableViewRecognizer;
@synthesize grabbedObject;

#pragma mark - Setter and Getter methods

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

- (NSMutableArray *)nowAssignments
{
	if ([completeSegmentedControl selectedSegmentIndex] == NOTCOMPLETE) 
		return self.assignments;
	else 
		return self.completeAssignments;
}
- (NSMutableArray *)otherAssignments
{
	if ([completeSegmentedControl selectedSegmentIndex] == NOTCOMPLETE) 
		return self.completeAssignments;
	else 
		return self.assignments;
}
- (UITableView *)nowAssignmentsTableView
{
	if ([completeSegmentedControl selectedSegmentIndex] == NOTCOMPLETE) 
		return self.assignmentsTableView;
	else 
		return self.completeAssignmentsTableView;
}
- (UITableView *)otherAssignmentsTableView
{
	if ([completeSegmentedControl selectedSegmentIndex] == NOTCOMPLETE) 
		return self.completeAssignmentsTableView;
	else 
		return self.assignmentsTableView;
}
- (NSMutableArray *)assignmentsOfTableView:(UITableView *)tableView
{
	if ([tableView isEqual:self.assignmentsTableView]) 
		return self.assignments;
	else if ([tableView isEqual:self.completeAssignmentsTableView])
		return self.completeAssignments;
	return nil;
}
- (NSMutableDictionary *)nibsRegisteredOfTableView:(UITableView *)tableView
{
	if ([tableView isEqual:self.assignmentsTableView]) 
		return self.nibsRegistered;
	else if ([tableView isEqual:self.completeAssignmentsTableView])
		return self.completeNibsRegistered;
	return nil;
}

#pragma mark - View Lifecycle

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
	self.title = TITLE_ASSIGNMENT;
	self.assignmentsTableViewRecognizer = [self.assignmentsTableView enableGestureTableViewWithDelegate:self];
	self.completeAssignmentsTableViewRecognizer = [self.completeAssignmentsTableView enableGestureTableViewWithDelegate:self];
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
	[super viewWillAppear:animated];
	self.assignments = [[[NSUserDefaults standardUserDefaults] objectForKey:kASSIGNMENTS] mutableCopy];
	self.completeAssignments = [[[NSUserDefaults standardUserDefaults] objectForKey:kCOMPLETEASSIGNMENTS] mutableCopy];
}
- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[[self nowAssignmentsTableView] reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
	    return YES;
	} else {
	    return (interfaceOrientation == UIInterfaceOrientationPortrait);
	}
}

#pragma mark -
#pragma mark Table View Attributes Methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSUInteger row = [indexPath row];
	NSString *nibName = @"NanbeigeAssignmentNoImageCell";
	NSString *identifier = @"NoImageCellIdentifier";
	
	if ([[[[self assignmentsOfTableView:tableView] objectAtIndex:row] objectForKey:kASSIGNMENTHASIMAGE] boolValue]) {
		nibName = @"NanbeigeAssignmentImageCell";
		identifier = @"ImageCellIdentifier";
	}
	
	if (![[[self nibsRegisteredOfTableView:tableView] objectForKey:nibName] isEqualToString:@"YES"]) {
		UINib *nib = [UINib nibWithNibName:nibName bundle:nil];
		[tableView registerNib:nib forCellReuseIdentifier:identifier];
		[[self nibsRegisteredOfTableView:tableView] setValue:@"YES" forKey:nibName];
	}
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	
	return cell.frame.size.height;
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
	
	if ([[[[self assignmentsOfTableView:tableView] objectAtIndex:row] objectForKey:kASSIGNMENTHASIMAGE] boolValue]) {
		nibName = @"NanbeigeAssignmentImageCell";
		identifier = @"ImageCellIdentifier";
	}
	
	if (![[[self nibsRegisteredOfTableView:tableView] objectForKey:nibName] isEqualToString:@"YES"]) {
		UINib *nib = [UINib nibWithNibName:nibName bundle:nil];
		[tableView registerNib:nib forCellReuseIdentifier:identifier];
		[[self nibsRegisteredOfTableView:tableView] setValue:@"YES" forKey:nibName];
	}
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	
	[(id)cell courseName].text = [[[self assignmentsOfTableView:tableView] objectAtIndex:row] objectForKey:kASSIGNMENTCOURSE];
	[(id)cell assignmentName].text = [[[self assignmentsOfTableView:tableView] objectAtIndex:row] objectForKey:kASSIGNMENTDESCRIPTION];
	[(id)cell assignmentTime].text = [[[self assignmentsOfTableView:tableView] objectAtIndex:row] objectForKey:kASSIGNMENTDDLSTR];
	if ([nibName isEqualToString:@"NanbeigeAssignmentImageCell"]) {
		//[[(NanbeigeAssignmentImageCell *)cell assignmentImage] setBackgroundImage:[UIImage imageNamed:@"assignment_image"] forState:UIControlStateNormal];
	}
	
	if ([[[[self assignmentsOfTableView:tableView] objectAtIndex:row] objectForKey:kASSIGNMENTCOMPLETE] boolValue]) {
		[[(id)cell changeCompleteButton] setBackgroundColor:completeAssignmentCellColor];
	} else {
		[[(id)cell changeCompleteButton] setBackgroundColor:notCompleteAssignmentCellColor];
	}	
	[(id)cell setDelegate:self];
	[(id)cell setAssignmentIndex:row];
	
	return cell;
}

- (void)changeComplete:(id)sender
{
	NSMutableDictionary *assignment = [[[self nowAssignments] objectAtIndex:[sender assignmentIndex]] mutableCopy];
	[assignment setObject:[NSNumber numberWithBool:[completeSegmentedControl selectedSegmentIndex] == NOTCOMPLETE] forKey:kASSIGNMENTCOMPLETE];
	[[self nowAssignments] removeObjectAtIndex:[sender assignmentIndex]];
	[[self otherAssignments] addObject:assignment];
	
	[[NSUserDefaults standardUserDefaults] setObject:self.assignments forKey:kASSIGNMENTS];
	[[NSUserDefaults standardUserDefaults] setObject:self.completeAssignments forKey:kCOMPLETEASSIGNMENTS];
	
	[[self nowAssignmentsTableView] deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[sender assignmentIndex] inSection:0]] withRowAnimation:[completeSegmentedControl selectedSegmentIndex] == COMPLETE ? UITableViewRowAnimationLeft : UITableViewRowAnimationRight];
	
    [[self nowAssignmentsTableView] performSelector:@selector(reloadData) withObject:nil afterDelay:JTTableViewRowAnimationDuration];
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
	[super prepareForSegue:segue sender:sender];
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
	[[self nowAssignmentsTableView] reloadData];
	[[self nowAssignmentsTableView] setHidden:NO];
	[[self otherAssignmentsTableView] setHidden:YES];
}

#pragma mark JTTableViewGestureEditingRowDelegate

- (void)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer didEnterEditingState:(JTTableViewCellEditingState)state forRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
	cell = [[self nowAssignmentsTableView] cellForRowAtIndexPath:indexPath];
	
    switch (state) {
        case JTTableViewCellEditingStateLeft:
            break;
        case JTTableViewCellEditingStateRight:
            break;
		case JTTableViewCellEditingStateMiddle:
			break;
        default:
            break;
    }
}

// This is needed to be implemented to let our delegate choose whether the panning gesture should work
- (BOOL)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)gestureRecognizer:(JTTableViewGestureRecognizer *)gestureRecognizer commitEditingState:(JTTableViewCellEditingState)state forRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableView *tableView = gestureRecognizer.tableView;
    [tableView beginUpdates];
    if (state == JTTableViewCellEditingStateLeft) {
        // An example to discard the cell at JTTableViewCellEditingStateLeft
		if ([[[[self nowAssignments] objectAtIndex:indexPath.row] objectForKey:kASSIGNMENTCOMPLETE] boolValue]) {
			NSMutableDictionary *assignment = [[[self nowAssignments] objectAtIndex:indexPath.row] mutableCopy];
			[assignment setObject:[NSNumber numberWithBool:NO] forKey:kASSIGNMENTCOMPLETE];
			[[self nowAssignments] removeObjectAtIndex:indexPath.row];
			[[self otherAssignments] addObject:assignment];
			
			[[NSUserDefaults standardUserDefaults] setObject:self.assignments forKey:kASSIGNMENTS];
			[[NSUserDefaults standardUserDefaults] setObject:self.completeAssignments forKey:kCOMPLETEASSIGNMENTS];
			
			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
		} else {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"确认删除作业: 「%@」", [(id)[[self nowAssignmentsTableView] cellForRowAtIndexPath:indexPath] assignmentName].text] message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
			[alert setTag:indexPath.row];
			[alert show];
		}
    } else if (state == JTTableViewCellEditingStateRight) {
        // An example to retain the cell at commiting at JTTableViewCellEditingStateRight
		if (![[[[self nowAssignments] objectAtIndex:indexPath.row] objectForKey:kASSIGNMENTCOMPLETE] boolValue]) {
			NSMutableDictionary *assignment = [[[self nowAssignments] objectAtIndex:indexPath.row] mutableCopy];
			[assignment setObject:[NSNumber numberWithBool:YES] forKey:kASSIGNMENTCOMPLETE];
			[[self nowAssignments] removeObjectAtIndex:indexPath.row];
			[[self otherAssignments] addObject:assignment];
			
			[[NSUserDefaults standardUserDefaults] setObject:self.assignments forKey:kASSIGNMENTS];
			[[NSUserDefaults standardUserDefaults] setObject:self.completeAssignments forKey:kCOMPLETEASSIGNMENTS];
			
			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
		} else {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"确认删除作业: 「%@」", [(id)[[self nowAssignmentsTableView] cellForRowAtIndexPath:indexPath] assignmentName].text] message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
			[alert setTag:indexPath.row];
			[alert show];
		}
    } else {
        // JTTableViewCellEditingStateMiddle shouldn't really happen in
        // - [JTTableViewGestureDelegate gestureRecognizer:commitEditingState:forRowAtIndexPath:]
    }
    [tableView endUpdates];
	
    // Row color needs update after datasource changes, reload it.
    [tableView performSelector:@selector(reloadVisibleRowsExceptIndexPath:) withObject:indexPath afterDelay:JTTableViewRowAnimationDuration];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 1) {
		[[self nowAssignments] removeObjectAtIndex:alertView.tag];
		[[self nowAssignmentsTableView] deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:alertView.tag inSection:0]] withRowAnimation:[completeSegmentedControl selectedSegmentIndex] == COMPLETE ? UITableViewRowAnimationRight : UITableViewRowAnimationLeft];
		[[NSUserDefaults standardUserDefaults] setObject:[self nowAssignments] forKey:[completeSegmentedControl selectedSegmentIndex] == COMPLETE ? kCOMPLETEASSIGNMENTS : kASSIGNMENTS];
	}	
}
		
@end
