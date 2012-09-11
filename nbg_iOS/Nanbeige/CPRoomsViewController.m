//
//  CPRoomsViewController.m
//  CP
//
//  Created by ZongZiWang on 12-8-9.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import "CPRoomsViewController.h"
#import "Environment.h"
#import "Coffeepot.h"
#import "Models+addon.h"
#import "QueryResultsController.h"

@interface CPRoomsViewController () {
	NSDate *date;
	NSInteger buildingIndex;
	NSMutableArray *roomsOfBuilding;
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
	
	self.tableView.backgroundColor = tableBgColorPlain;
	self.tabBarController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"教学楼" style:UIBarButtonItemStyleBordered target:nil action:nil];
	
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
	
    NSArray *vcarray = self.navigationController.viewControllers;
    NSString *back_title = [[vcarray objectAtIndex:vcarray.count-2] title];
	self.navigationItem.leftBarButtonItem = [UIBarButtonItem styledBackBarButtonItemWithTitle:back_title target:self.navigationController selector:@selector(popViewControllerAnimated:)];
	self.navigationItem.rightBarButtonItem = [UIBarButtonItem styledBlueBarButtonItemWithTitle:@"日期" target:self selector:@selector(onDatePick:)];
	
	CouchDatabase *localDatabase = [(CPAppDelegate *)([[UIApplication sharedApplication] delegate]) localDatabase];
	CouchDocument *doc = [localDatabase documentWithID:[NSString stringWithFormat:@"buildings-%@", [User sharedAppUser].campus_id]];
	self.buildings = [[doc properties] objectForKey:@"value"];
	
	doc = [localDatabase documentWithID:@"rooms"];
	self.rooms = [[doc properties] objectForKey:@"value"];
	
	[self reloadRooms];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	if (![self.rooms count]) {
		[self reloadTableViewDataSource];
	}
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

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	[(CPAppDelegate *)[UIApplication sharedApplication].delegate hideProgressHud];
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
	return roomsOfBuilding.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray* rooms = [roomsOfBuilding objectAtIndex:section];
    return rooms.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	if (nil == cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
	}
	
	if (indexPath.row == 0) {
		cell.selectionStyle = UITableViewCellSelectionStyleBlue;
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		
		cell.textLabel.text = [[self.buildings objectAtIndex:indexPath.section] objectForKey:@"name"];
		cell.detailTextLabel.text = nil;
		
		[self addSeparatorAtView:cell.contentView OffsetY:0 WithColor:separatorColorTitleNoContentHeader1];
		[self addSeparatorAtView:cell.contentView OffsetY:TIMETABLESEPARATORHEIGHT WithColor:separatorColorTitleNoContentHeader2];
		if ([[roomsOfBuilding objectAtIndex:indexPath.section] count] == 0)
			[self addSeparatorAtView:cell.contentView OffsetY:cell.contentView.frame.size.height - TIMETABLESEPARATORHEIGHT WithColor:separatorColorTitleNoContentFooter];
		else [self addSeparatorAtView:cell.contentView OffsetY:cell.contentView.frame.size.height - TIMETABLESEPARATORHEIGHT WithColor:separatorColorTitleHasContentFooter];
		
	} else {
		
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.textLabel.shadowColor = [UIColor whiteColor];
		cell.textLabel.shadowOffset = CGSizeMake(0, 1);
		cell.textLabel.textColor = [UIColor colorWithRed:120/255.0 green:116/255.0 blue:100/255.0 alpha:1.0];
		cell.textLabel.backgroundColor = [UIColor clearColor];
		cell.textLabel.font = [UIFont boldSystemFontOfSize:20];
		cell.contentView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg-TableView"]];
		
		cell.textLabel.text = [[roomsOfBuilding objectAtIndex:indexPath.section] objectAtIndex:indexPath.row-1];
		cell.detailTextLabel.text = nil;
		
		if (indexPath.row == 1) {
			[self addSeparatorAtView:cell.contentView OffsetY:0 WithColor:separatorColorContentHeader1];
			[self addSeparatorAtView:cell.contentView OffsetY:TIMETABLESEPARATORHEIGHT WithColor:separatorColorContentHeader2];
			[self addSeparatorAtView:cell.contentView OffsetY:2*TIMETABLESEPARATORHEIGHT WithColor:separatorColorContentHeader3];
		} else {
			[self addSeparatorAtView:cell.contentView OffsetY:0 WithColor:separatorColorContentMiddleHeader];
		}
		
		if (indexPath.row == [[roomsOfBuilding objectAtIndex:indexPath.section] count]) {
			[self addSeparatorAtView:cell.contentView OffsetY:cell.contentView.frame.size.height - 2 * TIMETABLESEPARATORHEIGHT WithColor:separatorColorContentFooter1];
			[self addSeparatorAtView:cell.contentView OffsetY:cell.contentView.frame.size.height - TIMETABLESEPARATORHEIGHT WithColor:separatorColorContentFooter2];
		} else {
			[self addSeparatorAtView:cell.contentView OffsetY:cell.contentView.frame.size.height - TIMETABLESEPARATORHEIGHT WithColor:separatorColorContentMiddleFooter];
		}
	}
	
    return cell;
}

