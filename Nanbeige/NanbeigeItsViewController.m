//
//  NanbeigeItsViewController.m
//  Nanbeige
//
//  Created by Wang Zhongyu on 12-7-9.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import "NanbeigeItsViewController.h"
#import "Environment.h"
#import "NanbeigeAppDelegate.h"
#import "ASIHTTPRequest.h"
#import "SystemHelper.h"
#import "RegexKitLite.h"
#import "NanbeigeIPGateHelper.h"
#import "ModalAlert.h"
#import "AppUser.h"

#define _keyAutoDisconnect @"AutoDisconnect"
#define _keyAlwaysGlobal @"AlwaysGlobal"
#define _keyAccountState @"IPGateAccount"
#define _keyIPGateBalance @"余额"
#define _keyIPGateType @"Type"
#define _keyIPGateTimeLeft @"timeLeft"
#define _keyIPGateTimeConsumed @"Time"
#define _keyIPGateUpdatedTime @"IPGateUpdatedTime"

@interface NanbeigeItsViewController ()

@end

@implementation NanbeigeItsViewController
@synthesize Username;
@synthesize Password;
@synthesize connector;
@synthesize swAutoDisconnect;
@synthesize swAlwaysGlobal;
@synthesize gateStateDictionary;
@synthesize defaults;
@synthesize numStatus;
@synthesize labelStatus;
@synthesize labelWarning;
@synthesize progressHub;
@synthesize delegate;

#pragma mark - getter and setter Override

- (NSObject<AppCoreDataProtocol,AppUserDelegateProtocol,ReachabilityProtocol,PABezelHUDDelegate> *)delegate {
    if (delegate == nil) {
        delegate = (NSObject<AppCoreDataProtocol,AppUserDelegateProtocol,ReachabilityProtocol,PABezelHUDDelegate> *)[UIApplication sharedApplication].delegate;
    }
    return delegate;
}
- (MBProgressHUD *)progressHub{
    if (progressHub == nil) {
        progressHub = self.delegate.progressHub;
    }
    return progressHub;
}
- (void)setNumStatus:(NSInteger)anumStatus{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"M月d日h:mm";
    
    NSDate *dateUpdate = [NSDate date];
    
    NSString *stringUpdateStatus = [NSString stringWithFormat:@"更新于：%@",[formatter stringFromDate:dateUpdate]];
    
    [self.gateStateDictionary setObject:stringUpdateStatus forKey:_keyIPGateUpdatedTime];
	
    self.labelWarning.text = stringUpdateStatus;
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    switch (anumStatus) {
        case 0:
            self.labelStatus.text = @"当前网络状态未知";
            cell.textLabel.text = @"网络状态未知";
            break;
        case 1:
            self.labelStatus.text = @"当前可访问校园网";
            cell.textLabel.text = @"可访问校园网";
            break;
        case 2:
            self.labelStatus.text = @"当前可访问校园网、免费网址";
            cell.textLabel.text = @"可访问免费网址";
            break;
        case 3:
            self.labelStatus.text = @"当前可访问校园网、免费网址、收费网址";
            cell.textLabel.text = @"可访问收费网址";
            break;
        default:
            break;
    }
    [self.tableView reloadData];
    numStatus = anumStatus;
}
/*
- (NITableViewModel *)detailDataSource {
    if (detailDataSource == nil) {
        NSMutableArray *arraySections = [NSMutableArray arrayWithCapacity:6];
		
        [arraySections addObject:self.labelWarning.text];        
        if ([self.gateStateDictionary objectForKey:_keyIPGateTimeLeft] != nil) {
            
            
            if ([self.gateStateDictionary objectForKey:_keyIPGateType] == @"NO") {
                [arraySections addObject:[NSArray arrayWithObject:@"10元国内地址任意游"]];
            }
            else if ([[self.gateStateDictionary objectForKey:_keyIPGateTimeLeft] isEqualToString:@"不限时"]){
                [arraySections addObject: [NSArray arrayWithObject:@"90元不限时"]];
            }
            else {
                [arraySections addObject:[NSArray arrayWithObject:[self.gateStateDictionary objectForKey:_keyIPGateType]]];
                [arraySections addObject:[NSArray arrayWithObject:[NSString stringWithFormat:@"%@小时",[self.gateStateDictionary objectForKey:_keyIPGateTimeConsumed]]]];
                [arraySections addObject:[NSArray arrayWithObject:[self.gateStateDictionary objectForKey:_keyIPGateTimeLeft]]];
            }
            
            [arraySections addObjectsFromArray:[NSArray arrayWithObjects:@"",[NSArray arrayWithObject:[NSString stringWithFormat:@"%@元",[self.gateStateDictionary objectForKey:_keyIPGateBalance]]],nil]];
            
			
            
            detailDataSource = [[NITableViewModel alloc] initWithSectionedArray:arraySections delegate:self];               
		}
    }
    return detailDataSource;
}
 */
