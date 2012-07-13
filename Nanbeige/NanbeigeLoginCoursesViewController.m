//
//  NanbeigeLoginCoursesViewController.m
//  Nanbeige
//
//  Created by Wang Zhongyu on 12-7-13.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import "NanbeigeLoginCoursesViewController.h"
#import "NanbeigeAppDelegate.h"
#import "AppUser.h"
#import "ASIFormDataRequest.h"
#import "ASIHTTPRequest.h"
#import "Course.h"
#import "Environment.h"
#import "MBProgressHUD.h"
#import "SBJson.h"
#import "SystemHelper.h"

#define pathImg [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"deancode.png"]

@interface NanbeigeLoginCoursesViewController ()

@end

@implementation NanbeigeLoginCoursesViewController

@synthesize tableView;
@synthesize Username = _Username;
@synthesize UserPwd = _UserPwd;
@synthesize validCode = _validCode;
@synthesize requestImg = _requestImg;
@synthesize didInputUsername = _didInputUsername;
@synthesize firstImg;
@synthesize sessionid;
@synthesize HUD;
@synthesize appUser;
@synthesize activityView;

#pragma mark - setter OverRide
- (void)setDidInputUsername:(BOOL)didInputUsername{
    if (self.didInputUsername == NO && didInputUsername == YES) {
        _didInputUsername = didInputUsername;
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:2 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    }
    
}

#pragma mark - getter OverRide
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField == self.validCode) {
        [self.validCode resignFirstResponder];
        [self myLogin:nil];
        return NO;
    }
    else if (textField == self.UserPwd) {
        
        [self.validCode becomeFirstResponder];
        return NO;
    }
    else if (textField == self.Username) {
        [self.UserPwd becomeFirstResponder];
    }
    
    return YES;
}

- (UIButton *)firstImg{
    if (firstImg == nil) {
        firstImg = [UIButton buttonWithType:UIButtonTypeCustom];
        [firstImg addTarget:self action:@selector(refreshImg) forControlEvents:UIControlEventTouchUpInside];
        [firstImg setFrame:CGRectMake(250, 13, deanImgWidth, deanImgHeight)];
        
        
    }
    
    return firstImg;
}

- (UITextField *)Username{
    if (Username == nil) {
        Username = [[UITextField alloc] initWithFrame:CGRectMake(90, 11, 200, 20)];
        Username.borderStyle = UITextBorderStyleNone;
        Username.delegate = self;
        Username.keyboardType = UIKeyboardTypeASCIICapable;
        Username.autocorrectionType = UITextAutocorrectionTypeNo;
        Username.autocapitalizationType = UITextAutocapitalizationTypeNone;
        Username.enablesReturnKeyAutomatically = YES;
        Username.returnKeyType = UIReturnKeyNext;
        Username.placeholder = @"课程账号";
        Username.delegate = self;
    }
    return  Username;
}
- (UITextField *)UserPwd{
    if (UserPwd == nil) {
        UserPwd = [[UITextField alloc] initWithFrame:CGRectMake(90, 11, 200, 20)];
        UserPwd.borderStyle = UITextBorderStyleNone;
        UserPwd.secureTextEntry = YES;
        UserPwd.keyboardType = UIKeyboardTypeASCIICapable;
        UserPwd.autocorrectionType = UITextAutocorrectionTypeNo;
        UserPwd.autocapitalizationType = UITextAutocapitalizationTypeNone;
		
        UserPwd.enablesReturnKeyAutomatically = YES;
        
        UserPwd.returnKeyType = UIReturnKeyNext;
        UserPwd.delegate = self;
    }
    return UserPwd;
}

- (UITextField *)validCode{
    if (validCode == nil) {
        validCode = [[UITextField alloc] initWithFrame:CGRectMake(90, 11, 140, 20)];
        validCode.autocapitalizationType = UITextAutocapitalizationTypeNone;
		
        validCode.borderStyle = UITextBorderStyleNone;
        validCode.enablesReturnKeyAutomatically = YES;
        validCode.autocorrectionType = UITextAutocorrectionTypeNo;
		
        validCode.keyboardType = UIKeyboardTypeASCIICapable;
        validCode.returnKeyType = UIReturnKeyGo;
        validCode.delegate = self;
    }
    return validCode;
}

