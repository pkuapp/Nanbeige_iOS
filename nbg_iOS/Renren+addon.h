//
//  Renren+addon.h
//  nbg_iOS
//
//  Created by ZongZiWang on 12-8-12.
//  Copyright (c) 2012年 wuhaotian. All rights reserved.
//

#import "Renren.h"
#import "ROConnect.h"
#import "CPBlockHandler.h"

@interface Renren (addon)

- (void)requestWithParam:(RORequestParam *)param
			 andDelegate:(id <RenrenDelegate>)delegate
				 success:(void (^)(RORequest *request, id result))success_block
					fail:(void (^)(RORequest *request, ROError *error))fail_block;

@end
