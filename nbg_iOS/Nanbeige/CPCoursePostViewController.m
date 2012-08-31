//
//  CPCoursePostViewController.m
//  nbg_iOS
//
//  Created by ZongZiWang on 12-8-30.
//  Copyright (c) 2012年 wuhaotian. All rights reserved.
//

#import "CPCoursePostViewController.h"
#import "Models+addon.h"
#import "Coffeepot.h"

@interface CPCoursePostViewController () {
	CGRect originalTextViewFrame;
	BOOL _isKeyboardHidden;
}

@end

@implementation CPCoursePostViewController


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
	
	self.weibo = [WBEngine sharedWBEngine];
	self.renren = [Renren sharedRenren];
	
	self.view.backgroundColor = tableBgColorPlain;
	self.textToPost.backgroundColor = navBarTextColor1;
	
	// view init
	[self.textToPost becomeFirstResponder];
}
- (void)viewDidUnload
{
	[self setTextToPost:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

#pragma mark - Display Status
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
	    return YES;
	} else {
	    return (interfaceOrientation == UIInterfaceOrientationPortrait);
	}
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    if (!CGRectContainsPoint(self.textToPost.frame,[touch locationInView:self.view])) {
        if (!_isKeyboardHidden) {
            [self.textToPost resignFirstResponder];
        }
    }
}
- (void)viewWillAppear:(BOOL)animated {
    // Register notifications for when the keyboard appears
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[(CPAppDelegate *)[UIApplication sharedApplication].delegate hideProgressHud];
}

- (void)keyboardWillShow:(NSNotification*)notification {
	_isKeyboardHidden = NO;
    [self moveTextViewForKeyboard:notification up:YES];
}

- (void)keyboardWillHide:(NSNotification*)notification {
	_isKeyboardHidden = YES;
    [self moveTextViewForKeyboard:notification up:NO];
}

- (void)moveTextViewForKeyboard:(NSNotification*)notification up:(BOOL)up {
    NSDictionary *userInfo = [notification userInfo];
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardRect;
	
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    animationDuration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    keyboardRect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
	
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
	
	if (up == YES) {
        CGFloat keyboardTop = keyboardRect.origin.y;
        CGRect newTextViewFrame = self.textToPost.frame;
        originalTextViewFrame = self.textToPost.frame;
		newTextViewFrame.size.height = keyboardTop - self.textToPost.frame.origin.y - 20;
		
        self.textToPost.frame = newTextViewFrame;
    } else {
		// Keyboard is going away (down) - restore original frame
        self.textToPost.frame = originalTextViewFrame;
    }
	
    [UIView commitAnimations];
}

#pragma mark - IBAction

- (IBAction)onPostButtonPressed:(id)sender {
	// check text length
	if ([self.textToPost.text length] <= 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"状态不能为空！" message:nil delegate:nil cancelButtonTitle:sCONFIRM otherButtonTitles:nil];
        [alert show];
    }
    
	[[Coffeepot shared] requestWithMethodPath:[NSString stringWithFormat:@"course/%@/comment/add/", self.course_id] params:@{ @"content" : self.textToPost.text } requestMethod:@"POST" success:^(CPRequest *_req, id collection) {
		
		[(CPAppDelegate *)[UIApplication sharedApplication].delegate hideProgressHud];
		
		[[NSUserDefaults standardUserDefaults] setObject:@1 forKey:[NSString stringWithFormat:@"course%@_edited", self.course_id]];
		[[NSUserDefaults standardUserDefaults] synchronize];
		[self dismissModalViewControllerAnimated:YES];
		
	} error:^(CPRequest *request, NSError *error) {
		[(CPAppDelegate *)[UIApplication sharedApplication].delegate hideProgressHud];
		[self showAlert:[error description]];//NSLog(@"%@", [error description]);
	}];
	
	[self.textToPost resignFirstResponder];
	
	[(CPAppDelegate *)[UIApplication sharedApplication].delegate showProgressHud:@"七嘴八舌发送中..."];
}

- (IBAction)onCancelButtonPressed:(id)sender {
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark

-(void)showAlert:(NSString*)message{
	UIAlertView* alertView =[[UIAlertView alloc] initWithTitle:nil
													   message:message
													  delegate:nil
											 cancelButtonTitle:sCONFIRM
											 otherButtonTitles:nil];
	[alertView show];
}

#pragma mark - WBEngineDelegate Methods

- (void)engineNotAuthorized:(WBEngine *)engine
{
	[(CPAppDelegate *)[UIApplication sharedApplication].delegate hideProgressHud];
	[self showAlert:@"微博未授权，请在设置中连接微博"];
}

- (void)engineAuthorizeExpired:(WBEngine *)engine
{
	[(CPAppDelegate *)[UIApplication sharedApplication].delegate hideProgressHud];
	[self showAlert:@"微博授权已过期，请在设置中再次连接微博"];
}

- (void)engine:(WBEngine *)engine requestDidSucceedWithResult:(id)result
{
	[(CPAppDelegate *)[UIApplication sharedApplication].delegate hideProgressHud];
    NSLog(@"requestDidSucceedWithResult: %@", result);
	[self dismissModalViewControllerAnimated:YES];
}

- (void)engine:(WBEngine *)engine requestDidFailWithError:(NSError *)error
{
	[(CPAppDelegate *)[UIApplication sharedApplication].delegate hideProgressHud];
    NSLog(@"requestDidFailWithError: %@", error);
	[self showAlert:@"微博吐槽失败，请稍后再试"];
}

@end
