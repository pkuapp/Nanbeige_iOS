//
//  NanbeigeRenrenPostViewController.m
//  Nanbeige
//
//  Created by Wang Zhongyu on 12-7-10.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import "NanbeigeRenrenPostViewController.h"

@interface NanbeigeRenrenPostViewController ()

@end

@implementation NanbeigeRenrenPostViewController
@synthesize textToPost;

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
	
	// renren init
	renren = [Renren sharedRenren];
	
	// view init
	[self.textToPost becomeFirstResponder];
	indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	[indicatorView setCenter:CGPointMake(160, 240)];
    [self.view addSubview:indicatorView];
}
- (void)viewDidUnload
{
	[self setTextToPost:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    [indicatorView release], indicatorView = nil;
}
- (void)dealloc {
	[textToPost release];
	[super dealloc];
}

#pragma mark - IBAction

- (IBAction)onPostButtonPressed:(id)sender {
	// check text length
	if ([self.textToPost.text length] <= 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"状态不能为空！" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    
	// set parameters and post
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:10];
    [params setObject:@"status.set" forKey:@"method"];
    [params setObject:self.textToPost.text forKey:@"status"];
    [renren requestWithParams:params andDelegate:self];
	[indicatorView startAnimating];
}

#pragma mark - Display Status

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
	    return (interfaceOrientation == UIInterfaceOrientationPortrait);
		//return YES;
	} else {
	    return (interfaceOrientation == UIInterfaceOrientationPortrait);
	}
}
- (void)keyboardWillShow:(NSNotification *)notification
{
    _isKeyboardHidden = NO;
}
- (void)keyboardWillHide:(NSNotification *)notification
{
    _isKeyboardHidden = YES;
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    if (!CGRectContainsPoint(self.textToPost.frame,[touch locationInView:self.view])) {
        if (!_isKeyboardHidden) {
            [self.textToPost resignFirstResponder];
        }
    }
}

#pragma mark

-(void)showAlert:(NSString*)message{
	UIAlertView* alertView =[[UIAlertView alloc] initWithTitle:nil 
													   message:message
													  delegate:nil
											 cancelButtonTitle:@"确定"
											 otherButtonTitles:nil];
	[alertView show];
    [alertView release];
}

#pragma mark - RenrenDelegate

// 人人接口请求成功
- (void)renren:(Renren *)renren requestDidReturnResponse:(ROResponse*)response {
    [indicatorView stopAnimating];
    NSLog(@"%@", response.rootObject);
	[self showAlert:@"人人吐槽成功！"];
	[self.navigationController popViewControllerAnimated:YES];
}
// 人人接口请求失败
- (void)renren:(Renren *)renren requestFailWithError:(ROError*)error {
    [indicatorView stopAnimating];
    NSLog(@"%@", [error localizedDescription]);
	[self showAlert:@"人人吐槽失败，请稍后再试"];
}

@end
