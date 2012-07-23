//
//  NanbeigeLine2Button2Cell.m
//  Nanbeige
//
//  Created by Wang Zhongyu on 12-7-13.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import "NanbeigeLine2Button2Cell.h"

@implementation NanbeigeLine2Button2Cell
@synthesize nameLabel;
@synthesize imageView;
@synthesize name;
@synthesize image;
@synthesize delegate;

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

- (IBAction)onButton1Pressed:(id)sender {
	if ([self.delegate respondsToSelector:@selector(onButton1Pressed:)]) {
		[self.delegate onButton1Pressed:sender];
	}
}

- (IBAction)onButton2Pressed:(id)sender {
	if ([self.delegate respondsToSelector:@selector(onButton2Pressed:)]) {
		[self.delegate onButton2Pressed:sender];
	}
}
@end
