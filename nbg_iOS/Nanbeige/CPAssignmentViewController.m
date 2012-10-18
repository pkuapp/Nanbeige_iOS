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
	
//    NSArray *vcarray = self.navigationController.viewControllers;
//    NSString *back_title = [[vcarray objectAtIndex:vcarray.count-2] title];
//	self.navigationItem.leftBarButtonItem = [UIBarButtonItem styledBackBarButtonItemWithTitle:back_title target:self.navigationController selector:@selector(popViewControllerAnimated:)];
	
	self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"作业列表" style:UIBarButtonItemStyleBordered target:nil action:nil];
	self.navigationItem.rightBarButtonItem = [UIBarButtonItem styledBlueBarButtonItemWithTitle:@"新增" target:self selector:@selector(onCreate:)];
	
	self.tableView.backgroundColor = tableBgColorPlain;
	
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
	
	if (self.bInitShowComplete) {
		self.completeSegmentedControl.selectedSegmentIndex = COMPLETE;
		[self onAssignmentCompleteChanged:self.completeSegmentedControl];
	}
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                         change:(NSDictionary *)change context:(void *)context
{
	if (object == _query) {
		self.assignments = nil;
		for (CouchQueryRow* row in [object rows]) {
            [self.assignments addObject:[Assignment modelForDocument:row.document]];
        }
		[self.tableView reloadData];
	}
	if (object == _completeQuery) {
		self.completeAssignments = nil;
		for (CouchQueryRow* row in [object rows]) {
            [self.completeAssignments addObject:[Assignment modelForDocument:row.document]];
        }
		[self.tableView reloadData];
	}
}

- (void)viewDidUnload
{
	[self setCompleteSegmentedControl:nil];
	[self setTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	self.nibsRegistered = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
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
	
	Assignment *assignment = [self.nowAssignments objectAtIndex:row];
	
	if ([assignment.has_image boolValue]) {
		nibName = @"CPAssignmentImageCell";
		identifier = @"ImageCellIdentifier";
	}
	
	if (![[self.nibsRegistered objectForKey:nibName] integerValue]) {
		UINib *nib = [UINib nibWithNibName:nibName bundle:nil];
		[tableView registerNib:nib forCellReuseIdentifier:identifier];
		[self.nibsRegistered setValue:@1 forKey:nibName];
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
	return [self.nowAssignments count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	
	NSUInteger row = [indexPath row];
	NSString *nibName = @"CPAssignmentNoImageCell";
	NSString *identifier = @"NoImageCellIdentifier";
	
	Assignment *assignment = [self.nowAssignments objectAtIndex:row];
	
	if ([assignment.has_image boolValue]) {
		nibName = @"CPAssignmentImageCell";
		identifier = @"ImageCellIdentifier";
	}
	
	if (![[self.nibsRegistered objectForKey:nibName] integerValue]) {
		UINib *nib = [UINib nibWithNibName:nibName bundle:nil];
		[tableView registerNib:nib forCellReuseIdentifier:identifier];
		[self.nibsRegistered setValue:@1 forKey:nibName];
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
	Assignment *assignment = [self.nowAssignments objectAtIndex:[sender assignmentIndex]];
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

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		[tableView beginUpdates];
		RESTOperation *deleteOp = [[[self.nowAssignments objectAtIndex:indexPath.row] document] DELETE];
		if (deleteOp && ![deleteOp wait]) NSLog(@"%@", deleteOp.error);
		[self.nowAssignments removeObjectAtIndex:indexPath.row];
		[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
		[tableView endUpdates];
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
	[super prepareForSegue:segue sender:sender];
	UINavigationController *nc = segue.destinationViewController;
	CPAssignmentCreateViewController *ncavc = (CPAssignmentCreateViewController *)(nc.topViewController);

	ncavc.coursesData = [[Course userCourseListDocument] propertyForKey:@"value"];
	
	ncavc.bInitWithCamera = NO;
	if ([segue.identifier isEqualToString:@"ModifyAssignmentSegue"]) {
		ncavc.bCreate = NO;
		ncavc.assignment = [self.nowAssignments objectAtIndex:assignmentSelect];
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

- (void)onCreate:(id)sender
{
	[self performSegueWithIdentifier:@"CreateAssignmentSegue" sender:self];
}

- (IBAction)onAssignmentCompleteChanged:(id)sender {
	[self.tableView reloadData];
}
		
@end
