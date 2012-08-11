//
//  CPRenrenPostViewController.m
//  CP
//
//  Created by Wang Zhongyu on 12-7-10.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import "CPRenrenPostViewController.h"

@interface CPRenrenPostViewController () {
	CGRect originalTextViewFrame;
}

@end

@implementation CPRenrenPostViewController
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
	indicatorView = nil;
}

#pragma mark - IBAction

- (IBAction)onPostButtonPressed:(id)sender {
	// check text length
	if ([self.textToPost.text length] <= 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"状态不能为空！" message:nil delegate:nil cancelButtonTitle:sCONFIRM otherButtonTitles:nil];
        [alert show];
    }
    
	// set parameters and post
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:10];
    [params setObject:@"status.set" forKey:@"method"];
    [params setObject:self.textToPost.text forKey:@"status"];
    [renren requestWithParams:params andDelegate:self];
	[indicatorView startAnimating];
}

- (IBAction)onCancelButtonPressed:(id)sender {
	[self dismissModalViewControllerAnimated:YES];
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
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
        CGRect newTextViewFrame = textToPost.frame;
        originalTextViewFrame = textToPost.frame;
		newTextViewFrame.size.height = keyboardTop - textToPost.frame.origin.y - 20;
		
        textToPost.frame = newTextViewFrame;
    } else {
		// Keyboard is going away (down) - restore original frame
        textToPost.frame = originalTextViewFrame;
    }
	
    [UIView commitAnimations];
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

#pragma mark - RenrenDelegate

// 人人接口请求成功
- (void)renren:(Renren *)renren requestDidReturnResponse:(ROResponse*)response {
    [indicatorView stopAnimating];
    NSLog(@"%@", response.rootObject);
	[self showAlert:@"人人吐槽成功！"];
	[self dismissModalViewControllerAnimated:YES];
}
// 人人接口请求失败
- (void)renren:(Renren *)renren requestFailWithError:(ROError*)error {
    [indicatorView stopAnimating];
    NSLog(@"%@", error);
	[self showAlert:@"人人吐槽失败，请稍后再试"];
}

@end
