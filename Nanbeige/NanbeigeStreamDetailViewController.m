//
//  NanbeigeStreamDetailViewController.m
//  Nanbeige
//
//  Created by Wang Zhongyu on 12-7-26.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import "NanbeigeStreamDetailViewController.h"
#import "Environment.h"

@interface NanbeigeStreamDetailViewController ()

@end

@implementation NanbeigeStreamDetailViewController
@synthesize tableView = _tableView;
@synthesize toolbar = _toolbar;
@synthesize splitViewBarButtonItem = _splitViewBarButtonItem;
@synthesize course = _course;

- (void)setSplitViewBarButtonItem:(UIBarButtonItem *)splitViewBarButtonItem
{
	if (_splitViewBarButtonItem != splitViewBarButtonItem) {
		NSMutableArray *toolbarItems = [self.toolbar.items mutableCopy];
		if (_splitViewBarButtonItem) [toolbarItems removeObject:_splitViewBarButtonItem];
		if (splitViewBarButtonItem) [toolbarItems insertObject:splitViewBarButtonItem atIndex:0];
		self.toolbar.items = toolbarItems;
		_splitViewBarButtonItem = splitViewBarButtonItem;
	}
}

- (void)setCourse:(NSDictionary *)course
{
	if (_course != course) {
		_course = course;
		[self.tableView reloadData];
	}
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
	
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	self.navigationController.navigationBar.backgroundColor = navBarBgColor;
	self.tableView.backgroundColor = tableBgColor;
	
}

- (void)viewDidUnload
{
	[self setTableView:nil];
	[self setToolbar:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
	    return YES;
	} else {
	    return (interfaceOrientation == UIInterfaceOrientationPortrait);
	}
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.course.count ? 8 : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	switch (section) {
		case 7:
			return [[self.course objectForKey:@"week"] count];
		case 3:
			return [[self.course objectForKey:@"lessons"] count];
		case 5:
			return [[self.course objectForKey:@"ta"] count];
		case 0:
			return [[self.course objectForKey:@"teacher"] count];
		case 1:
		case 2:
		case 4:
		case 6:
			return 1;
		default:
			break;
	}
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	switch (section) {
		case 7:
			return @"上课周数";
		case 3:
			return @"上课信息";
		case 5:
			return @"助教";
		case 0:
			return @"授课老师";
		case 1:
			return @"学分";
		case 2:
			return @"课程名";
		case 4:
			return @"原始id";
		case 6:
			return @"课程id";
		default:
			break;
	}
	return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *identifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	if (nil == cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
	}
	NSArray *weekdays = [[NSArray alloc] initWithObjects:@"周日", @"周一", @"周二", @"周三", @"周四", @"周五", @"周六", nil];
	switch (indexPath.section) {
		case 7:
			cell.textLabel.text = [[[self.course objectForKey:@"week"] objectAtIndex:indexPath.row] stringValue];
			break;
		case 3:
			cell.textLabel.text = [NSString stringWithFormat:@"地点:%@    时间:%@    起始周:%d    结束周:%d", [[[self.course objectForKey:@"lessons"] objectAtIndex:indexPath.row] objectForKey:@"location"], [weekdays objectAtIndex:[[[[self.course objectForKey:@"lessons"] objectAtIndex:indexPath.row] objectForKey:@"day"] intValue]], [[[[self.course objectForKey:@"lessons"] objectAtIndex:indexPath.row] objectForKey:@"start"] intValue], [[[[self.course objectForKey:@"lessons"] objectAtIndex:indexPath.row] objectForKey:@"end"] intValue]];
			break;
		case 5:
			cell.textLabel.text = [[self.course objectForKey:@"ta"] objectAtIndex:indexPath.row];
			break;
		case 0:
			cell.textLabel.text = [[self.course objectForKey:@"teacher"] objectAtIndex:indexPath.row];
			break;
		case 1:
			cell.textLabel.text = [[self.course objectForKey:@"credit"] stringValue];
			break;
		case 2:
			cell.textLabel.text = [self.course objectForKey:@"name"];
			break;
		case 4:
			cell.textLabel.text = [self.course objectForKey:@"orig_id"];
			break;
		case 6:
			cell.textLabel.text = [[self.course objectForKey:@"id"] stringValue];
			break;
		default:
			break;
	}
    
    return cell;
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

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)showAlert:(NSString*)message{
	UIAlertView* alertView =[[UIAlertView alloc] initWithTitle:nil 
													   message:message
													  delegate:nil
											 cancelButtonTitle:@"确定"
											 otherButtonTitles:nil];
	[alertView show];
}
- (IBAction)renrenPost:(id)sender {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	if ([defaults valueForKey:kRENRENIDKEY] == nil) {
		[self showAlert:@"人人未授权！请到设置中授权"];
		self.tabBarController.selectedIndex = 2;
	} else {
		[self performSegueWithIdentifier:@"RenrenPostSegue" sender:self];
	}
}

- (IBAction)weiboPost:(id)sender {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	if ([defaults valueForKey:kWEIBOIDKEY] == nil) {
		[self showAlert:@"微博未授权！请到设置中授权"];
		self.tabBarController.selectedIndex = 2;
	} else {
		[self performSegueWithIdentifier:@"WeiboPostSegue" sender:self];
	}
}

@end