-(NanbeigeAppDelegate *)delegate
{
    if (nil == delegate) {
        delegate = (NanbeigeAppDelegate*) [[UIApplication sharedApplication] delegate];
    }
    return delegate;
}

-(NSManagedObjectContext *)context
{
    if (nil == context) {
        context = self.delegate.managedObjectContext;
    }
    return context;
}

#pragma mark - UITextField Delegate
- (void)textFieldDidEndEditing:(UITextField *)textField{
    if (textField == Username) {
        self.didInputUsername = YES;
        [self refreshImg];
    }
}
#pragma mark - UITableView Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
		if (self.didInputUsername) {
			return 3;
		}
		return 2;	
	} else {
		return 1;
	}
}

- (UITableViewCell *)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	static NSString *stringCell;
	if (indexPath.section == 0) stringCell = @"stringCell";
	else stringCell = @"buttonCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:stringCell];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:stringCell];
    }
	if (indexPath.section == 0) {
		switch (indexPath.row) {
			case 0:
				cell.textLabel.text = @"用户名";
				[cell.contentView addSubview: self.Username];
				break;
			case 1:
				cell.textLabel.text = @"密码";
				[cell.contentView addSubview: self.UserPwd];
				break;
			case 2:
				cell.textLabel.text = @"验证码";
				[cell.contentView addSubview: self.validCode];
				[cell.contentView addSubview:self.firstImg];
				self.activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
				self.activityView.center = CGPointMake(270, 22);
				[cell.contentView addSubview:self.activityView];
				self.activityView.hidesWhenStopped = YES;
				break;
				
			default:
				break;
		}
    } else {
		switch (indexPath.row) {
			case 0:
				cell.textLabel.text = @"注销课程账户";
				break;
				
			default:
				break;
		}
	}
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == 1) {
		[self.delegate logout];
		UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
		cell.selected = NO;
		[self performSelectorOnMainThread:@selector(logoutSucceed) withObject:nil waitUntilDone:YES];
	}
}

-(void)logoutSucceed
{
	[self dismissModalViewControllerAnimated:YES];
}


#pragma mark ASIHttpRequestDelegate Setup
- (void)requestFinished:(ASIHTTPRequest *)request
{
	
	NSArray *cookies = [request responseCookies];
    
    NSAssert2([cookies count] > 0, @"Unhandled error at %s line %d", __FUNCTION__, __LINE__); 
    
    NSLog(@"%@",cookies);
    
    NSString *tempString = [[cookies objectAtIndex:0] valueForKey:@"value"];// cStringUsingEncoding:-2147481083];
    if ([SystemHelper getPkuWeeknumberNow] > 2) {
        self.sessionid = [SystemHelper Utf8stringFromGB18030:tempString];
    }
    else self.sessionid = tempString;
    
    NSLog(@"%@",sessionid);
    
	[self.firstImg setImage:[UIImage imageWithContentsOfFile: pathImg] forState:UIControlStateNormal];
    
    _validCode.placeholder = @"轻按图片以更新";
    
    [self.activityView stopAnimating];
	
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
	
	NSError *error = [request error];
	NSLog(@"%@",error);
	self.delegate.progressHub.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"alert-no.png"]];
    self.delegate.progressHub.labelText = @"获取验证码失败";
    self.delegate.progressHub.mode = MBProgressHUDModeCustomView;
    
    [self.delegate.progressHub show:YES];
    
    [self.delegate.progressHub hide:YES afterDelay:0.5];
	
	//	firstAlertView = [[[UIAlertView alloc] initWithTitle:@"Fetch authImg failed" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil] autorelease];
	//    [firstAlertView show];
	//    [self.activityView stopAnimating];
	
    
}
-(BOOL)refreshImg
{	
    NSInteger pkuNumberNow = [SystemHelper getPkuWeeknumberNow];
    NSString *urlImg;
    
    if (pkuNumberNow <= 2) {
        urlImg = urlImgEle;
    }
    else urlImg = urlImgDean; 
    
	self.firstImg.imageView.image = nil;
    self.activityView.hidden = NO;
    [self.activityView startAnimating];
	self.requestImg = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:urlImg]];
    
	[self.requestImg setDownloadDestinationPath:pathImg];
    
	[self.requestImg setDelegate:self];
	
	
	[ASIHTTPRequest setSessionCookies:nil];
    
	
	[self.requestImg startAsynchronous];
	//		  [queueNet addOperation:imgDeanCode];
	//		  [queueNet go];
	return YES;
}

