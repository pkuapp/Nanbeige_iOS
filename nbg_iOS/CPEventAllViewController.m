//
//  CPEventAllViewController.m
//  nbg_iOS
//
//  Created by ZongZiWang on 12-9-1.
//  Copyright (c) 2012年 wuhaotian. All rights reserved.
//

#import "CPEventAllViewController.h"
#import "Environment.h"
#import "Coffeepot.h"
#import "Models+addon.h"
#import "CPEventViewController.h"

@interface CPEventAllViewController ()  {
	Event *eventSelected;
}

@end

@implementation CPEventAllViewController

#pragma mark - Setter and Getter methods

- (NSMutableArray *)events
{
	if (_events == nil) {
		_events = [[NSMutableArray alloc] init];
	}
	return _events;
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
	self.tableView.backgroundColor = tableBgColorPlain;
	self.title = TITLE_ALL_EVENT;
	
	if (_refreshHeaderView == nil) {
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
		view.delegate = self;
		[view setBackgroundColor:tableBgColorPlain];
		[self.tableView addSubview:view];
		_refreshHeaderView = view;
	}
	//  update the last update date
	[_refreshHeaderView refreshLastUpdatedDate];
	
	self.events = [[Event eventListDocument] propertyForKey:@"value"];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	CouchDocument *eventListDocument = [Event eventListDocument];
	if (![eventListDocument propertyForKey:@"value"]) {
		[self reloadTableViewDataSource];
	}
}

- (void)viewDidUnload
{
	[self setTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
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
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.events.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	if (nil == cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
	}
	cell.textLabel.text = [Event eventAtIndex:indexPath.row eventList:self.events].title;
	
    return cell;
}

#pragma mark - Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
	
	//  should be calling your tableviews data source model to reload
	//  put here just for demo
	_reloading = YES;
	
	[[Coffeepot shared] requestWithMethodPath:@"event/" params:nil requestMethod:@"GET" success:^(CPRequest *_req, id collection) {
		
		CouchDatabase *localDatabase = [(CPAppDelegate *)([[UIApplication sharedApplication] delegate]) localDatabase];
		
		if (!self) return ;
		
		if ([collection isKindOfClass:[NSArray class]]) {
			
			NSMutableArray *events = [[NSMutableArray alloc] init];
			for (NSDictionary *eventDict in collection) {

				Event *event = [Event eventWithID:[eventDict objectForKey:@"id"]];
				
				event.doc_type = @"event";
				event.id = [eventDict objectForKey:@"id"];
				event.title = [eventDict objectForKey:@"title"];
				event.subtitle = [eventDict objectForKey:@"subtitle"];
				event.category_id = [[eventDict objectForKey:@"category"] objectForKey:@"id"];
				event.category_name = [[eventDict objectForKey:@"category"] objectForKey:@"name"];
				event.time = [eventDict objectForKey:@"time"];
				event.organizer = [eventDict objectForKey:@"organizer"];
				event.location = [eventDict objectForKey:@"location"];
				event.follow_count = [eventDict objectForKey:@"follow_count"];

				RESTOperation *eventSaveOp = [event save];
				if (eventSaveOp && ![eventSaveOp wait])
					[self showAlert:[eventSaveOp.error description]];
				else
					[events addObject:event.document.documentID];

			}
			
			self.events = events;
			NSMutableDictionary *eventListDict = [@{ @"doc_type" : @"eventlist", @"value" : events } mutableCopy];
			CouchDocument *eventListDocument = [Event eventListDocument];
			if ([eventListDocument propertyForKey:@"_rev"]) [eventListDict setObject:[eventListDocument propertyForKey:@"_rev"] forKey:@"_rev"];
			RESTOperation *putOp = [eventListDocument putProperties:eventListDict];
			if (![putOp wait])
				[self showAlert:[putOp.error description]];
			
			[(CPAppDelegate *)[UIApplication sharedApplication].delegate hideProgressHud];
			[self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:0.5];
			
		} else {
			[(CPAppDelegate *)[UIApplication sharedApplication].delegate hideProgressHud];
			[self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:0.5];
			[self showAlert:@"返回结果不是NSArray"];
		}
		
	} error:^(CPRequest *request, NSError *error) {
		[(CPAppDelegate *)[UIApplication sharedApplication].delegate hideProgressHud];
		[self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:0.5];
		[self showAlert:[error description]];//NSLog(@"%@", [error description]);
	}];
	
	[(CPAppDelegate *)[UIApplication sharedApplication].delegate showProgressHud:@"获取活动列表中..."];
	
}

- (void)doneLoadingTableViewData{
	
	[self.tableView reloadData];
	//  model should call this when its done loading
	_reloading = NO;
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
	
}

#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
	
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
	
}

#pragma mark - EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
	
	[self reloadTableViewDataSource];
	
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	
	return _reloading; // should return if data source model is reloading
	
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	
	return [NSDate date]; // should return date data source was last changed
	
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	eventSelected = [Event eventAtIndex:indexPath.row eventList:self.events];
	[self performSegueWithIdentifier:@"EventSegue" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"EventSegue"]) {
		[segue.destinationViewController setEvent:eventSelected];
	}
}

@end