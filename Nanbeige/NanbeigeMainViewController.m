//
//  NanbeigeMainViewController.m
//  Nanbeige
//
//  Created by Wang Zhongyu on 12-7-9.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import "NanbeigeMainViewController.h"
#import "NanbeigeMainCell.h"
#import "NanbeigeItsViewController.h"

@interface NanbeigeMainViewController ()

@end

@implementation NanbeigeMainViewController
@synthesize functionArray;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	// TODO
	NSDictionary *itsDict = [[NSDictionary alloc] initWithObjectsAndKeys:@"IP网关", @"name", @"its", @"image", nil];
	NSDictionary *coursesDict = [[NSDictionary alloc] initWithObjectsAndKeys:@"课程", @"name", @"courses", @"image", nil];
	NSDictionary *roomsDict = [[NSDictionary alloc] initWithObjectsAndKeys:@"空闲教室", @"name", @"rooms", @"image", nil];
	NSDictionary *calendarDict = [[NSDictionary alloc] initWithObjectsAndKeys:@"日程", @"name", @"calendar", @"image", nil];
	NSDictionary *feedbackDict = [[NSDictionary alloc] initWithObjectsAndKeys:@"反馈", @"name", @"feedback", @"image", nil];
	
	[self setFunctionArray:[[NSArray alloc] initWithObjects:itsDict, coursesDict, roomsDict, calendarDict, feedbackDict, nil]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	[self setFunctionArray:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
	    return (interfaceOrientation == UIInterfaceOrientationPortrait);
		//return YES;
	} else {
	    return (interfaceOrientation == UIInterfaceOrientationPortrait);
	}
}

#pragma mark -
#pragma mark Table View Attributes Methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
		// TODO
		return 74;
		// TODO
	} else {
	    return 74;
	}
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	//#warning Potentially incomplete method implementation.
    // Return the number of sections.
    //return 0;
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    //return 0;
	return [self.functionArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MainTableIdentifier = @"MainTableIdentifier";
	NanbeigeMainCell *cell = [tableView dequeueReusableCellWithIdentifier: MainTableIdentifier];
	if (nil == cell) {
		cell = [[NanbeigeMainCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MainTableIdentifier];
	}
	
	NSUInteger row = [indexPath row];
	
	cell.name = [[functionArray objectAtIndex:row] objectForKey:@"name"];
	cell.image = [[functionArray objectAtIndex:row] objectForKey:@"image"];
    
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
	NanbeigeItsViewController *itsViewController = [[NanbeigeItsViewController alloc] initWithStyle:UITableViewStyleGrouped];
	[self.navigationController pushViewController:itsViewController animated:YES];
	/*
	 NSUInteger row = [indexPath row];
	 NSString *rowValue = [[functionArray objectAtIndex:row] objectForKey:@"name"];
	 */
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
