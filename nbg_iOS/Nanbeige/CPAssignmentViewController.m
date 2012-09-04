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
#import "CPCourseGrabberViewController.h"
#import "Environment.h"
#import "Models+addon.h"

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
	
	self.assignmentsTableView.backgroundColor = tableBgColorPlain;
	self.completeAssignmentsTableView.backgroundColor = tableBgColorPlain;
	
	self.database = [(CPAppDelegate *)([[UIApplication sharedApplication] delegate]) database];
    
	CouchDesignDocument *_design = [self.database designDocumentWithName: @"assignment"];
    CouchDesignDocument *_completeDesign = [self.database designDocumentWithName: @"completeAssignment"];
    if (self.courseIdFilter) {
		[_design defineViewNamed:[NSString stringWithFormat:@"notcomplete?id=%@", self.courseIdFilter] mapBlock: MAPBLOCK({
			NSString *type = [doc objectForKey:@"doc_type"];
			NSNumber *finished = [doc objectForKey: @"finished"];
			NSString *due = [doc objectForKey: @"due"];
			NSNumber *course_id = [doc objectForKey:@"course_id"];
			if ([type isEqualToString:@"assignment"] && [course_id isEqualToNumber:self.courseIdFilter] && ![finished boolValue]) emit(due, doc);
		}) version: @"1.0"];
		[_completeDesign defineViewNamed: [NSString stringWithFormat:@"complete?id=%@", self.courseIdFilter] mapBlock: MAPBLOCK({
			NSString *type = [doc objectForKey:@"doc_type"];
			NSNumber *finished = [doc objectForKey: @"finished"];
			NSString *due = [doc objectForKey: @"due"];
			NSNumber *course_id = [doc objectForKey:@"course_id"];
			if ([type isEqualToString:@"assignment"] && [course_id isEqualToNumber:self.courseIdFilter] && [finished boolValue]) emit(due, doc);
		}) version: @"1.0"];
		
		// Create a query sorted by descending date, i.e. newest items first:
		NSAssert(self.database!=nil, @"Not hooked up to database yet");
		_query = [[_design queryViewNamed:[NSString stringWithFormat:@"notcomplete?id=%@", self.courseIdFilter]] asLiveQuery];
		_query.descending = NO;
		[_query addObserver: self forKeyPath: @"rows" options: 0 context: NULL];
		[_query start];
		
		_completeQuery = [[_completeDesign queryViewNamed:[NSString stringWithFormat:@"complete?id=%@", self.courseIdFilter]] asLiveQuery];
		_completeQuery.descending = NO;
		[_completeQuery addObserver: self forKeyPath: @"rows" options: 0 context: NULL];
		[_completeQuery start];
	} else {
		[_design defineViewNamed: @"notcomplete" mapBlock: MAPBLOCK({
			NSString *type = [doc objectForKey:@"doc_type"];
			NSNumber *finished = [doc objectForKey: @"finished"];
			NSString *due = [doc objectForKey: @"due"];
			if ([type isEqualToString:@"assignment"] && ![finished boolValue]) emit(due, doc);
		}) version: @"1.0"];
		[_completeDesign defineViewNamed: @"complete" mapBlock: MAPBLOCK({
			NSString *type = [doc objectForKey:@"doc_type"];
			NSNumber *finished = [doc objectForKey: @"finished"];
			NSString *due = [doc objectForKey: @"due"];
			if ([type isEqualToString:@"assignment"] && [finished boolValue]) emit(due, doc);
		}) version: @"1.0"];
		
		// Create a query sorted by descending date, i.e. newest items first:
		NSAssert(self.database!=nil, @"Not hooked up to database yet");
		_query = [[_design queryViewNamed: @"notcomplete"] asLiveQuery];
		_query.descending = NO;
		[_query addObserver: self forKeyPath: @"rows" options: 0 context: NULL];
		[_query start];
		
		_completeQuery = [[_completeDesign queryViewNamed: @"complete"] asLiveQuery];
		_completeQuery.descending = NO;
		[_completeQuery addObserver: self forKeyPath: @"rows" options: 0 context: NULL];
		[_completeQuery start];
	}
	
	[self updateSyncURL];
	if (self.bInitShowComplete) {
		self.completeSegmentedControl.selectedSegmentIndex = COMPLETE;
		[self onAssignmentCompleteChanged:self.completeSegmentedControl];
	}
}

- (void)updateSyncURL {
    if (!self.database)
        return;
    NSURL* newRemoteURL = nil;
    NSString *syncpoint = [[NSUserDefaults standardUserDefaults] objectForKey:@"syncpoint"];
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
        if (total > 0 && completed <= total) {
            //[self showSyncStatus];
            //[progress setProgress:(completed / (float)total)];
			if (completed == 0) {
				[(CPAppDelegate *)[UIApplication sharedApplication].delegate showProgressHudModeAnnularDeterminate:@"云端同步作业中..."];
			} else {
				[(CPAppDelegate *)[UIApplication sharedApplication].delegate setProgressHudProgress:(completed / (float)total)];
				if (completed == total) {
					[(CPAppDelegate *)[UIApplication sharedApplication].delegate hideProgressHud];
				}
			}
        } else {
            //[self showSyncButton];
        }
    }
	if (object == _query) {
		self.assignments = nil;
		for (CouchQueryRow* row in [object rows]) {
            [self.assignments addObject:[Assignment modelForDocument:row.document]];
        }
		[[self assignmentsTableView] reloadData];
	}
	if (object == _completeQuery) {
		self.completeAssignments = nil;
		for (CouchQueryRow* row in [object rows]) {
            [self.completeAssignments addObject:[Assignment modelForDocument:row.document]];
        }
		[[self completeAssignmentsTableView] reloadData];
	}
}

