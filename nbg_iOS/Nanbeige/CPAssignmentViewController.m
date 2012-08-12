//
//  CPAssignmentViewController.m
//  CP
//
//  Created by Wang Zhongyu on 12-7-17.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import "CPAssignmentViewController.h"
#import "CPAssignmentCreateViewController.h"
#import "CPAssignmentNoImageCell.h"
#import "CPAssignmentImageCell.h"
#import "Environment.h"
#import <CouchCocoa/CouchDesignDocument_Embedded.h>

@interface CPAssignmentViewController () 
{
	int assignmentSelect;
}


@property (nonatomic, strong) id grabbedObject;

@end

@implementation CPAssignmentViewController
@synthesize assignments = _assignments;
@synthesize completeAssignments = _completeAssignments;
@synthesize nibsRegistered = _nibsRegistered;
@synthesize assignmentsTableView = _assignmentsTableView;
@synthesize completeAssignmentsTableView = _completeAssignmentsTableView;
@synthesize completeNibsRegistered = _completeNibsRegistered;
@synthesize completeSegmentedControl = _completeSegmentedControl;

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
	if ([_completeSegmentedControl selectedSegmentIndex] == NOTCOMPLETE)
		return self.assignments;
	else 
		return self.completeAssignments;
}
- (NSMutableArray *)otherAssignments
{
	if ([_completeSegmentedControl selectedSegmentIndex] == NOTCOMPLETE) 
		return self.completeAssignments;
	else 
		return self.assignments;
}
- (UITableView *)nowAssignmentsTableView
{
	if ([_completeSegmentedControl selectedSegmentIndex] == NOTCOMPLETE) 
		return self.assignmentsTableView;
	else 
		return self.completeAssignmentsTableView;
}
- (UITableView *)otherAssignmentsTableView
{
	if ([_completeSegmentedControl selectedSegmentIndex] == NOTCOMPLETE) 
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
	self.title = TITLE_ASSIGNMENT;
	self.completeSegmentedControl.tintColor = navBarBgColor1;
	
	self.database = [(CPAppDelegate *)([[UIApplication sharedApplication] delegate]) database];
    
	// Create a 'view' containing list items sorted by date:
    CouchDesignDocument* design = [self.database designDocumentWithName: @"assignment"];
    [design defineViewNamed: @"notcomplete" mapBlock: MAPBLOCK({
		NSString *type = [doc objectForKey:@"doc_type"];
        NSNumber *finished = [doc objectForKey: @"finished"];
		NSString *due = [doc objectForKey: @"due"];
        if ([type isEqualToString:@"assignment"] && ![finished boolValue]) emit(due, doc);
    }) version: @"1.0"];
    [design defineViewNamed: @"complete" mapBlock: MAPBLOCK({
		NSString *type = [doc objectForKey:@"doc_type"];
        NSNumber *finished = [doc objectForKey: @"finished"];
		NSString *due = [doc objectForKey: @"due"];
        if ([type isEqualToString:@"assignment"] && [finished boolValue]) emit(due, doc);
    }) version: @"1.0"];
    
    // and a validation function requiring parseable dates:
    design.validationBlock = VALIDATIONBLOCK({
        if (newRevision.deleted)
            return YES;
        id date = [newRevision.properties objectForKey: @"last_modified"];
        if (date && ! [RESTBody dateWithJSONObject: date]) {
            context.errorMessage = [@"invalid date " stringByAppendingString: date];
            return NO;
        }
        return YES;
    });
	
	// Create a query sorted by descending date, i.e. newest items first:
    NSAssert(self.database!=nil, @"Not hooked up to database yet");
    _query = [[[self.database designDocumentWithName: @"assignment"] queryViewNamed: @"notcomplete"] asLiveQuery];
    _query.descending = NO;
    [_query addObserver: self forKeyPath: @"rows" options: 0 context: NULL];
	
	_completeQuery = [[[self.database designDocumentWithName: @"assignment"] queryViewNamed: @"complete"] asLiveQuery];
    _completeQuery.descending = NO;
    [_completeQuery addObserver: self forKeyPath: @"rows" options: 0 context: NULL];
	
    [self updateSyncURL];
}

- (void)updateSyncURL {
    if (!self.database)
        return;
    NSURL* newRemoteURL = nil;
    NSString *syncpoint = kDefaultSyncDbURL;
    if (syncpoint.length > 0)
        newRemoteURL = [NSURL URLWithString:syncpoint];
    
    [self forgetSync];
	
    NSArray* repls = [self.database replicateWithURL: newRemoteURL exclusively: YES];
    _pull = [repls objectAtIndex: 0];
    _push = [repls objectAtIndex: 1];
    [_pull addObserver: self forKeyPath: @"completed" options: 0 context: NULL];
    [_push addObserver: self forKeyPath: @"completed" options: 0 context: NULL];
}

