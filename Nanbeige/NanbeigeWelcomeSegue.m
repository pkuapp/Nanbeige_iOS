//
//  NanbeigeWelcomeSegue.m
//  Nanbeige
//
//  Created by ZongZiWang on 12-8-1.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import "NanbeigeWelcomeSegue.h"
#import "DoorsTransition.h"

@implementation NanbeigeWelcomeSegue

-(void) perform{
	transition = [[DoorsTransition alloc] init];
	[[HMGLTransitionManager sharedTransitionManager] setTransition:transition];
	
	[[HMGLTransitionManager sharedTransitionManager] presentModalViewController:[self destinationViewController] onViewController:[self sourceViewController]];
}

@end
