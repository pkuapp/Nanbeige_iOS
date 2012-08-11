//
//  CPWelcomeSegue.m
//  CP
//
//  Created by ZongZiWang on 12-8-1.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import "CPWelcomeSegue.h"
#import "DoorsTransition.h"

@implementation CPWelcomeSegue

-(void) perform{
	transition = [[DoorsTransition alloc] init];
	[[HMGLTransitionManager sharedTransitionManager] setTransition:transition];
	
	[[HMGLTransitionManager sharedTransitionManager] presentModalViewController:[self destinationViewController] onViewController:[self sourceViewController]];
}

@end