#pragma mark - MBProgressHub delegate
- (void)hudWasHidden:(MBProgressHUD *)hud {
}

#pragma mark - Navigation Setup

- (void)didSelectNeXTBtn{
    [self myLogin:nil];
}

- (void) myLogin:(id)sender{
    [self.validCode resignFirstResponder];
    self.delegate.progressHub.delegate = self;
    self.delegate.progressHub.mode = MBProgressHUDModeIndeterminate;
    self.delegate.progressHub.labelText = @"登录中";
    [self.delegate.progressHub show:YES];
    [self performSelectorInBackground:@selector(taskLogin) withObject:nil];
	
}

- (void)loginSucceed {
    self.delegate.progressHub.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"alert-yes.png"]];
    self.delegate.progressHub.mode = MBProgressHUDModeCustomView;
	
    self.delegate.progressHub.labelText = @"已完成";
    
    [self.delegate.progressHub hide:YES afterDelay:1];
	
	[NSThread sleepForTimeInterval:1];
    
    [self dismissModalViewControllerAnimated:YES];
}

- (void)loginFailed:(NSDictionary *)dict{
    self.delegate.progressHub.labelText = [[dict objectForKey:@"info"] description];
    self.delegate.progressHub.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"alert-no.png"]];
    
    self.delegate.progressHub.mode = MBProgressHUDModeCustomView;
	
    [self.delegate.progressHub hide:YES afterDelay:1];
}

- (void)taskLogin {
    NSString *error;
    @try {
        if ([self.delegate authUserForAppWithCoursesID:self.Username.text coursesPassword:self.UserPwd.text coursesCode:self.validCode.text sessionID:self.sessionid error:&error]) {
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            
            [defaults setObject:[NSString stringWithString:self.Username.text] forKey:@"appUser"];
            
            [self.delegate updateAppUserProfile];
            
			[self.delegate updateServerCourses];
            
            [defaults setInteger:VersionReLogin forKey:@"VersionReLogin"];
            
            [defaults setBool:YES forKey:@"didLogin"];
            [NSUserDefaults resetStandardUserDefaults]; 
            
            [self performSelectorOnMainThread:@selector(loginSucceed) withObject:nil waitUntilDone:YES];
            
        }
        else {
            [self performSelectorOnMainThread:@selector(loginFailed:) withObject:[NSDictionary dictionaryWithObjectsAndKeys:error,@"info", nil] waitUntilDone:YES];
        }
    }
    @catch (NSException *exception) {
        [self performSelectorOnMainThread:@selector(loginFailed:) withObject:[NSDictionary dictionaryWithObjectsAndKeys:exception,@"info", nil] waitUntilDone:YES];
        NSLog(@"%@",exception);
    }
    @finally {
        
    }
    
}

#pragma mark - View lifecycle

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
    self.didInputUsername = NO;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
	[self setUsername:nil];
    [self setUserPwd:nil];
    [self setValidCode:nil];
    firstImg = nil;
    sessionid = nil;
    HUD = nil;
}
- (void)viewDidAppear:(BOOL)animated
{
    [self.Username becomeFirstResponder];   
	
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

- (void)dealloc {
    NSFileManager *imgManager = [NSFileManager defaultManager];
    [imgManager removeItemAtPath:pathImg error:nil];
    [self.Username release];
    [self.UserPwd release];
    [self.validCode release];
    [firstImg release];
    [sessionid release];
    [_requestImg clearDelegatesAndCancel];
    [_requestImg release];
    [HUD release];
    [tableView release];
    [super dealloc];
}

- (IBAction)onCancelButtonPressed:(id)sender {
	[self dismissModalViewControllerAnimated:YES];
}
@end