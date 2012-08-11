//
//  CPPickerLabel.m
//  CP
//
//  Created by Wang Zhongyu on 12-7-25.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import "CPPickerLabel.h"

@implementation CPPickerLabel
@synthesize inputView = _inputView;
@synthesize inputAccessoryView = _inputAccessoryView;
@synthesize popoverController = _popoverController;
@synthesize delegate;

#pragma mark - Setter and Getter Methods

- (void)setInputView:(UIView *)inputView
{
	if (_inputView != inputView) {
		_inputView = inputView;
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			
			UIViewController *popoverContent = [[UIViewController alloc] init];
			UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 216)];
			popoverContent.view = view;
			_inputView.frame = CGRectMake(0, 0, 320, 216);
			if (_inputView.superview) [_inputView removeFromSuperview];
			[view addSubview:_inputView];
			
			self.popoverController = [[UIPopoverController alloc] initWithContentViewController:popoverContent];
			self.popoverController.delegate = self;
		}
	}
}
- (UIView *)inputView
{
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		return nil;
	} else {
		return _inputView;
	}
}
- (UIView *)inputAccessoryView {
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		return nil;
	} else {
		return _inputAccessoryView;
	}
}

#pragma mark - View Lifecycle

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (BOOL)becomeFirstResponder {
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		CGSize pickerSize = [_inputView sizeThatFits:CGSizeZero];
		CGRect frame = _inputView.frame;
		frame.size = pickerSize;
		_inputView.frame = frame;
		self.popoverController.popoverContentSize = pickerSize;
		[self.popoverController presentPopoverFromRect:self.frame inView:self permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
		return NO;
	}
	return [super becomeFirstResponder];
}

- (BOOL)resignFirstResponder {
	[(CPAssignmentCreateViewController *)self.delegate onConfirmCoursesAfterResignFirstResponder:self];
	return [super resignFirstResponder];
}

#pragma mark - Respond to touch and become first responder.

- (BOOL)canBecomeFirstResponder {
	return YES;
}

#pragma mark - UIKeyInput Protocol Methods

- (BOOL)hasText {
	return YES;
}

- (void)insertText:(NSString *)theText {
}

- (void)deleteBackward {
}

#pragma mark - UIPopoverControllerDelegate Protocol Methods

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
	[self resignFirstResponder];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