- (UILabel *)labelStatus{
    if (labelStatus == nil) {
        labelStatus = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 280, 30)];
        labelStatus.backgroundColor = [UIColor clearColor];
        labelStatus.textAlignment = UITextAlignmentCenter;
        labelWarning.font = [UIFont systemFontOfSize:14];
        labelStatus.text = @"当前网络状态未知";
    }
    return labelStatus;
}
- (UILabel *)labelWarning{
    if (labelWarning == nil) {
        labelWarning = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 280, 30)];
        labelWarning.backgroundColor = [UIColor clearColor];
        labelWarning.textAlignment = UITextAlignmentCenter;
        labelWarning.font = [UIFont systemFontOfSize:14];
        NSString *text = [defaults objectForKey:@"stringUpdateStatus"];
        if (!text) {
            text = @"账户状态未知";
        }
        labelWarning.text = text;
		
		//        if (labelStatus.text == nil || [labelStatus.text isEqualToString:@"(null)"]) {
		//
		//            labelWarning.text = @"账户状态未知";
		//        }
    }
    return labelWarning;
}
#pragma mark - IPGateDelegate setup

- (void)didConnectToIPGate{
	
}

- (void)didLoseConnectToIpGate{
    
}



- (void)disconnectSuccess{
    if (_hasSilentCallback) {
        _hasSilentCallback = NO;
        return;
    }
    
    self.numStatus = 1;
    
    [self.progressHub hide:NO];
    
    self.progressHub.labelText = @"已断开全部连接";
    
    self.progressHub.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"alert-yes.png"]] autorelease];
    
    self.progressHub.mode = MBProgressHUDModeCustomView;
	
    [self.progressHub show:YES];
    
    [self.progressHub hide:YES afterDelay:1];
}

- (void)connectFreeSuccess{
    
    UITableViewCell *cell;
	
    NSDictionary *dictDetail = self.connector.dictDetail;
    
    if (![[dictDetail objectForKey:@"Type"] isEqualToString:@"NO"]) {
        
        cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3]];
        
        NSString *accountTimeLeftString = [NSString stringWithFormat:@"包月剩余%@小时",[dictDetail objectForKey:@"timeLeft"]];
        
        cell.detailTextLabel.text = accountTimeLeftString;
        
        cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        
		//        cell.imageView.image = [UIImage imageNamed:@"status-2"];
        
        cell.textLabel.text = @"可访问免费地址";
        
        self.numStatus = 2;
        
		//        NSLog(@"%@",dictDetail);
    }
    progressHub.animationType = MBProgressHUDAnimationZoom;
    
    self.progressHub.labelText = @"已连接到免费地址";
    
    self.progressHub.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"alert-yes.png"]] autorelease];
    
    self.progressHub.mode = MBProgressHUDModeCustomView;
	
    [self.progressHub hide:YES afterDelay:0.5];
    
    NSLog(@"ConnectToFreeDone");
    [self saveAccountState];
	
}
- (void)connectFailed
{
    if (self.connector.error == IPGateErrorOverCount) {
        self.progressHub.mode = MBProgressHUDModeIndeterminate;
        self.progressHub.labelText = @"连接数超过预定值";
        if ([ModalAlert confirm:@"断开别处的连接" withMessage:@"断开别处的连接才能在此处建立连接"]){
            _hasSilentCallback = YES;
            
            [self.connector disConnect];
            
            self.progressHub.labelText = @"正在断开重连";
            
            [self.connector reConnect];
			//            self.progressHub.mode = MBProgressHUDModeIndeterminate;
            
        }
        else [self.progressHub hide:YES afterDelay:0.5];
		
        
    }
    else {
        self.progressHub.labelText = [self.connector.dictResult objectForKey:@"REASON"];
		//        self.progressHub.mode = MBProgressHUDModeIndeterminate;
		//        [self.progressHub show:YES];
        self.progressHub.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"alert-no.png"]] autorelease];
        self.progressHub.mode = MBProgressHUDModeCustomView;
		
        [self.progressHub hide:YES afterDelay:0.5];
        
        NSLog(@"Reason %@",[self.connector.dictResult objectForKey:@"REASON"]);
    }
    if (self.connector.error != IPGateErrorTimeout) {
		//        [self saveAccountState];
    }
	
}

