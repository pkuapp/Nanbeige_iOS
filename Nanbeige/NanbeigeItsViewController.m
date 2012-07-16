//
//  NanbeigeItsViewController.m
//  Nanbeige
//
//  Created by Wang Zhongyu on 12-7-9.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import "NanbeigeItsViewController.h"

@interface NanbeigeItsViewController () {
	BOOL bViewDidLoad;
}

@end

@implementation NanbeigeItsViewController
@synthesize detailGateInfo;
@synthesize Username;
@synthesize Password;
@synthesize connector;
@synthesize gateStateDictionary;
@synthesize defaults;
@synthesize numStatus;
@synthesize labelStatus;
@synthesize labelWarning;
@synthesize progressHub;
@synthesize delegate;
@synthesize connectFree;
@synthesize connectGlobal;
@synthesize disconnectAll;

#pragma mark - getter and setter Override

-(NSMutableDictionary *)gateStateDictionary
{
	return [NSMutableDictionary dictionaryWithDictionary:[defaults objectForKey:_keyAccountState]];
}
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
	[defaults setObject:gateStateDictionary forKey:_keyAccountState];
	
    self.labelWarning.text = stringUpdateStatus;
    
	[detailGateInfo setBackgroundColor:gateConnectingBtnColor];
    switch (anumStatus) {
        case 0:
            self.labelStatus.text = @"当前网络状态未知";
			[detailGateInfo setTitle:[detailGateInfo.titleLabel.text stringByReplacingOccurrencesOfRegex:@".*\n" withString:@"网络状态未知\n"] forState:UIControlStateNormal];
            break;
        case 1:
            self.labelStatus.text = @"当前可访问校园网";
			[detailGateInfo setTitle:[detailGateInfo.titleLabel.text stringByReplacingOccurrencesOfRegex:@".*\n" withString:@"可访问校园网\n"] forState:UIControlStateNormal];
            break;
        case 2:
            self.labelStatus.text = @"当前可访问校园网、免费网址";
			[detailGateInfo setTitle:[detailGateInfo.titleLabel.text stringByReplacingOccurrencesOfRegex:@".*\n" withString:@"可访问免费网址\n"] forState:UIControlStateNormal];
            break;
        case 3:
            self.labelStatus.text = @"当前可访问校园网、免费网址、收费网址";
			[detailGateInfo setTitle:[detailGateInfo.titleLabel.text stringByReplacingOccurrencesOfRegex:@".*\n" withString:@"可访问收费网址\n"] forState:UIControlStateNormal];
            break;
        default:
            break;
    }
    [self.tableView reloadData];
    numStatus = anumStatus;
}
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
    NSDictionary *dictDetail = self.connector.dictDetail;
    if (![[dictDetail objectForKey:@"Type"] isEqualToString:@"NO"]) {
        NSString *accountTimeLeftString;
		if ([[dictDetail objectForKey:@"timeLeft"] isEqualToString:@"不限时"]) {
			accountTimeLeftString = [dictDetail objectForKey:@"timeLeft"];
		} else {
			accountTimeLeftString = [NSString stringWithFormat:@"包月剩余%@小时",[dictDetail objectForKey:@"timeLeft"]];
		}
		[detailGateInfo setBackgroundColor:gateConnectingBtnColor];
        [detailGateInfo setTitle:[@"可访问免费地址\n" stringByAppendingString:accountTimeLeftString] forState:UIControlStateNormal];
        self.numStatus = 2;
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
        }
        else [self.progressHub hide:YES afterDelay:0.5];
    }
    else {
		if ([self.connector.dictResult objectForKey:@"REASON"] == nil) {
			self.progressHub.labelText = @"未知错误";
		} else {
			self.progressHub.labelText = [self.connector.dictResult objectForKey:@"REASON"];
		}
        self.progressHub.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"alert-no.png"]] autorelease];
        self.progressHub.mode = MBProgressHUDModeCustomView;
        [self.progressHub hide:YES afterDelay:0.5];
        NSLog(@"Reason %@",[self.connector.dictResult objectForKey:@"REASON"]);
    }
    if (self.connector.error != IPGateErrorTimeout) {
		//[self saveAccountState];
    }
}
- (void)connectGlobalSuccess {
    NSDictionary *dictDetail = self.connector.dictDetail;    
    if (![[dictDetail objectForKey:_keyIPGateType] isEqualToString:@"NO"]) {
		NSString *accountTimeLeftString;
        if ([[dictDetail objectForKey:@"timeLeft"] isEqualToString:@"不限时"]) {
			accountTimeLeftString = [dictDetail objectForKey:@"timeLeft"];
		} else {
			accountTimeLeftString = [NSString stringWithFormat:@"包月剩余%@小时",[dictDetail objectForKey:@"timeLeft"]];
		}
        
		[detailGateInfo setBackgroundColor:gateConnectingBtnColor];
		[detailGateInfo setTitle:[@"可访问收费地址\n" stringByAppendingString:accountTimeLeftString] forState:UIControlStateNormal];
        self.numStatus = 3;
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
    [self.defaults setObject:gateStateDictionary forKey:_keyAccountState];
}

#pragma mark - private ControlEvent Setup
- (IBAction)configAutoDisconnectDidChanged:(UISwitch *)sender {
    [gateStateDictionary setObject:[NSNumber numberWithBool:sender.on] forKey:_keyAutoDisconnect];
    
    [defaults setObject:gateStateDictionary forKey:_keyAccountState];
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
    [connectFree release];
	[connectGlobal release];
	[disconnectAll release];
	[detailGateInfo release];
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
    
	self.connector = [[NanbeigeIPGateHelper alloc] init];
	self.connector.delegate = self;
	
	[connectFree setBackgroundColor:[UIColor colorWithRed:80/255.0 green:160/255.0 blue:90/255.0 alpha:1.0]];
	[connectGlobal setBackgroundColor:[UIColor colorWithRed:80/255.0 green:160/255.0 blue:90/255.0 alpha:1.0]];
	[disconnectAll setBackgroundColor:[UIColor colorWithRed:176/255.0 green:92/255.0 blue:69/255.0 alpha:1.0]];
	
	[detailGateInfo setBackgroundColor:gateConnectedBtnColor];
	detailGateInfo.titleLabel.textAlignment = UITextAlignmentCenter;
	detailGateInfo.titleLabel.lineBreakMode = UILineBreakModeWordWrap;
	if ([self.gateStateDictionary objectForKey:_keyIPGateTimeConsumed] != nil) {
		[detailGateInfo setTitle:[NSString stringWithFormat:@"包月剩余：%@小时\n%@", [self.gateStateDictionary objectForKey:_keyIPGateTimeConsumed], self.labelWarning.text] forState:UIControlStateNormal];
	} else {
		[detailGateInfo setTitle:[NSString stringWithFormat:@"包月剩余时间未知\n%@", self.labelWarning.text] forState:UIControlStateNormal];
	}
	//[detailGateInfo setTitle:@"当前网络状态未知\n用户状态未知" forState:UIControlStateNormal];
	
	bViewDidLoad = YES;
	
}
- (void)viewDidAppear:(BOOL)animated
{
	if (bViewDidLoad && ([self.defaults valueForKey:kITSIDKEY] == nil || ((NSString *)([self.defaults valueForKey:kITSIDKEY])).length == 0)) {
		[self performSegueWithIdentifier:@"ItsLoginSegue" sender:self];
		bViewDidLoad = NO;
	}
}
- (void)viewDidUnload
{
	[self setConnectFree:nil];
	[self setConnectGlobal:nil];
	[self setDisconnectAll:nil];
	[self setDetailGateInfo:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.Username = nil;
    self.Password = nil;
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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	progressHub.animationType = MBProgressHUDAnimationFade;
	
	self.Username = [self.defaults valueForKey:kITSIDKEY];
    self.Password = [self.defaults valueForKey:kITSPASSWORDKEY];
	if ([self.defaults valueForKey:kITSIDKEY] == nil || ((NSString *)([self.defaults valueForKey:kITSIDKEY])).length == 0) {
		[self performSegueWithIdentifier:@"ItsLoginSegue" sender:self];
		return ;
	}
	
    switch (indexPath.section) {
        case 0:
            if ([[self.gateStateDictionary objectForKey:_keyAutoDisconnect] boolValue]) {
                [self.connector disConnect];
                _hasSilentCallback = YES;
            }
            if (indexPath.row == 0) {
                [self.connector connectFree];
                [self showProgressHubWithTitle:@"正连接到免费地址"];
            } else if (indexPath.row == 1){
                [self.connector connectGlobal];
                [self showProgressHubWithTitle:@"正连接到收费地址"];
            }
            break;
        case 1:
            [self.connector disConnect];
            [self showProgressHubWithTitle:@"正断开全部连接"];
            break;
        case 3:
			if (indexPath.row == 1) {
				[self performSegueWithIdentifier:@"ItsLoginSegue" sender:self];
			}
            break;
        default:
            break;
	}
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark

- (void)showProgressHubWithTitle:(NSString *)title{
    self.progressHub.mode = MBProgressHUDModeIndeterminate;
    self.progressHub.delegate = self;
    self.progressHub.labelText = title;
    [self.progressHub show:YES];
}

#pragma mark - Segue setup

- (IBAction)detailGateInfoPressed:(id)sender {
	[self performSegueWithIdentifier:@"DetailGateInfoSegue" sender:self];
}
- (IBAction)backToMainButtonPressed:(id)sender {
	[self dismissModalViewControllerAnimated:YES];
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"DetailGateInfoSegue"]) {
		NanbeigeDetailGateInfoViewController *dvc = segue.destinationViewController;
		dvc.accountStatus = self.labelWarning.text;
		dvc.accountPackage = @"未知";
		dvc.accountAccuTime = @"未知";
		dvc.accountRemainTime = @"未知";
		dvc.accountBalance = @"未知";
		
		if ([self.gateStateDictionary objectForKey:_keyIPGateTimeLeft] != nil) {
            if ([self.gateStateDictionary objectForKey:_keyIPGateType] == @"NO") {
                dvc.accountPackage = @"10元国内地址任意游";
            } else if ([[self.gateStateDictionary objectForKey:_keyIPGateTimeLeft] isEqualToString:@"不限时"]){
                dvc.accountPackage = @"90元不限时";
            } else {
                dvc.accountPackage = [self.gateStateDictionary objectForKey:_keyIPGateType];
            }
			dvc.accountAccuTime = [NSString stringWithFormat: @"%@小时",[self.gateStateDictionary objectForKey:_keyIPGateTimeConsumed]];
			dvc.accountRemainTime = [self.gateStateDictionary objectForKey:_keyIPGateTimeLeft];
            dvc.accountBalance = [NSString stringWithFormat:@"%@元",[self.gateStateDictionary objectForKey:_keyIPGateBalance]];
		}
	}
}

@end
