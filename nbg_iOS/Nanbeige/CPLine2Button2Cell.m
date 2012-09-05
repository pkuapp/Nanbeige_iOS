//
//  CPLine2Button2Cell.m
//  CP
//
//  Created by Wang Zhongyu on 12-7-13.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import "CPLine2Button2Cell.h"

@implementation CPLine2Button2Cell
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
@end
