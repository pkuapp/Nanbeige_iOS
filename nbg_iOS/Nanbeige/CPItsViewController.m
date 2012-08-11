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
@synthesize gateStateDictionary = _gateStateDictionary;
@synthesize defaults;
@synthesize numStatus;
@synthesize labelStatus;
@synthesize labelWarning;
@synthesize progressHub;
@synthesize delegate;
@synthesize connectFree;
@synthesize connectGlobal;
@synthesize disconnectAll;
@synthesize mainViewController;

#pragma mark - getter and setter Override

- (NSObject *)delegate {
    if (delegate == nil) {
//        delegate = (NSObject<AppCoreDataProtocol,AppUserDelegateProtocol,ReachabilityProtocol,PABezelHUDDelegate> *)[UIApplication sharedApplication].delegate;
    }
    return delegate;
}
- (MBProgressHUD *)progressHub{
    if (progressHub == nil) {
//        progressHub = self.delegate.progressHub;
    }
    return progressHub;
}
- (void)setNumStatus:(NSInteger)anumStatus{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"M月d日HH:mm";
    NSDate *dateUpdate = [NSDate date];
    NSString *stringUpdateStatus = [NSString stringWithFormat:@"更新于：%@",[formatter stringFromDate:dateUpdate]];
    
	self.gateStateDictionary = [NSMutableDictionary dictionaryWithDictionary:[defaults objectForKey:_keyAccountState]];
    [self.gateStateDictionary setObject:stringUpdateStatus forKey:_keyIPGateUpdatedTime];
	[defaults setObject:self.gateStateDictionary forKey:_keyAccountState];
	
    self.labelWarning.text = stringUpdateStatus;
    
	switch (anumStatus) {
        case 0:
            self.labelStatus.text = @"当前网络状态未知";
			break;
        case 1:
            self.labelStatus.text = @"当前可访问校园网";
			break;
        case 2:
            self.labelStatus.text = @"当前可访问校园网、免费网址";
			break;
        case 3:
            self.labelStatus.text = @"当前可访问校园网、免费网址、收费网址";
			break;
        default:
            break;
    }
    numStatus = anumStatus;
	if ([self.mainViewController respondsToSelector:@selector(setNumStatus:)]) {
		[self.mainViewController setNumStatus:anumStatus];
	}
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
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	self.defaults = [NSUserDefaults standardUserDefaults];
    
	//self.connector = [[NanbeigeIPGateHelper alloc] init];
	//self.connector.delegate = self;
	
	[connectFree setBackgroundColor:gateConnectCellColor];
	[connectGlobal setBackgroundColor:gateConnectCellColor];
	[disconnectAll setBackgroundColor:gateDisconnectCellColor];
	
	bViewDidLoad = YES;
	self.title = TITLE_ITS;
	
}
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self changeDetailGateInfo:nil isConnecting:NO];
}
- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	if (bViewDidLoad && ([self.defaults valueForKey:kITSIDKEY] == nil || ((NSString *)([self.defaults valueForKey:kITSIDKEY])).length == 0)) {
		[self performSegueWithIdentifier:@"ItsLoginSegue" sender:self];
		bViewDidLoad = NO;
	}
}
- (void)viewDidUnload
{
	[self setUsername:nil];
	[self setPassword:nil];
	[self setConnectFree:nil];
	[self setConnectGlobal:nil];
	[self setDisconnectAll:nil];
	[self setDetailGateInfo:nil];
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

#pragma mark - Display
- (void)changeDetailGateInfo:(NSString *)title 
			   isConnecting:(BOOL)bConnecting
{
	detailGateInfo.titleLabel.textAlignment = UITextAlignmentCenter;
	detailGateInfo.titleLabel.lineBreakMode = UILineBreakModeWordWrap;
	
	self.gateStateDictionary = [NSMutableDictionary dictionaryWithDictionary:[defaults objectForKey:_keyAccountState]];
	
	NSString *timeLeftString = [NSString stringWithFormat:@"包月剩余：%@",[self.gateStateDictionary objectForKey:_keyIPGateTimeLeft] ? [self.gateStateDictionary objectForKey:_keyIPGateTimeLeft] : @"未知"];
	NSString *balanceString = [self.gateStateDictionary objectForKey:_keyIPGateBalance] ? [NSString stringWithFormat:@"账户余额：%@元", [self.gateStateDictionary objectForKey:_keyIPGateBalance]] : @"账户余额：未知";
	
	if (bConnecting) {
		[detailGateInfo setBackgroundColor:gateConnectingBtnColor];
		if (![[self.gateStateDictionary objectForKey:_keyIPGateType] isEqualToString:@"NO"]) {
			[detailGateInfo setTitle:[NSString stringWithFormat:@"%@\n%@", title, timeLeftString]
							forState:UIControlStateNormal];
		} else {
			[detailGateInfo setTitle:[NSString stringWithFormat:@"%@\n%@", title, balanceString]
							forState:UIControlStateNormal];
		}
	} else {
		[detailGateInfo setBackgroundColor:gateConnectedBtnColor];
		NSString *updateTimeString = [self.gateStateDictionary objectForKey:_keyIPGateUpdatedTime] ? [self.gateStateDictionary objectForKey:_keyIPGateUpdatedTime] : @"更新时间：无";
		if (![[self.gateStateDictionary objectForKey:_keyIPGateType] isEqualToString:@"NO"]) {
			[detailGateInfo setTitle:[NSString stringWithFormat:@"%@\n%@", timeLeftString, updateTimeString]
							forState:UIControlStateNormal];
		} else {
			[detailGateInfo setTitle:[NSString stringWithFormat:@"%@\n%@", balanceString, updateTimeString]
							forState:UIControlStateNormal];
		}
	}
}
- (void)changeProgressHub:(NSString *)title
				isSuccess:(BOOL)bSuccess
{
	progressHub.animationType = MBProgressHUDAnimationZoom;
    self.progressHub.labelText = title;
    if (bSuccess) {
		self.progressHub.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"alert-yes"]];
	} else {
		self.progressHub.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"alert-no"]];
	}
    self.progressHub.mode = MBProgressHUDModeCustomView;
    [self.progressHub hide:YES afterDelay:1];
}
- (void)showProgressHubWithTitle:(NSString *)title{
    self.progressHub.mode = MBProgressHUDModeIndeterminate;
	self.progressHub.transform = CGAffineTransformIdentity;
    self.progressHub.delegate = self;
    self.progressHub.labelText = title;
    [self.progressHub show:YES];
	self.progressHub.taskInProgress = YES;
}
#pragma mark - MBProgressHUD Delegate
- (void)hudWasHidden:(MBProgressHUD *)hud
{
	self.progressHub.taskInProgress = NO;
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
    [self changeDetailGateInfo:@"当前可访问校园网" isConnecting:YES];
	[self changeProgressHub:@"已断开全部连接" isSuccess:YES];
	
    NSLog(@"DisconnectDone");
}
- (void)connectFreeSuccess{
	self.numStatus = 2;
    [self saveAccountState];
	[self changeDetailGateInfo:@"可访问免费地址" isConnecting:YES];
	[self changeProgressHub:@"已连接到免费地址" isSuccess:YES];
    
    NSLog(@"ConnectToFreeDone");
	
}
- (void)connectGlobalSuccess {
	self.numStatus = 3;
    [self saveAccountState];
	[self changeDetailGateInfo:@"可访问收费地址" isConnecting:YES];
	[self changeProgressHub:@"已连接到收费地址" isSuccess:YES];
	
    NSLog(@"ConnectToGlobalDone");
}
- (void)connectFailed
{
//    if (self.connector.error == IPGateErrorOverCount) {
//        self.progressHub.mode = MBProgressHUDModeIndeterminate;
//        self.progressHub.labelText = @"连接数超过预定值";
//        if ([ModalAlert confirm:@"断开别处的连接" withMessage:@"断开别处的连接才能在此处建立连接"]){
//            _hasSilentCallback = YES;
//            [self.connector disConnect];
//            self.progressHub.labelText = @"正在断开重连";
//            [self.connector reConnect];
//        } else [self.progressHub hide:YES afterDelay:0.5];
//    } else {
//		if ([self.connector.dictResult objectForKey:@"REASON"] == nil) {
//			[self changeProgressHub:@"网络错误，请稍后再试。" isSuccess:NO];
//		} else if ([[self.connector.dictResult objectForKey:@"REASON"] hasSuffix:@"在例外中"]) {
//			[self changeProgressHub:@"您的IP地址不在学校范围内。"  isSuccess:NO];
//		} else {
//			[self changeProgressHub:[self.connector.dictResult objectForKey:@"REASON"] isSuccess:NO];
//		}
//        NSLog(@"Reason %@",[self.connector.dictResult objectForKey:@"REASON"]);
//		self.connector.dictResult = nil;
//    }
}
- (void)saveAccountState {
	self.gateStateDictionary = [NSMutableDictionary dictionaryWithDictionary:[defaults objectForKey:_keyAccountState]];
	[self.gateStateDictionary setValuesForKeysWithDictionary:self.connector.dictResult];
	[self.gateStateDictionary setValuesForKeysWithDictionary:self.connector.dictDetail];
    [self.defaults setObject:self.gateStateDictionary forKey:_keyAccountState];
}

