//
//  CPMainViewController.m
//  CP
//
//  Created by Wang Zhongyu on 12-7-9.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import "CPMainViewController.h"
#import "Environment.h"
#import "CPLine1Button0Cell.h"
#import "CPLine2Button0Cell.h"
#import "CPLine2Button2Cell.h"
#import "CPLine3Button0Cell.h"
#import "CPLine3Button2Cell.h"
#import "CPAssignmentCreateViewController.h"
#import "Models+addon.h"

@interface CPMainViewController () <UIScrollViewDelegate> {
    BOOL _autoDisconnect;
    BOOL _hasSilentCallback;
}

@property (strong, nonatomic) UILabel *timeLabel;

@end

@implementation CPMainViewController
@synthesize delegate;
@synthesize functionOrder = _functionOrder;
@synthesize functionArray;
@synthesize nibsRegistered;
@synthesize nivc;
//@synthesize connector;
@synthesize navc;
@synthesize nrvc;
@synthesize progressHub;
@synthesize gateStateDictionary;
@synthesize defaults;
@synthesize numStatus;
@synthesize itsCell;
@synthesize Username;
@synthesize Password;


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
- (NSArray *)functionOrder
{
	if (_functionOrder == nil) {
		NSMutableArray *newOrder = [[[defaults valueForKey:kMAINORDERKEY] componentsSeparatedByString:@","] mutableCopy];
		if (newOrder == nil || newOrder.count < 7) {
			newOrder = [[NSMutableArray alloc] init];
			int cnt = functionArray.count;
			for (int i = 0; i < cnt; i++) {
				[newOrder addObject:[NSString stringWithFormat:@"%d", i]];
			}
		};
		_functionOrder = [[NSArray alloc] initWithArray:newOrder];
	}
	return _functionOrder;
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
	
	self.tableView.backgroundColor = tableBgColorGrouped;
	self.tabBarController.tabBar.tintColor = tabBarBgColor1;
	self.navigationController.navigationBar.tintColor = navBarBgColor1;
	
	NSMutableDictionary *titleTextAttributes = [self.navigationController.navigationBar.titleTextAttributes mutableCopy];
	if (!titleTextAttributes) titleTextAttributes = [@{} mutableCopy];
	[titleTextAttributes setObject:[UIColor colorWithRed:230/255.0 green:109/255.0 blue:69/255.0 alpha:1.0] forKey:UITextAttributeTextColor];
	[titleTextAttributes setObject:[NSValue valueWithUIOffset:UIOffsetMake(0, 0)] forKey:UITextAttributeTextShadowOffset];
	self.navigationController.navigationBar.titleTextAttributes = titleTextAttributes;
	
	UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
	view.backgroundColor = [UIColor colorWithRed:227/255.0 green:225/255.0 blue:218/255.0 alpha:1.0];
	
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	formatter.dateFormat = @"第w周 E M月d日";
	self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, view.frame.size.height - 30, 280, 20)];
	self.timeLabel.text = [formatter stringFromDate:[NSDate date]];
	self.timeLabel.backgroundColor = [UIColor clearColor];
	self.timeLabel.textColor = [UIColor whiteColor];
	self.timeLabel.font = [UIFont boldSystemFontOfSize:14];
	self.timeLabel.shadowColor = [UIColor blackColor];
	self.timeLabel.shadowOffset = CGSizeMake(0, 0.5);
	self.timeLabel.textAlignment = UITextAlignmentCenter;
	
	formatter.dateFormat = @"w";
	UIView *timeFlies = [[UIView alloc] initWithFrame:CGRectMake(0, 0, view.frame.size.width * [[formatter stringFromDate:[NSDate date]] integerValue] / 52, view.frame.size.height)];
	timeFlies.backgroundColor = [UIColor colorWithRed:230/255.0 green:109/255.0 blue:69/255.0 alpha:1.0];
	
	[self.tableView addSubview:view];
	[view addSubview:timeFlies];
	[view addSubview:self.timeLabel];
	
	NSDictionary *itsDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
							 @"IP网关", @"name",
							 @"its", @"image", 
							 @"Line1Button0Identifier", @"identifier",
							 @"CPLine1Button0Cell", @"nibname",
							 nil];
	if ([[NSUserDefaults standardUserDefaults] objectForKey:kITSIDKEY] != nil) {
		itsDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
								 @"IP网关", @"name",
								 @"its", @"image",
								 @"Line3Button2Identifier", @"identifier",
								 @"CPLine3Button2Cell", @"nibname",
								 nil];
	}
	
	NSDictionary *coursesDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
								 @"课程", @"name", 
								 @"courses", @"image", 
								 @"Line3Button0Identifier", @"identifier", 
								 @"CPLine3Button0Cell", @"nibname",
								 nil];
	NSDictionary *roomsDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
							   @"自习室", @"name", 
							   @"rooms", @"image", 
							   @"Line1Button0Identifier", @"identifier", 
							   @"CPLine1Button0Cell", @"nibname",
							   nil];
