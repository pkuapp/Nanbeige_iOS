//
//  CPChangeMainOrderViewController.m
//  CP
//
//  Created by Wang Zhongyu on 12-7-16.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import "CPChangeMainOrderViewController.h"
#import "CPMainViewController.h"
#import "UIBarButtonItem+StyledButton.h"

@interface CPChangeMainOrderViewController () {
	NSString *oldorderStr;
}

@end

@implementation CPChangeMainOrderViewController
@synthesize functionOrder;
@synthesize functionArray;
@synthesize cancelButton;
@synthesize changeButton;

#pragma mark - View Lifecycle

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
    
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem styledPlainBarButtonItemWithTitle:@"取消" target:self selector:@selector(onCancelButtonPressed:)];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem styledBlueBarButtonItemWithTitle:@"完成" target:self selector:@selector(onChangeButtonPressed:)];

	UINavigationController *nc = [self.tabBarController.childViewControllers objectAtIndex:1];
	CPMainViewController *nmvc = (CPMainViewController *)(nc.topViewController);
	[nmvc.functionArray indexOfObject:0];
	functionArray = [[NSArray alloc] initWithArray:nmvc.functionArray];
	functionOrder = [[NSArray alloc] initWithArray:nmvc.functionOrder];
	
	self.tableView.backgroundColor = tableBgColorPlain;
	[self.tableView setEditing:!self.tableView.editing animated:YES];
	
	oldorderStr = [[NSUserDefaults standardUserDefaults] valueForKey:kMAINORDERKEY];
}

- (void)viewDidUnload
{
	[self setCancelButton:nil];
	[self setChangeButton:nil];
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return functionArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSUInteger row = indexPath.row;
	NSUInteger functionIndex = [((NSString *)([functionOrder objectAtIndex:row])) integerValue];
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (nil == cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}
	
	cell.textLabel.text = [[functionArray objectAtIndex:functionIndex] valueForKey:@"name"];
//	cell.imageView.image = [UIImage imageNamed:[[functionArray objectAtIndex:functionIndex] valueForKey:@"image"]];
	
    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellEditingStyleNone;
}


// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
	NSMutableArray *newOrder = [self.functionOrder mutableCopy];
	NSUInteger fromRow = [fromIndexPath row];
	NSUInteger toRow = [toIndexPath row];
	id object = [newOrder objectAtIndex:fromRow];
	[newOrder removeObjectAtIndex:fromRow];
	[newOrder insertObject:object atIndex:toRow];
	self.functionOrder = [[NSArray alloc] initWithArray:newOrder];
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
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
}

#pragma mark - Button controllerAction

- (IBAction)onChangeButtonPressed:(id)sender {
	NSString * neworderStr = [functionOrder componentsJoinedByString:@","];
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setValue:neworderStr forKey:kMAINORDERKEY];
	[defaults synchronize];
	
	if (![neworderStr isEqualToString:oldorderStr]) {
		[[[UIAlertView alloc] initWithTitle:nil message:@"已修改" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil] show];
	} else {
		[[[UIAlertView alloc] initWithTitle:nil message:@"未变化" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil] show];
	}
	[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onCancelButtonPressed:(id)sender {
	[self.navigationController popViewControllerAnimated:YES];
}

@end