- (void)connectGlobalSuccess {
    
    UITableViewCell *cell;
    
    NSDictionary *dictDetail = self.connector.dictDetail;
    
    if (![[dictDetail objectForKey:_keyIPGateType] isEqualToString:@"NO"]) {
        
        cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3]];
        
        NSString *accountTimeLeftString = [dictDetail objectForKey:@"timeLeft"];
        
        cell.detailTextLabel.text = accountTimeLeftString;
        
        cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        
		//        cell.imageView.image = [UIImage imageNamed:@"status-2"];
        
        cell.textLabel.text = @"可访问收费地址";
        
        self.numStatus = 3;
		//        NSLog(@"%@",dictDetail);
    }
	progressHub.animationType = MBProgressHUDAnimationZoom;
	
	self.progressHub.labelText = @"已连接到收费地址";
    
	self.progressHub.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"alert-yes.png"]] autorelease];
    
	self.progressHub.mode = MBProgressHUDModeCustomView;
    
	[self.progressHub hide:YES afterDelay:0.5];
    [self saveAccountState];
    NSLog(@"ConnectToGlobalDone");
}

- (void)saveAccountState {
    [gateStateDictionary setValuesForKeysWithDictionary:self.connector.dictResult];
    [gateStateDictionary setValuesForKeysWithDictionary:self.connector.dictDetail];
    
    [self.defaults setObject:gateStateDictionary forKey:_keyAccountState];
	
}
#pragma mark - private ControlEvent Setup

- (void)configAutoDisconnectDidChanged:(UISwitch *)sender
{
    [gateStateDictionary setObject:[NSNumber numberWithBool:sender.on] forKey:_keyAutoDisconnect];
    
    [defaults setObject:gateStateDictionary forKey:_keyAccountState];
}
-(void)configAlwaysGlobalDidChanged:(UISwitch *)sender
{
    [gateStateDictionary setObject:[NSNumber numberWithBool:sender.on] forKey:_keyAlwaysGlobal];
    
    [defaults setObject:gateStateDictionary forKey:_keyAccountState];
    
    [self.tableView beginUpdates];
    
    if (sender.on) {
        
        NSArray *deleteArray = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:1]];
        
        [self.tableView deleteRowsAtIndexPaths:deleteArray withRowAnimation:UITableViewRowAnimationFade];
    }
    else {
        
        NSArray *insertArray = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:1]];
        
        [self.tableView insertRowsAtIndexPaths:insertArray withRowAnimation:UITableViewRowAnimationFade];
    }
    [self.tableView endUpdates];
}

#pragma mark - View Lifecycle

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)dealloc
{
    [Username release];
    [Password release];
    [swAutoDisconnect release];
    [swAlwaysGlobal release];
    [gateStateDictionary release];
    [super dealloc];
}
- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	self.defaults = [NSUserDefaults standardUserDefaults];
	
	self.Username = self.delegate.appUser.deanid;//[defaults objectForKey:@"Username"];
    self.Password = self.delegate.appUser.password;
    
	self.gateStateDictionary = [NSMutableDictionary dictionaryWithDictionary:[defaults objectForKey:_keyAccountState]];
	self.connector = [[NanbeigeIPGateHelper alloc] init];
	self.connector.delegate = self;
	
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.numStatus = 0;
    self.Username = nil;
    self.Password = nil;
    self.swAlwaysGlobal = nil;
    self.swAutoDisconnect = nil;
    self.gateStateDictionary = nil;
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
{    progressHub.animationType = MBProgressHUDAnimationFade;
	
    switch (indexPath.section) {
        case 0:
			break;
        case 1:
            if ([[self.gateStateDictionary objectForKey:_keyAutoDisconnect] boolValue]) {
                [self.connector disConnect];
                _hasSilentCallback = YES;
            }
            
            if ([[self.gateStateDictionary objectForKey:@"AlwaysGlobal"] boolValue] && indexPath.row == 0) {
                [self.connector connectGlobal];
                
                [self showProgressHubWithTitle:@"正连接到收费地址"];
				
            }
            else if (indexPath.row == 0) {
                [self.connector connectFree];
                [self showProgressHubWithTitle:@"正连接到免费地址"];
            }
            else if (indexPath.row == 1){
                [self.connector connectGlobal];
				
                [self showProgressHubWithTitle:@"正连接到收费地址"];
            }
            break;
        case 2:
            [self.connector disConnect];
            [self showProgressHubWithTitle:@"正断开全部连接"];
            break;
        case 3:
            break;
        case 4:
        default:
            break;
	}
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.selected = NO;
}

- (void)showProgressHubWithTitle:(NSString *)title{
    self.progressHub.mode = MBProgressHUDModeIndeterminate;
    self.progressHub.delegate = self;
    self.progressHub.labelText = title;
    [self.progressHub show:YES];
}

@end