//	NSDictionary *calendarDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
//								  @"校园黄页", @"name", 
//								  @"calendar", @"image", 
//								  @"Line1Button0Identifier", @"identifier", 
//								  @"CPLine1Button0Cell", @"nibname",
//								  nil];
//	NSDictionary *feedbackDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
//								  @"反馈", @"name", 
//								  @"feedback", @"image", 
//								  @"Line1Button0Identifier", @"identifier",
//								  @"CPLine1Button0Cell", @"nibname",
//								  nil];
//	NSDictionary *activityDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
//								  @"活动", @"name", 
//								  @"Icon", @"image", 
//								  @"Line2Button0Identifier", @"identifier", 
//								  @"CPLine2Button0Cell", @"nibname",
//								  nil];
	NSDictionary *homeworkDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
								  @"作业", @"name", 
								  @"180-stickynote", @"image", 
								  @"Line2Button2Identifier", @"identifier", 
								  @"CPLine2Button2Cell", @"nibname",
								  nil];
	
	functionArray =[[NSMutableArray alloc] initWithObjects:itsDict, coursesDict, roomsDict, /*calendarDict, feedbackDict, activityDict, */homeworkDict, nil];
	
	nibsRegistered = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
					  @"NO", @"CPLine1Button0Cell",
					  @"NO", @"CPLine2Button0Cell",
					  @"NO", @"CPLine2Button2Cell", 
					  @"NO", @"CPLine3Button0Cell",
					  @"NO", @"CPLine3Button2Cell", 
					  nil];
//	self.connector = [[CPIPGateHelper alloc] init];
	self.defaults = [NSUserDefaults standardUserDefaults];
	self.title = TITLE_MAIN;
	
	[self setupDatabaseForSync];
}

- (void)viewDidUnload
{
	[self setFunctionOrder:nil];
	[self setFunctionArray:nil];
	[self setNibsRegistered:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	if ([[[self.functionArray objectAtIndex:0] objectForKey:@"identifier"] isEqualToString:@"Line3Button2Identifier"] && [[NSUserDefaults standardUserDefaults] objectForKey:kITSIDKEY] == nil) {
		NSDictionary *itsDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
								 @"IP网关", @"name",
								 @"its", @"image", 
								 @"Line1Button0Identifier", @"identifier",
								 @"CPLine1Button0Cell", @"nibname",
								 nil];
		[self.functionArray removeObjectAtIndex:0];
		[self.functionArray insertObject:itsDict atIndex:0];
		[self.tableView reloadData];
	} else if ([[[self.functionArray objectAtIndex:0] objectForKey:@"identifier"] isEqualToString:@"Line1Button0Identifier"] && [[NSUserDefaults standardUserDefaults] objectForKey:kITSIDKEY] != nil) {
		NSDictionary *itsDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
								 @"IP网关", @"name",
								 @"its", @"image", 
								 @"Line3Button2Identifier", @"identifier",
								 @"CPLine3Button2Cell", @"nibname",
								 nil];
		[self.functionArray removeObjectAtIndex:0];
		[self.functionArray insertObject:itsDict atIndex:0];
		[self.tableView reloadData];
	}
