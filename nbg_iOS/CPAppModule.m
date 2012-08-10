//
//  CP.m
//  nbg_iOS
//
//  Created by wuhaotian on 12-8-7.
//  Copyright (c) 2012年 wuhaotian. All rights reserved.
//

#import "CPAppModule.h"
#import <CoreData/CoreData.h>
@protocol CoreDataContextProviderDelegete;

@implementation CPAppModule
- (void)configure {
    [self bind:[UIApplication sharedApplication] toClass:[UIApplication class]];
    [self bind:[UIApplication sharedApplication].delegate toProtocol:@protocol(UIApplicationDelegate) ];
    

//    [self bind:[NSManagedObjectContext defaultContext] toProtocol:@protocol(CoreDataContextProviderDelegete)];
}
@end
