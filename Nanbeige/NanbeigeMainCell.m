//
//  NanbeigeMainCell.m
//  Nanbeige
//
//  Created by Wang Zhongyu on 12-7-9.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import "NanbeigeMainCell.h"

#define knameLabelTag 1
#define kImageValueTag 2

@implementation NanbeigeMainCell
@synthesize name;
@synthesize image;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
		
		CGRect imageImageRect;
		if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
			// TODO
			imageImageRect = CGRectMake(5, 5, 64, 64);
		} else {
			imageImageRect = CGRectMake(5, 5, 64, 64);
		}
		UIImageView *imageImage = [[UIImageView alloc] initWithFrame:imageImageRect];
		imageImage.tag = kImageValueTag;
		imageImage.image = [UIImage imageNamed:image];
		[self.contentView addSubview:imageImage];
		
		CGRect nameLabelRect;
		if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
			// TODO
			nameLabelRect = CGRectMake(74, 5, 256, 64);
		} else {
			nameLabelRect = CGRectMake(74, 5, 256, 64);
		}
		UILabel *nameLabel = [[UILabel alloc] initWithFrame: nameLabelRect];
		nameLabel.tag = knameLabelTag;
		[self.contentView addSubview:nameLabel];
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
		UILabel *nameLabel = (UILabel *)[self.contentView viewWithTag: knameLabelTag];
		nameLabel.text = name;
	}
}

- (void)setImage:(NSString *)_image {
	if (![_image isEqualToString:image]) {
		image = [_image copy];
		UIImageView *imageImage = (UIImageView *)[self.contentView viewWithTag:kImageValueTag];
		imageImage.image = [UIImage imageNamed:image];
	}
}

@end
