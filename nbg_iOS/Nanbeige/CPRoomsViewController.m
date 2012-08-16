//
//  CPRoomsViewController.m
//  CP
//
//  Created by ZongZiWang on 12-8-9.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import "CPRoomsViewController.h"
#import "Environment.h"
#import "CPRoomRetractableSectionController.h"
#import "Coffeepot.h"
#import "Models+addon.h"

@interface CPRoomsViewController () {
	NSDate *date;
	NSInteger buildingIndex;
	NSMutableArray *retractableControllers;
}

@end

@implementation CPRoomsViewController
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
	self.tableView.backgroundColor = tableBgColorPlain;
	
	if (_refreshHeaderView == nil) {
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
		view.delegate = self;
		[view setBackgroundColor:tableBgColorPlain];
		[self.tableView addSubview:view];
		_refreshHeaderView = view;
	}
	//  update the last update date
	[_refreshHeaderView refreshLastUpdatedDate];
	
	self.title = [NSString stringWithFormat:FORMAT_TITLE_ROOMS, @"今天"];
	date = nil;
	UIBarButtonItem *datePickButton = [[UIBarButtonItem alloc] initWithTitle:@"日期" style:UIBarButtonItemStyleBordered target:self action:@selector(onDatePick:)];
	self.navigationItem.rightBarButtonItem = datePickButton;
	
	CouchDatabase *localDatabase = [(CPAppDelegate *)([[UIApplication sharedApplication] delegate]) localDatabase];
	CouchDocument *doc = [localDatabase documentWithID:[NSString stringWithFormat:@"buildings%@", [User sharedAppUser].campus_id]];
	self.buildings = [[doc properties] objectForKey:@"value"];
	
	doc = [localDatabase documentWithID:@"rooms"];
	self.rooms = [[doc properties] objectForKey:@"value"];
	
	[self reloadRooms];
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
		
		NSMutableDictionary *mutableRooms = [@{ @"value" : self.rooms } mutableCopy];
		[mutableRooms setObject:@"rooms" forKey:@"doc_type"];
		CouchDatabase *localDatabase = [(CPAppDelegate *)([[UIApplication sharedApplication] delegate]) localDatabase];
		CouchDocument *doc = [localDatabase documentWithID:@"rooms"];
		if ([doc propertyForKey:@"_rev"]) [mutableRooms setObject:[doc propertyForKey:@"_rev"] forKey:@"_rev"];
		RESTOperation *op = [doc putProperties:mutableRooms];
		[op onCompletion:^{
			if (op.error) NSLog(@"%@", op.error);
		}];
		
		[self reloadRooms];
		[self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:0.5];
		return ;
	}
	
	NSNumber *building_id;
	NSDictionary *params;
	if (date) {
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		dateFormatter.dateFormat = @"yyyy-MM-dd";
		params = @{ @"date" : [dateFormatter stringFromDate:date] };
	} else params = nil;
	building_id = [[self.buildings objectAtIndex:buildingIndex] objectForKey:@"id"];
	
	[[Coffeepot shared] requestWithMethodPath:[NSString stringWithFormat:@"study/building/%@/room/", building_id] params:params requestMethod:@"GET" success:^(CPRequest *_req, id collection) {
		
		buildingIndex ++;
		[self.rooms addObject:collection];
		[self syncNextRooms];
		
	} error:^(CPRequest *_req, id collection, NSError *error) {
		if ([collection isKindOfClass:[NSDictionary class]] && [collection objectForKey:@"error"])
			[self showAlert:[collection objectForKey:@"error"]];//raise(-1);
		if ([collection isKindOfClass:[NSDictionary class]] && [collection objectForKey:@"error_code"])
			[self showAlert:[collection objectForKey:@"error_code"]];//raise(-1);
	}];
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
			roomString = [roomString stringByAppendingString:[[[self.rooms objectAtIndex:index] objectAtIndex:i] objectForKey:@"name"]];
		}
		if ([roomString length] > 0) [roomNames addObject:roomString];
		
		CPRoomRetractableSectionController* arrayController = [[CPRoomRetractableSectionController alloc] initWithArray:roomNames viewController:self];
		arrayController.title = [[self.buildings objectAtIndex:index] objectForKey:@"name"];
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
	
	NSNumber *campus_id = [User sharedAppUser].campus_id;
	[[Coffeepot shared] requestWithMethodPath:[NSString stringWithFormat:@"study/building/?campus_id=%@", campus_id] params:nil requestMethod:@"GET" success:^(CPRequest *_req, id collection) {
		
		NSMutableDictionary *mutableBuildings = [@{ @"value" : collection } mutableCopy];
		[mutableBuildings setObject:campus_id forKey:@"campus_id"];
		[mutableBuildings setObject:@"buildings" forKey:@"doc_type"];
		CouchDatabase *localDatabase = [(CPAppDelegate *)([[UIApplication sharedApplication] delegate]) localDatabase];
		CouchDocument *doc = [localDatabase documentWithID:[NSString stringWithFormat:@"buildings%@", campus_id]];
		if ([doc propertyForKey:@"_rev"]) [mutableBuildings setObject:[doc propertyForKey:@"_rev"] forKey:@"_rev"];
		RESTOperation *op = [doc putProperties:mutableBuildings];
		[op onCompletion:^{
			if (op.error) NSLog(@"%@", op.error);
		}];
		
		self.buildings = collection;
		self.rooms = nil;
		buildingIndex = 0;
		[self syncNextRooms];
		
	} error:^(CPRequest *_req, id collection, NSError *error) {
		if ([collection isKindOfClass:[NSDictionary class]] && [collection objectForKey:@"error"])
			[self showAlert:[collection objectForKey:@"error"]];//raise(-1);
		if ([collection isKindOfClass:[NSDictionary class]] && [collection objectForKey:@"error_code"])
			[self showAlert:[collection objectForKey:@"error_code"]];//raise(-1);
	}];
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

@end