- (void) forgetSync {
    [_pull removeObserver: self forKeyPath: @"completed"];
    _pull = nil;
    [_push removeObserver: self forKeyPath: @"completed"];
    _push = nil;
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                         change:(NSDictionary *)change context:(void *)context
{
    if (object == _pull || object == _push) {
        unsigned completed = _pull.completed + _push.completed;
        unsigned total = _pull.total + _push.total;
        NSLog(@"SYNC progress: %u / %u", completed, total);
        if (total > 0 && completed < total) {
            //[self showSyncStatus];
            //[progress setProgress:(completed / (float)total)];
        } else {
            //[self showSyncButton];
        }
		for (CouchQueryRow* row in [object rows]) {
            // update the UI
        }
    }
	if (object == _query) {
		for (CouchQueryRow* row in [object rows]) {
            // update the UI
        }
	}
	if (object == _completeQuery) {
		for (CouchQueryRow* row in [object rows]) {
            // update the UI
        }
	}
}

- (void)viewDidUnload
{
	[self setCompleteSegmentedControl:nil];
	[self setAssignmentsTableView:nil];
	[self setCompleteAssignmentsTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
//	self.assignments = [[[NSUserDefaults standardUserDefaults] objectForKey:kASSIGNMENTS] mutableCopy];
//	self.completeAssignments = [[[NSUserDefaults standardUserDefaults] objectForKey:kCOMPLETEASSIGNMENTS] mutableCopy];
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
	NSString *nibName = @"CPAssignmentNoImageCell";
	NSString *identifier = @"NoImageCellIdentifier";
	
	if ([[[[self assignmentsOfTableView:tableView] objectAtIndex:row] objectForKey:@"has_image"] boolValue]) {
		nibName = @"CPAssignmentImageCell";
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
	NSString *nibName = @"CPAssignmentNoImageCell";
	NSString *identifier = @"NoImageCellIdentifier";
	
	if ([[[[self assignmentsOfTableView:tableView] objectAtIndex:row] objectForKey:@"has_image"] boolValue]) {
		nibName = @"CPAssignmentImageCell";
		identifier = @"ImageCellIdentifier";
	}
	
	if (![[[self nibsRegisteredOfTableView:tableView] objectForKey:nibName] isEqualToString:@"YES"]) {
		UINib *nib = [UINib nibWithNibName:nibName bundle:nil];
		[tableView registerNib:nib forCellReuseIdentifier:identifier];
		[[self nibsRegisteredOfTableView:tableView] setValue:@"YES" forKey:nibName];
	}
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	
	[(id)cell courseName].text = [[[self assignmentsOfTableView:tableView] objectAtIndex:row] objectForKey:@"course_id"];
	[(id)cell assignmentName].text = [[[self assignmentsOfTableView:tableView] objectAtIndex:row] objectForKey:@"content"];
	[(id)cell assignmentTime].text = [[[self assignmentsOfTableView:tableView] objectAtIndex:row] objectForKey:@"due"];
	if ([nibName isEqualToString:@"CPAssignmentImageCell"]) {
		//[[(CPAssignmentImageCell *)cell assignmentImage] setBackgroundImage:[UIImage imageNamed:@"assignment_image"] forState:UIControlStateNormal];
	}
	
	if ([[[[self assignmentsOfTableView:tableView] objectAtIndex:row] objectForKey:@"finished"] boolValue]) {
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
	[assignment setObject:[NSNumber numberWithBool:[self.completeSegmentedControl selectedSegmentIndex] == NOTCOMPLETE] forKey:@"finished"];
	
	
//	[[self nowAssignments] removeObjectAtIndex:[sender assignmentIndex]];
//	[[self otherAssignments] addObject:assignment];
	
//	[[NSUserDefaults standardUserDefaults] setObject:self.assignments forKey:kASSIGNMENTS];
//	[[NSUserDefaults standardUserDefaults] setObject:self.completeAssignments forKey:kCOMPLETEASSIGNMENTS];
	
	[[self nowAssignmentsTableView] deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[sender assignmentIndex] inSection:0]] withRowAnimation:[self.completeSegmentedControl selectedSegmentIndex] == COMPLETE ? UITableViewRowAnimationLeft : UITableViewRowAnimationRight];
	
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
	CPAssignmentCreateViewController *ncavc = (CPAssignmentCreateViewController *)(nc.topViewController);
#warning 传递课表
	ncavc.coursesData = [[NSUserDefaults standardUserDefaults] objectForKey:kTEMPCOURSES];
	ncavc.initWithCamera = NO;
	if ([segue.identifier isEqualToString:@"ModifyAssignmentSegue"]) {
		ncavc.assignmentIndex = assignmentSelect;
		ncavc.bComplete = ([self.completeSegmentedControl selectedSegmentIndex] == COMPLETE);
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
		
@end