- (UIView *)addSeparatorAtView:(UIView *)view
					   OffsetY:(CGFloat)y
					 WithColor:(UIColor *)color
{
	UIView *separator = [[UIView alloc] init];
	separator.backgroundColor = color;
	separator.frame = CGRectMake(0, y, TIMETABLEWIDTH, TIMETABLESEPARATORHEIGHT);
	[view addSubview:separator];
	return separator;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.row) return ;
    QueryResultsController *qrc = [[QueryResultsController alloc] initWithNibName:@"QueryResults" bundle:nil];
    qrc.nameLocation = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
    [self.navigationController pushViewController:qrc animated:YES];
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
			if (op.error) [self showAlert:[op.error description]];
		}];
		
		[self reloadRooms];
		
		[(CPAppDelegate *)[UIApplication sharedApplication].delegate hideProgressHud];
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
		
	} error:^(CPRequest *request, NSError *error) {
		[(CPAppDelegate *)[UIApplication sharedApplication].delegate hideProgressHud];
		[self showAlert:[error description]];//NSLog(@"%@", [error description]);
	}];
}

- (void)reloadRooms
{
	roomsOfBuilding = [[NSMutableArray alloc] init];
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
		
		[roomsOfBuilding addObject:roomNames];
	}
}

#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
	
	//  should be calling your tableviews data source model to reload
	//  put here just for demo
	_reloading = YES;
    
#warning always use 8 as campus_id in test
	NSNumber *campus_id = [User sharedAppUser].campus_id;
	[[Coffeepot shared] requestWithMethodPath:[NSString stringWithFormat:@"study/building/?campus_id=%@", @8] params:nil requestMethod:@"GET" success:^(CPRequest *_req, id collection) {
		
		NSMutableDictionary *mutableBuildings = [@{ @"value" : collection } mutableCopy];
		[mutableBuildings setObject:campus_id forKey:@"campus_id"];
		[mutableBuildings setObject:@"buildings" forKey:@"doc_type"];
		CouchDatabase *localDatabase = [(CPAppDelegate *)([[UIApplication sharedApplication] delegate]) localDatabase];
		CouchDocument *doc = [localDatabase documentWithID:[NSString stringWithFormat:@"buildings-%@", campus_id]];
		if ([doc propertyForKey:@"_rev"]) [mutableBuildings setObject:[doc propertyForKey:@"_rev"] forKey:@"_rev"];
		RESTOperation *op = [doc putProperties:mutableBuildings];
		[op onCompletion:^{
			if (op.error) [self showAlert:[op.error description]];
		}];
		
		self.buildings = collection;
		self.rooms = nil;
		buildingIndex = 0;
		[self syncNextRooms];
		
	} error:^(CPRequest *request, NSError *error) {
		[(CPAppDelegate *)[UIApplication sharedApplication].delegate hideProgressHud];
		[self showAlert:[error description]];//NSLog(@"%@", [error description]);
	}];
	
	[(CPAppDelegate *)[UIApplication sharedApplication].delegate showProgressHud:@"获取自习室列表中..."];
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