- (void)viewDidUnload
{
	[self setCompleteSegmentedControl:nil];
	[self setAssignmentsTableView:nil];
	[self setCompleteAssignmentsTableView:nil];
	self.nibsRegistered = nil;
	self.completeNibsRegistered = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	if ([self.assignmentsTableView indexPathForSelectedRow])
		[self.assignmentsTableView deselectRowAtIndexPath:[self.assignmentsTableView indexPathForSelectedRow] animated:YES];
	if ([self.completeAssignmentsTableView indexPathForSelectedRow])
		[self.completeAssignmentsTableView deselectRowAtIndexPath:[self.completeAssignmentsTableView indexPathForSelectedRow] animated:YES];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	[(CPAppDelegate *)[UIApplication sharedApplication].delegate hideProgressHud];
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
	
	Assignment *assignment = [[self assignmentsOfTableView:tableView] objectAtIndex:row];
	
	if ([assignment.has_image boolValue]) {
		nibName = @"CPAssignmentImageCell";
		identifier = @"ImageCellIdentifier";
	}
	
	if (![[[self nibsRegisteredOfTableView:tableView] objectForKey:nibName] integerValue]) {
		UINib *nib = [UINib nibWithNibName:nibName bundle:nil];
		[tableView registerNib:nib forCellReuseIdentifier:identifier];
		[[self nibsRegisteredOfTableView:tableView] setValue:@1 forKey:nibName];
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
	
	Assignment *assignment = [[self assignmentsOfTableView:tableView] objectAtIndex:row];
	
	if ([assignment.has_image boolValue]) {
		nibName = @"CPAssignmentImageCell";
		identifier = @"ImageCellIdentifier";
	}
	
	if (![[[self nibsRegisteredOfTableView:tableView] objectForKey:nibName] integerValue]) {
		UINib *nib = [UINib nibWithNibName:nibName bundle:nil];
		[tableView registerNib:nib forCellReuseIdentifier:identifier];
		[[self nibsRegisteredOfTableView:tableView] setValue:@1 forKey:nibName];
	}
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	
	[(id)cell courseName].text = assignment.course_name;
	if ([assignment.due_type isEqualToString:TYPE_ON_LESSON] && [[(id)cell courseName].text length] > 5) [(id)cell courseName].text = [NSString stringWithFormat:@"%@...", [[(id)cell courseName].text substringToIndex:5]];
	if ([assignment.due_type isEqualToString:TYPE_ON_DATE] && [[(id)cell courseName].text length] > 7) [(id)cell courseName].text =  [NSString stringWithFormat:@"%@...", [[(id)cell courseName].text substringToIndex:7]];
	[(id)cell assignmentName].text = assignment.content;
	[(id)cell assignmentTime].text = assignment.due_display;
	if ([assignment.has_image boolValue]) {
		[[(id)cell assignmentImage] setBackgroundImage:[UIImage imageWithData:assignment.image_data] forState:UIControlStateNormal];
	}
	
	if ([assignment.finished boolValue]) {
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
	Assignment *assignment = [[self nowAssignments] objectAtIndex:[sender assignmentIndex]];
	assignment.finished = [NSNumber numberWithBool:![assignment.finished boolValue]];
	RESTOperation *op = [assignment save];
	[op onCompletion:^{
		if (op.error) {
			NSLog(@"Assignment:changeComplete %@", op.error);
		} else {
			NSLog(@"Assignment:changeComplete %@", @"更新完毕");
		}
	}];
	
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

	ncavc.coursesData = [[Course userCourseListDocument] propertyForKey:@"value"];
	
	ncavc.bInitWithCamera = NO;
	if ([segue.identifier isEqualToString:@"ModifyAssignmentSegue"]) {
		ncavc.bCreate = NO;
		ncavc.assignment = [[self nowAssignments] objectAtIndex:assignmentSelect];
	} else {
		ncavc.bCreate = YES;
		ncavc.courseIdFilter = self.courseIdFilter;
		ncavc.assignment = [[Assignment alloc] initWithNewDocumentInDatabase:[(CPAppDelegate *)([[UIApplication sharedApplication] delegate]) database]];
	}
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
	assignmentSelect = [indexPath row];
	[self performSegueWithIdentifier:@"ModifyAssignmentSegue" sender:self];
}

- (IBAction)onAssignmentCompleteChanged:(id)sender {
	[[self nowAssignmentsTableView] reloadData];
	[[self nowAssignmentsTableView] setHidden:NO];
	[[self otherAssignmentsTableView] setHidden:YES];
}
		
@end
