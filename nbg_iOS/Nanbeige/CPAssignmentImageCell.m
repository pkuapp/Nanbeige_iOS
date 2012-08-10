//
//  NanbeigeAssignmentImageCell.m
//  Nanbeige
//
//  Created by Wang Zhongyu on 12-7-17.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import "CPAssignmentImageCell.h"

@implementation CPAssignmentImageCell
@synthesize courseName;
@synthesize assignmentName;
@synthesize assignmentImage;
@synthesize assignmentTime;
@synthesize delegate;
@synthesize assignmentIndex;
@synthesize changeCompleteButton;

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

- (IBAction)changeComplete:(id)sender {
	if ([self.delegate respondsToSelector:@selector(changeComplete:)]) {
		[self.delegate changeComplete:self];
	}
}
@end
