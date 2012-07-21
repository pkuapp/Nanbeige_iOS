//
//  NanbeigeSignupViewController.m
//  Nanbeige
//
//  Created by Wang Zhongyu on 12-7-15.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import "NanbeigeSignupViewController.h"
#import "Environment.h"

@interface NanbeigeSignupViewController ()

@end

@implementation NanbeigeSignupViewController
@synthesize usernameTextField;
@synthesize passwordTextField;
@synthesize validcodeTextField;
@synthesize usernameCell;
@synthesize passwordCell;
@synthesize validcodeCell;

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
	
    [usernameCell.contentView addSubview: self.usernameTextField];
	[passwordCell.contentView addSubview: self.passwordTextField];
	[validcodeCell.contentView addSubview: self.validcodeTextField];
	
	[self.usernameTextField becomeFirstResponder];
}
- (void)viewDidUnload
{
	[self setUsernameTextField:nil];
	[self setPasswordTextField:nil];
	[self setUsernameCell:nil];
	[self setPasswordCell:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - TextField

- (UITextField *)usernameTextField{
    if (usernameTextField == nil) {
        usernameTextField = [[UITextField alloc] initWithFrame:CGRectMake(90, 11, 200, 20)];
        usernameTextField.borderStyle = UITextBorderStyleNone;
        usernameTextField.delegate = self;
        usernameTextField.keyboardType = UIKeyboardTypeASCIICapable;
        usernameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        usernameTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        usernameTextField.enablesReturnKeyAutomatically = YES;
        usernameTextField.returnKeyType = UIReturnKeyNext;
        usernameTextField.placeholder = @"南北阁账号";
        usernameTextField.delegate = self;
    }
    return  usernameTextField;
}
- (UITextField *)passwordTextField{
    if (passwordTextField == nil) {
        passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(90, 11, 200, 20)];
        passwordTextField.borderStyle = UITextBorderStyleNone;
        passwordTextField.secureTextEntry = YES;
        passwordTextField.keyboardType = UIKeyboardTypeASCIICapable;
        passwordTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        passwordTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
		
        passwordTextField.enablesReturnKeyAutomatically = YES;
        
        passwordTextField.returnKeyType = UIReturnKeyNext;
        passwordTextField.delegate = self;
    }
    return passwordTextField;
}
- (UITextField *)validcodeTextField{
    if (validcodeTextField == nil) {
        validcodeTextField = [[UITextField alloc] initWithFrame:CGRectMake(90, 11, 140, 20)];
        validcodeTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
		
        validcodeTextField.borderStyle = UITextBorderStyleNone;
        validcodeTextField.enablesReturnKeyAutomatically = YES;
        validcodeTextField.autocorrectionType = UITextAutocorrectionTypeNo;
		
        validcodeTextField.keyboardType = UIKeyboardTypeASCIICapable;
        validcodeTextField.returnKeyType = UIReturnKeyGo;
        validcodeTextField.delegate = self;
    }
    return validcodeTextField;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField == self.validcodeTextField) {
        [self.validcodeTextField resignFirstResponder];
		// TODO sign up the Username and Password
		[self dismissModalViewControllerAnimated:YES];
		return NO;
	} else if (textField == self.passwordTextField) {
        [self.validcodeTextField becomeFirstResponder];
		return NO;
    }
    else if (textField == self.usernameTextField) {
        [self.passwordTextField becomeFirstResponder];
    }
    return YES;
}

#pragma mark - IBAction

- (IBAction)onCancelButtonPressed:(id)sender {
	[self dismissModalViewControllerAnimated:YES];
}

@end