//	self.connector.delegate = self;
	if (itsCell) {
		[self changeDetailGateInfo:nil isConnecting:NO];
	}
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	[super prepareForSegue:segue sender:sender];
	if ([segue.identifier isEqualToString:@"ItsEnterSegue"]) {
		CPItsViewController *destinationViewController = (CPItsViewController *)[segue destinationViewController];
//		destinationViewController.connector = self.connector;
		destinationViewController.mainViewController = self;
//		self.connector.delegate = destinationViewController;
		self.nivc = destinationViewController;
	} else if ([segue.identifier isEqualToString:@"RoomsEnterSegue"]) {
		self.nrvc = segue.destinationViewController;
	} else if ([segue.identifier isEqualToString:@"AssignmentEnterSegue"]) {
		CPAssignmentViewController *destinationViewController = (CPAssignmentViewController *)[segue destinationViewController];
		self.navc = destinationViewController;
	} else if ([segue.identifier isEqualToString:@"CreateAssignmentSegue"] || [segue.identifier isEqualToString:@"CreateAssignmentWithCameraSegue"]) {
		UINavigationController *nc = segue.destinationViewController;
		CPAssignmentCreateViewController *ncavc = (CPAssignmentCreateViewController *)(nc.topViewController);

		ncavc.coursesData = [[Course userCourseListDocument] propertyForKey:@"value"];;
		
		ncavc.bInitWithCamera = [segue.identifier isEqualToString:@"CreateAssignmentWithCameraSegue"];
		ncavc.bCreate = YES;
		ncavc.assignment = [[Assignment alloc] initWithNewDocumentInDatabase:[(CPAppDelegate *)([[UIApplication sharedApplication] delegate]) database]];
		
	} else if ([segue.identifier isEqualToString:@"DetailGateInfoSegue"]) {
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
		@"账户状态未知";
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

#pragma mark - Table View Attributes Methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSUInteger row = [indexPath row];
	NSUInteger functionIndex = [(NSString *)([self.functionOrder objectAtIndex:row]) integerValue];
	NSString *identifier = [[functionArray objectAtIndex:functionIndex] objectForKey:@"identifier"];
	NSString *nibName = [[functionArray objectAtIndex:functionIndex] objectForKey:@"nibname"];
	
	if ([[nibsRegistered objectForKey:nibName] isEqualToString:@"NO"]) {
		UINib *nib = [UINib nibWithNibName:nibName bundle:nil];
		[tableView registerNib:nib forCellReuseIdentifier:identifier];
		[nibsRegistered setValue:@"YES" forKey:nibName];
	}
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	
	return cell.frame.size.height;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [functionArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	
	NSUInteger row = [indexPath row];
	NSUInteger functionIndex = [(NSString *)([self.functionOrder objectAtIndex:row]) integerValue];
	NSString *identifier = [[functionArray objectAtIndex:functionIndex] objectForKey:@"identifier"];
	NSString *nibName = [[functionArray objectAtIndex:functionIndex] objectForKey:@"nibname"];
	NSString *name = [[functionArray objectAtIndex:functionIndex] objectForKey:@"name"];
//	NSString *image = [[functionArray objectAtIndex:functionIndex] objectForKey:@"image"];
	
	if ([[nibsRegistered objectForKey:nibName] isEqualToString:@"NO"]) {
		UINib *nib = [UINib nibWithNibName:nibName bundle:nil];
		[tableView registerNib:nib forCellReuseIdentifier:identifier];
		[nibsRegistered setValue:@"YES" forKey:nibName];
	}
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	if (nil == cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
	}
	
	if ([nibName isEqualToString:@"CPLine1Button0Cell"]) {
		((CPLine1Button0Cell *) cell).name = name;
//		((CPLine1Button0Cell *) cell).image = image;
	} else if ([nibName isEqualToString:@"CPLine2Button0Cell"]) {
		((CPLine2Button0Cell *) cell).name = name;
//		((CPLine2Button0Cell *) cell).image = image;
	} else if ([nibName isEqualToString:@"CPLine2Button2Cell"]) {
		((CPLine2Button2Cell *) cell).name = name;
//		((CPLine2Button2Cell *) cell).image = image;
		((CPLine2Button2Cell *) cell).delegate = self;
	} else if ([nibName isEqualToString:@"CPLine3Button0Cell"]) {
		((CPLine3Button0Cell*) cell).name = name;
//		((CPLine3Button0Cell*) cell).image = image;
	} else if ([nibName isEqualToString:@"CPLine3Button2Cell"]) {
		itsCell = (CPLine3Button2Cell*) cell;
		((CPLine3Button2Cell*) cell).name = name;
//		((CPLine3Button2Cell*) cell).image = image;
		((CPLine3Button2Cell*) cell).delegate = self;
		[self changeDetailGateInfo:nil isConnecting:NO];
	}
	
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
	NSUInteger row = [indexPath row];
	NSUInteger functionIndex = [(NSString *)([self.functionOrder objectAtIndex:row]) integerValue];
	NSString *name = [[functionArray objectAtIndex:functionIndex] objectForKey:@"name"];
	
	if ([name isEqualToString:@"IP网关"]) {
		if (self.nivc == nil) [self performSegueWithIdentifier:@"ItsEnterSegue" sender:self];
		else {
//			self.connector.delegate = self.nivc;
			[self.navigationController pushViewController:self.nivc animated:YES];
		}
	} else if ([name isEqualToString:@"课程"]) {
		UIStoryboard *sb = [UIStoryboard storyboardWithName:@"CPCoursesFlow" bundle:[NSBundle mainBundle]];
		[self.navigationController pushViewController:[sb instantiateInitialViewController] animated:YES];
//		[self performSegueWithIdentifier:@"CoursesEnterSegue" sender:self];
	} else if ([name isEqualToString:@"自习室"]) {
		if (self.nrvc == nil) [self performSegueWithIdentifier:@"RoomsEnterSegue" sender:self];
		else [self.navigationController pushViewController:self.nrvc animated:YES];
	} else if ([name isEqualToString:@"作业"]) {
		if (self.navc == nil) [self performSegueWithIdentifier:@"AssignmentEnterSegue" sender:self];
		else [self.navigationController pushViewController:self.navc animated:YES];
	} else {
		[self showAlert:@"功能正在制作中，敬请期待！"];
	}
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Its Connect Display

- (void)setNumStatus:(NSInteger)anumStatus{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"M月d日HH:mm";
    NSDate *dateUpdate = [NSDate date];
    NSString *stringUpdateStatus = [NSString stringWithFormat:@"更新于：%@",[formatter stringFromDate:dateUpdate]];
    
	self.gateStateDictionary = [NSMutableDictionary dictionaryWithDictionary:[defaults objectForKey:_keyAccountState]];
    [self.gateStateDictionary setObject:stringUpdateStatus forKey:_keyIPGateUpdatedTime];
	[defaults setObject:self.gateStateDictionary forKey:_keyAccountState];
	
    numStatus = anumStatus;
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

- (void)changeDetailGateInfo:(NSString *)title 
				isConnecting:(BOOL)bConnecting
{
	self.gateStateDictionary = [NSMutableDictionary dictionaryWithDictionary:[defaults objectForKey:_keyAccountState]];
	
	NSString *timeLeftString = [NSString stringWithFormat:@"（包月剩余：%@）",[self.gateStateDictionary objectForKey:_keyIPGateTimeLeft] ? [self.gateStateDictionary objectForKey:_keyIPGateTimeLeft] : @"未知"];
	NSString *balanceString = [self.gateStateDictionary objectForKey:_keyIPGateBalance] ? [NSString stringWithFormat:@"（账户余额：%@元）", [self.gateStateDictionary objectForKey:_keyIPGateBalance]] : @"（账户余额：未知）";
	
	if (![[self.gateStateDictionary objectForKey:_keyIPGateType] isEqualToString:@"NO"]) {
		itsCell.detailStatusLabel.text = timeLeftString;
	} else {
		itsCell.detailStatusLabel.text = balanceString;
	}
	if (bConnecting) {
		itsCell.statusLabel.text = @"已连接";
		[itsCell.statusBackground setBackgroundColor:gateConnectingBtnColor]; 
	} else {
		[itsCell.statusBackground setBackgroundColor:gateConnectedBtnColor];
	}
	
	if (self.numStatus == 0) {
		itsCell.statusLabel.text = @"状态未知";
		itsCell.detailStatusLabel.text = [NSString stringWithFormat:@"    %@", itsCell.detailStatusLabel.text];
	} else if (self.numStatus == 1) {
		itsCell.statusLabel.text = @"未连接";
	} else if (self.numStatus >= 2) {
		itsCell.statusLabel.text = @"已连接";
	}
}

#pragma mark - MBProgressHUD Delegate

- (void)hudWasHidden:(MBProgressHUD *)hud
{
	self.progressHub.taskInProgress = NO;
}

#pragma mark - CPLine2Button2DelegateProtocol

- (void)onButton1Pressed:(id)sender
{
	[self performSegueWithIdentifier:@"CreateAssignmentSegue" sender:self];
}

- (void)onButton2Pressed:(id)sender
{
	[self performSegueWithIdentifier:@"CreateAssignmentWithCameraSegue" sender:self];
}

#pragma mark - CPItsWidgetDelegateProtocol

- (void)connectFree:(id)sender
{
	if (self.progressHub.taskInProgress) return ;
	self.Username = [self.defaults valueForKey:kITSIDKEY];
    self.Password = [self.defaults valueForKey:kITSPASSWORDKEY];
	if ([self.defaults valueForKey:kITSIDKEY] == nil || ((NSString *)([self.defaults valueForKey:kITSIDKEY])).length == 0) {
		[self performSegueWithIdentifier:@"ItsLoginSegue" sender:self];
		return ;
	}
	self.gateStateDictionary = [NSMutableDictionary dictionaryWithDictionary:[defaults objectForKey:_keyAccountState]];
	if ([[self.gateStateDictionary objectForKey:_keyAutoDisconnect] boolValue]) {
//		[self.connector disConnect];
		_hasSilentCallback = YES;
	}
//	[self.connector connectFree];
	[self showProgressHubWithTitle:@"正连接到免费地址"];
}

- (void)connectGlobal:(id)sender
{
	if (self.progressHub.taskInProgress) return ;
	self.Username = [self.defaults valueForKey:kITSIDKEY];
    self.Password = [self.defaults valueForKey:kITSPASSWORDKEY];
	if ([self.defaults valueForKey:kITSIDKEY] == nil || ((NSString *)([self.defaults valueForKey:kITSIDKEY])).length == 0) {
		[self performSegueWithIdentifier:@"ItsLoginSegue" sender:self];
		return ;
	}
	self.gateStateDictionary = [NSMutableDictionary dictionaryWithDictionary:[defaults objectForKey:_keyAccountState]];
	if ([[self.gateStateDictionary objectForKey:_keyAutoDisconnect] boolValue]) {
//		[self.connector disConnect];
		_hasSilentCallback = YES;
	}
//	[self.connector connectGlobal];
	[self showProgressHubWithTitle:@"正连接到收费地址"];
}

- (void)disconnectAll:(id)sender
{
	if (self.progressHub.taskInProgress) return ;
	self.Username = [self.defaults valueForKey:kITSIDKEY];
    self.Password = [self.defaults valueForKey:kITSPASSWORDKEY];
	if ([self.defaults valueForKey:kITSIDKEY] == nil || ((NSString *)([self.defaults valueForKey:kITSIDKEY])).length == 0) {
		[self performSegueWithIdentifier:@"ItsLoginSegue" sender:self];
		return ;
	}
//	[self.connector disConnect];
	[self showProgressHubWithTitle:@"正断开全部连接"];
}

- (void)detailGateInfo:(id)sender
{
	[self performSegueWithIdentifier:@"DetailGateInfoSegue" sender:self];
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
//	[self.gateStateDictionary setValuesForKeysWithDictionary:self.connector.dictResult];
//	[self.gateStateDictionary setValuesForKeysWithDictionary:self.connector.dictDetail];
    [self.defaults setObject:self.gateStateDictionary forKey:_keyAccountState];
}

- (void)setupDatabaseForSync
{
	User *appUser = [User sharedAppUser];
    // Register the default value of the pref for the remote database URL to sync with:
    NSDictionary *appdefaults = [NSDictionary dictionaryWithObject:kSyncDbURLWithID(appUser.id)
                                                            forKey:@"syncpoint"];
    [defaults registerDefaults:appdefaults];
    [defaults synchronize];
	NSURLCredential* cred;
	cred = [NSURLCredential credentialWithUser: kSyncDbUsername
									  password: kSyncDbPassword
								   persistence: NSURLCredentialPersistenceForSession];
	NSURLProtectionSpace* space;
	space = [[NSURLProtectionSpace alloc] initWithHost: kSyncDbHostNameWithID(appUser.id)
												  port: 5984
											  protocol: @"http"
												 realm: @"server"
								  authenticationMethod: NSURLAuthenticationMethodDefault];
	[[NSURLCredentialStorage sharedCredentialStorage] setDefaultCredential: cred forProtectionSpace: space];
	
	CPAppDelegate *appDelegate = (CPAppDelegate *)([[UIApplication sharedApplication] delegate]);
    appDelegate.database = [appDelegate.server databaseNamed: kDatabaseNameWithID(appUser.id)];
    appDelegate.database.tracksChanges = YES;
#if !INSTALL_CANNED_DATABASE && !defined(USE_REMOTE_SERVER)
    // Create the database on the first run of the app.
    NSError* error;
    if (![appDelegate.database ensureCreated: &error]) {
        [self showAlert:[error localizedFailureReason]];
    }
#endif
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	CGFloat scrollViewHeight = -scrollView.contentOffset.y;
	CGFloat timeLabelY = [self.timeLabel superview].frame.size.height - 30;
	if (scrollViewHeight > 40) {
		self.timeLabel.frame = CGRectMake(20, timeLabelY - (scrollViewHeight - 40) / 2, self.timeLabel.frame.size.width, self.timeLabel.frame.size.height);
	}
}

@end
