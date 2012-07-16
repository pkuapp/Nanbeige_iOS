//
//  NanbeigeLoginItsViewController.m
//  Nanbeige
//
//  Created by Wang Zhongyu on 12-7-13.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import "NanbeigeLoginItsViewController.h"

@interface NanbeigeLoginItsViewController ()

@end

@implementation NanbeigeLoginItsViewController
@synthesize usernameTextField;
@synthesize passwordTextField;
@synthesize usernameCell;
@synthesize passwordCell;

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
- (void)dealloc {
	[usernameTextField release];
	[passwordTextField release];
	[usernameCell release];
	[passwordCell release];
	[super dealloc];
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
        usernameTextField.placeholder = @"网关账号";
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
        
        passwordTextField.returnKeyType = UIReturnKeyGo;
        passwordTextField.delegate = self;
    }
    return passwordTextField;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField == self.passwordTextField) {
        [self.passwordTextField resignFirstResponder];
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		[defaults setValue:usernameTextField.text forKey:kITSIDKEY];
		[defaults setValue:passwordTextField.text forKey:kITSPASSWORDKEY];
		
		if (!usernameTextField.text ||
			[usernameTextField.text isEqualToString:@""] || 
			!passwordTextField.text ||
			[passwordTextField.text isEqualToString:@""]) {
			[defaults removeObjectForKey:kITSIDKEY];
			[defaults removeObjectForKey:kITSPASSWORDKEY];
		}
		
		[defaults setValue:nil forKey:_keyAccountState];
		[self dismissModalViewControllerAnimated:YES];
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