#pragma mark - private ControlEvent Setup
- (IBAction)configAutoDisconnectDidChanged:(UISwitch *)sender {
	self.gateStateDictionary = [NSMutableDictionary dictionaryWithDictionary:[defaults objectForKey:_keyAccountState]];
    [self.gateStateDictionary setObject:[NSNumber numberWithBool:sender.on] forKey:_keyAutoDisconnect];
    [defaults setObject:self.gateStateDictionary forKey:_keyAccountState];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	self.Username = [self.defaults valueForKey:kITSIDKEY];
    self.Password = [self.defaults valueForKey:kITSPASSWORDKEY];
	if ([self.defaults valueForKey:kITSIDKEY] == nil || ((NSString *)([self.defaults valueForKey:kITSIDKEY])).length == 0) {
		[self performSegueWithIdentifier:@"ItsLoginSegue" sender:self];
		return ;
	}
	
    switch (indexPath.section) {
        case 0:
			if (self.progressHub.taskInProgress) return ;
			self.gateStateDictionary = [NSMutableDictionary dictionaryWithDictionary:[defaults objectForKey:_keyAccountState]];
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
			if (self.progressHub.taskInProgress) return ;
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
}

#pragma mark - Segue setup

- (IBAction)detailGateInfoPressed:(id)sender {
	[self performSegueWithIdentifier:@"DetailGateInfoSegue" sender:self];
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	[super prepareForSegue:segue sender:sender];
	if ([segue.identifier isEqualToString:@"DetailGateInfoSegue"]) {
		CPDetailGateInfoViewController *dvc = segue.destinationViewController;
		
		self.gateStateDictionary = [NSMutableDictionary dictionaryWithDictionary:[defaults objectForKey:_keyAccountState]];
		
		if ([[self.gateStateDictionary objectForKey:_keyIPGateType] isEqualToString:@"NO"]) {
			dvc.accountPackage = @"10元国内地址任意游";
		} else if ([[self.gateStateDictionary objectForKey:_keyIPGateTimeLeft] isEqualToString:@"不限时"]){
			dvc.accountPackage = @"90元不限时";
		} else {
			dvc.accountPackage = 
			[self.gateStateDictionary objectForKey:_keyIPGateType] ? 
				[self.gateStateDictionary objectForKey:_keyIPGateType] : 
				@"未知";
		}
		
		dvc.accountStatus = 
		[self.gateStateDictionary objectForKey:_keyIPGateUpdatedTime] ? 
			[self.gateStateDictionary objectForKey:_keyIPGateUpdatedTime] : 
			self.labelWarning.text;
		dvc.accountAccuTime = 
		[dvc.accountPackage isEqualToString:@"10元国内地址任意游"] ? 
			@"未包月" : 
			([self.gateStateDictionary objectForKey:_keyIPGateTimeConsumed] ? 
				 [self.gateStateDictionary objectForKey:_keyIPGateTimeConsumed] : 
				 @"未知");
		dvc.accountRemainTime = 
		[dvc.accountPackage isEqualToString:@"10元国内地址任意游"] ?
			@"未包月" : 
			([self.gateStateDictionary objectForKey:_keyIPGateTimeLeft] ? 
				 [self.gateStateDictionary objectForKey:_keyIPGateTimeLeft] : 
				 @"未知");
		dvc.accountBalance = 
		[self.gateStateDictionary objectForKey:_keyIPGateBalance] ? 
			[NSString stringWithFormat:@"%@元",[self.gateStateDictionary objectForKey:_keyIPGateBalance]] : 
			@"未知";
	}
}

@end
