//
//  NanbeigeMainViewController.m
//  Nanbeige
//
//  Created by Wang Zhongyu on 12-7-7.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import "NanbeigeMainViewController.h"
#import "NanbeigeMainCell.h"
#import "NanbeigeItsViewController.h"

@interface NanbeigeMainViewController ()

@end

@implementation NanbeigeMainViewController
@synthesize functionArray;

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

#pragma mark -
#pragma mark Table View Data Source Methods
- (NSInteger)tableView:(UITableView *)tableView
	numberOfRowsInSection:(NSInteger)section {
	return [self.functionArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
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

#pragma mark -
#pragma mark Table View Delegate Methods
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSUInteger row = [indexPath row];
	NanbeigeItsViewController *itsViewController = [[NanbeigeItsViewController alloc] initWithStyle:UITableViewStyleGrouped];
	[self.navigationController pushViewController:itsViewController animated:YES];
	/*NSString *rowValue = [[functionArray objectAtIndex:row] objectForKey:@"name"];
	NSString *message = [[NSString alloc] initWithFormat: @"You selected %@", rowValue];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Row Selected!"
													message:message
												   delegate:nil cancelButtonTitle:@"Yes I Did"
										  otherButtonTitles:nil]; [alert show];*/
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end