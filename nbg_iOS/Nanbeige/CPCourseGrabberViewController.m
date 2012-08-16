//
//  CPCourseGrabberViewController.m
//  CP
//
//  Created by ZongZiWang on 12-8-10.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import "CPCourseGrabberViewController.h"
#import "Environment.h"
#import "Coffeepot.h"
#import "Models+addon.h"

@interface CPCourseGrabberViewController () {

}

@end

@implementation CPCourseGrabberViewController

#pragma mark - Setter and Getter Methods

- (void)setQuickDialogTableView:(QuickDialogTableView *)aQuickDialogTableView {
    [super setQuickDialogTableView:aQuickDialogTableView];
    self.quickDialogTableView.backgroundView = nil;
    self.quickDialogTableView.backgroundColor = tableBgColorGrouped;
    self.quickDialogTableView.bounces = YES;
}

#pragma mark - View Lifecycle

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self) {
		self.root = [[QRootElement alloc] initWithJSONFile:@"courseGrabber"];
	}
	return self;
}

- (id)init
{
	self = [super init];
	if (self) {
		self.root = [[QRootElement alloc] initWithJSONFile:@"courseGrabber"];
	}
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	UIBarButtonItem *loginButton = [[UIBarButtonItem alloc] initWithTitle:sCONFIRM style:UIBarButtonItemStyleBordered target:self action:@selector(onConfirm:)];
	UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:sCANCEL style:UIBarButtonItemStyleBordered target:self action:@selector(close)];
	self.navigationItem.rightBarButtonItem = loginButton;
	self.navigationItem.leftBarButtonItem = closeButton;
	
	self.navigationController.navigationBar.tintColor = navBarBgColor1;
	NSMutableDictionary *titleTextAttributes = [self.navigationController.navigationBar.titleTextAttributes mutableCopy];
	if (!titleTextAttributes) titleTextAttributes = [@{} mutableCopy];
	[titleTextAttributes setObject:navBarTextColor1 forKey:UITextAttributeTextColor];
	[titleTextAttributes setObject:[NSValue valueWithUIOffset:UIOffsetMake(0, 0)] forKey:UITextAttributeTextShadowOffset];
	self.navigationController.navigationBar.titleTextAttributes = titleTextAttributes;

	[[Coffeepot shared] requestWithMethodPath:@"course/grabber/" params:nil requestMethod:@"POST" success:^(CPRequest *_req, id collection) {
		
		if (![collection isKindOfClass:[NSDictionary class]] || ![[collection objectForKey:@"available"] boolValue]) {
			[self performSelector:@selector(close) withObject:nil afterDelay:1.0];
			[self showAlert:@"抓课器暂不可用"];
		} else if ([[collection objectForKey:@"require_captcha"] boolValue]) {
			
			[[Coffeepot shared] requestWithMethodPath:@"course/grabber/captcha/" params:nil requestMethod:@"GET" raw:^(CPRequest *_req, NSData *data) {
			
				[self loading:NO];
				
				if ([data isKindOfClass:[NSData class]]) {
					NSDictionary *dict = @{@"captcha":@[@{ @"placeholder" : @"验证码" }]};
					[self.root bindToObject:dict];
					[self.quickDialogTableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationBottom];
					UIImage *image = [UIImage imageWithData:data];
					CGFloat width = image.size.width * 31.0 / image.size.height;
					UIImageView *captchaImageView = [[UIImageView alloc] initWithFrame:CGRectMake(290 - width, 6, width, 31)];
					captchaImageView.image = image;
					[[[self.quickDialogTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]] contentView] addSubview:captchaImageView];
				}
				
			} error:^(CPRequest *request, NSError *error) {
				[self loading:NO];
				[self showAlert:[error description]];//NSLog(%"%@", [error description]);
			}];
		}
		
	} error:^(CPRequest *request, NSError *error) {
		[self loading:NO];
		[self showAlert:[error description]];//NSLog(%"%@", [error description]);
	}];

	[[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    [self loading:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
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
	[[[UIAlertView alloc] initWithTitle:nil
								message:message
							   delegate:nil
					  cancelButtonTitle:sCONFIRM
					  otherButtonTitles:nil] show];
}

#pragma mark - Button controllerAction

- (void)onConfirm:(UIBarButtonItem *)sender {
	NSMutableDictionary *loginInfo = [[NSMutableDictionary alloc] init];
    [self.root fetchValueUsingBindingsIntoObject:loginInfo];
	NSString *username = [loginInfo objectForKey:kAPIUSERNAME];
	NSString *password = [loginInfo objectForKey:kAPIPASSWORD];
	NSString *captcha = [loginInfo objectForKey:kAPICAPTCHA];
	
	if ([username length] <= 0) {
		[self showAlert:@"用户名不能为空！"];
		return ;
    }
	if ([password length] <= 0) {
        [self showAlert:@"密码不能为空！"];
		return ;
    }
	
	NSMutableDictionary *params = [@{ @"username":username, @"password":password } mutableCopy];
	if (captcha) [params setObject:captcha forKey:@"captcha"];
	[[Coffeepot shared] requestWithMethodPath:@"course/grabber/start/" params:params requestMethod:@"POST" success:^(CPRequest *_req, id collection) {
		[self loading:NO];
		
		// TODO collection as NSArray of courses' id
		
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:kCOURSE_IMPORTED];
		[self close];
		
	} error:^(CPRequest *request, NSError *error) {
		[self loading:NO];
		[self showAlert:[error description]];//NSLog(%"%@", [error description]);
	}];
	
	[[[UIApplication sharedApplication] keyWindow] endEditing:YES];
	[self loading:YES];
}

- (void)close
{
	[self dismissModalViewControllerAnimated:YES];
}

@end
