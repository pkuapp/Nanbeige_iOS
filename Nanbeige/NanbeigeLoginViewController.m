//
//  NanbeigeLoginViewController.m
//  Nanbeige
//
//  Created by Wang Zhongyu on 12-7-15.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import "NanbeigeLoginViewController.h"
#import "Environment.h"

@interface NanbeigeLoginViewController ()

@end

@implementation NanbeigeLoginViewController
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
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
	    return YES;
	} else {
	    return (interfaceOrientation == UIInterfaceOrientationPortrait);
	}
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
        
        passwordTextField.returnKeyType = UIReturnKeyGo;
        passwordTextField.delegate = self;
    }
    return passwordTextField;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField == self.passwordTextField) {
        [self.passwordTextField resignFirstResponder];
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		[defaults setValue:usernameTextField.text forKey:kNANBEIGEIDKEY];
		[defaults setValue:passwordTextField.text forKey:kNANBEIGEPASSWORDKEY];
		
		if (!usernameTextField.text ||
			[usernameTextField.text isEqualToString:@""] || 
			!passwordTextField.text ||
			[passwordTextField.text isEqualToString:@""]) {
			[defaults removeObjectForKey:kNANBEIGEIDKEY];
			[defaults removeObjectForKey:kNANBEIGEPASSWORDKEY];
		}
		
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
