//
//  NanbeigeRoomsViewController.m
//  Nanbeige
//
//  Created by ZongZiWang on 12-8-9.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import "NanbeigeRoomsViewController.h"
#import "Environment.h"
#import "NanbeigeAccountManager.h"
#import "GCArraySectionController.h"
#import "GCRetractableSectionController.h"

@interface NanbeigeRoomsViewController () <AccountManagerDelegate> {
	NanbeigeAccountManager *accountManager;
	NSDate *date;
	NSInteger buildingIndex;
	NSMutableArray *retractableControllers;
}

@end

@implementation NanbeigeRoomsViewController
@synthesize tableView = _tableView;
@synthesize toolbar = _toolbar;
@synthesize datePicker = _datePicker;
@synthesize buildings = _buildings;
@synthesize rooms = _rooms;

#pragma mark - Setter and Getter methods

- (NSArray *)buildings
{
	if (_buildings == nil) {
		_buildings = [[NSArray alloc] init];
	}
	return _buildings;
}
- (NSMutableArray *)rooms
{
	if (_rooms == nil) {
		_rooms = [[NSMutableArray alloc] init];
	}
	return _rooms;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
	
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	self.navigationController.navigationBar.tintColor = navBarBgColor1;
	self.tableView.backgroundColor = tableBgColor3;
	
	if (_refreshHeaderView == nil) {
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
		view.delegate = self;
		[view setBackgroundColor:tableBgColor1];
		[self.tableView addSubview:view];
		_refreshHeaderView = view;
	}
	//  update the last update date
	[_refreshHeaderView refreshLastUpdatedDate];
	
	self.title = [NSString stringWithFormat:FORMAT_TITLE_ROOMS, @"今天"];
	date = nil;
	UIBarButtonItem *datePickButton = [[UIBarButtonItem alloc] initWithTitle:@"日期" style:UIBarButtonItemStyleBordered target:self action:@selector(onDatePick:)];
	self.navigationItem.rightBarButtonItem = datePickButton;
	
	self.buildings = [[NSUserDefaults standardUserDefaults] valueForKey:kTEMPBUILDINGS];
	self.rooms = [[NSUserDefaults standardUserDefaults] valueForKey:kTEMPROOMS];
	[self reloadRooms];
	
	accountManager = [[NanbeigeAccountManager alloc] initWithViewController:self];
	accountManager.delegate = self;
}

- (void)viewDidUnload
{
	[self setTableView:nil];
    [self setToolbar:nil];
    [self setDatePicker:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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
	UIAlertView* alertView =[[UIAlertView alloc] initWithTitle:nil
													   message:message
													  delegate:nil
											 cancelButtonTitle:sCONFIRM
											 otherButtonTitles:nil];
	[alertView show];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return retractableControllers.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    GCRetractableSectionController* sectionController = [retractableControllers objectAtIndex:section];
    return sectionController.numberOfRow;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GCRetractableSectionController* sectionController = [retractableControllers objectAtIndex:indexPath.section];
    return [sectionController cellForRow:indexPath.row];
	/*
    static NSString *identifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	if (nil == cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
	}
	cell.textLabel.text = [[self.buildings objectAtIndex:indexPath.row] objectForKey:kAPINAME];
    cell.detailTextLabel.text = [[[self.buildings objectAtIndex:indexPath.row] objectForKey:kAPIID] stringValue];
	
    return cell;
	 */
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    GCRetractableSectionController* sectionController = [retractableControllers objectAtIndex:indexPath.section];
    return [sectionController didSelectCellAtRow:indexPath.row];
}

#pragma mark - Data Process

- (void)syncNextRooms
{
	if (buildingIndex == _buildings.count) {
		[[NSUserDefaults standardUserDefaults] setValue:self.rooms forKey:kTEMPROOMS];
		[self reloadRooms];
		[self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:0.5];
		return ;
	}
	[accountManager requestRoomsWithBuildingID:[[self.buildings objectAtIndex:buildingIndex] objectForKey:kAPIID] Date:date];
	buildingIndex ++;
}

- (void)reloadRooms
{
	retractableControllers = [[NSMutableArray alloc] init];
	if (self.buildings.count != self.rooms.count) return ;
	for (int index = 0; index < self.buildings.count; index++) {
		
		NSMutableArray *roomNames = [[NSMutableArray alloc] init];
		NSString *roomString = @"";
		for (int i = 0; i < [[self.rooms objectAtIndex:index] count]; i++) {
			if ([roomString length] >= LIMIT_ROOM_STRING_LENGTH) {
				[roomNames addObject:roomString];
				roomString = @"";
			}
			if ([roomString length] > 0) roomString = [roomString stringByAppendingString:@"・"];
			roomString = [roomString stringByAppendingString:[[[self.rooms objectAtIndex:index] objectAtIndex:i] objectForKey:kAPINAME]];
		}
		if ([roomString length] > 0) [roomNames addObject:roomString];
		
		GCArraySectionController* arrayController = [[GCArraySectionController alloc] initWithArray:roomNames viewController:self];
		arrayController.title = [[self.buildings objectAtIndex:index] objectForKey:kAPINAME];
		arrayController.open = YES;
		[retractableControllers addObject:arrayController];
	}
}

#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
	
	//  should be calling your tableviews data source model to reload
	//  put here just for demo
	_reloading = YES;
	
	NSNumber *campus_id = [[NSUserDefaults standardUserDefaults] objectForKey:kCAMPUSIDKEY];
	if (campus_id) {
		[accountManager requestBuildingsWithCampusID:campus_id];
	} else {
		[accountManager requestBuildingsWithCampusID:[NSNumber numberWithInt:8]];
	}
}

- (void)doneLoadingTableViewData{
	
	[self.tableView reloadData];
	//  model should call this when its done loading
	_reloading = NO;
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
	
}


#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
	
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
	
}


#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
	
	[self reloadTableViewDataSource];
	//[self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:3.0];
	
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	
	return _reloading; // should return if data source model is reloading
	
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	
	return [NSDate date]; // should return date data source was last changed
	
}

#pragma mark - Button controllerAction

- (void)onDatePick:(id)sender
{
	self.toolbar.hidden = NO;
	self.datePicker.hidden = NO;
}
- (IBAction)onConfrimDatePick:(id)sender {
	self.toolbar.hidden = YES;
	self.datePicker.hidden = YES;
	date = self.datePicker.date;
	
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	formatter.dateFormat = @"M月d日";
	self.title = [NSString stringWithFormat:FORMAT_TITLE_ROOMS, [formatter stringFromDate:date]];
}

#pragma mark - AccountManagerDelegate Others

- (void)didBuildingsReceived:(NSArray *)buildings
				WithCampusID:(NSNumber *)campus_id
{
	self.buildings = buildings;
	[[NSUserDefaults standardUserDefaults] setValue:buildings forKey:kTEMPBUILDINGS];
	
	self.rooms = nil;
	buildingIndex = 0;
	[self syncNextRooms];
}

- (void)didRoomsReceived:(NSArray *)rooms
		  WithBuildingID:(NSNumber *)building_id
{
	[self.rooms addObject:rooms];
	[self syncNextRooms];
}

- (void)didRequest:(ASIHTTPRequest *)request FailWithError:(NSString *)errorString
{
	[self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:0.5];
	[self showAlert:errorString];
}

@end