//
//  Event.h
//  nbg_iOS
//
//  Created by ZongZiWang on 12-9-1.
//  Copyright (c) 2012年 wuhaotian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Event : CouchModel

@property (nonatomic, retain) NSString * doc_type;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * subtitle;
@property (nonatomic, retain) NSNumber * category_id;
@property (nonatomic, retain) NSString * category_name;
@property (nonatomic, retain) NSString * organizer;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSNumber * follow_count;
@property (nonatomic, retain) NSString * time;

@end
