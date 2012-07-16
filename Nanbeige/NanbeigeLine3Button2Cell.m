//
//  NanbeigeLine3Button2Cell.m
//  Nanbeige
//
//  Created by Wang Zhongyu on 12-7-13.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import "NanbeigeLine3Button2Cell.h"

@implementation NanbeigeLine3Button2Cell
@synthesize statusLabel;
@synthesize detailStatusLabel;
@synthesize nameLabel;
@synthesize imageView;
@synthesize name;
@synthesize image;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setName:(NSString *)_name {
	if (![_name isEqualToString:name]) {
		name = [_name copy];
		nameLabel.text = name;
	}
}

- (void)setImage:(NSString *)_image {
	if (![_image isEqualToString:image]) {
		image = [_image copy];
		imageView.image = [UIImage imageNamed:image];
	}
}

- (void)dealloc {
	[imageView release];
	[nameLabel release];
    [statusLabel release];
    [detailStatusLabel release];
	[super dealloc];
}

-(void)showAlert:(NSString*)message{
	UIAlertView* alertView =[[UIAlertView alloc] initWithTitle:nil 
													   message:message
													  delegate:nil
											 cancelButtonTitle:@"确定"
											 otherButtonTitles:nil];
	[alertView show];
    [alertView release];
}
- (IBAction)connectFree:(id)sender {
	[self showAlert:@"连接免费！"];
}

- (IBAction)connectGlobal:(id)sender {
	[self showAlert:@"连接收费！"];
}

- (IBAction)disconnectAll:(id)sender {
	[self showAlert:@"断开连接！"];
}
@end
