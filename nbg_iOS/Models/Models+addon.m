//
//  User+ModelsAddon.m
//  nbg_iOS
//
//  Created by wuhaotian on 12-8-9.
//  Copyright (c) 2012年 wuhaotian. All rights reserved.
//

#import "Models+addon.h"
#import <CoreData/CoreData.h>
#import "MagicalRecord.h"

static User *sharedAppUserObject = nil;

@implementation User (addon)

+ (User *)sharedAppUser{
    @synchronized(sharedAppUserObject){
        if (!sharedAppUserObject) {
            sharedAppUserObject = [User findAll].count ? [[User findAll] objectAtIndex:0] : nil;
            if (!sharedAppUserObject) {
                sharedAppUserObject = [User createEntity];
                [[NSManagedObjectContext defaultContext] save];
            }
        }
    }
    return sharedAppUserObject;
}

+ (void)updateSharedAppUserProfile:(NSDictionary *)dict {
    User *user = [self sharedAppUser];
    
    if ([dict objectForKey:@"id"]) {
        user.id = [dict objectForKey:@"id"];
    }
	if ([dict objectForKey:@"nickname"]) {
        user.nickname = [dict objectForKey:@"nickname"];
    }
	
    if ([dict objectForKey:@"email"]) {
        user.email = [dict objectForKey:@"email"];
    }
    if ([dict objectForKey:@"weibo_token"]) {
        user.weibo_token = [dict objectForKey:@"weibo_token"];
    }
    if ([dict objectForKey:@"renren_token"]) {
        user.renren_token = [dict objectForKey:@"renren_token"];
    }
	if ([dict objectForKey:@"weibo_name"]) {
		user.weibo_name = [dict objectForKey:@"weibo_name"];
	}
	if ([dict objectForKey:@"renren_name"]) {
		user.renren_name = [dict objectForKey:@"renren_name"];
	}
	
    if ([dict objectForKey:@"university"] && ![[dict objectForKey:@"university"] isKindOfClass:[NSNull class]]) {
        user.university_name = [[dict objectForKey:@"university"] objectForKey:@"name"];
        user.university_id = [[dict objectForKey:@"university"] objectForKey:@"id"];
    }
	
    if ([dict objectForKey:@"campus"] && ![[dict objectForKey:@"campus"] isKindOfClass:[NSNull class]]) {
        user.campus_name = [[dict objectForKey:@"campus"] objectForKey:@"name"];
        user.campus_id = [[dict objectForKey:@"campus"] objectForKey:@"id"];
    }
	
    [[NSManagedObjectContext defaultContext] save];
}

+ (void)deactiveSharedAppUser
{
	@synchronized(sharedAppUserObject){
        if (sharedAppUserObject) {
            [sharedAppUserObject deleteEntity];
			sharedAppUserObject = nil;
			[[NSManagedObjectContext defaultContext] save];
        }
    }
}

@end


@implementation Course (addon)

+ (CouchDocument *)userCourseListDocument
{
	CouchDocument *courseListDocument = nil;
	CouchDatabase *localDatabase = [(CPAppDelegate *)([[UIApplication sharedApplication] delegate]) localDatabase];
	CouchDesignDocument *design = [localDatabase designDocumentWithName: @"courselist"];
	[design defineViewNamed:@"byID" mapBlock: MAPBLOCK({
		NSString *doc_type = [doc objectForKey:@"doc_type"];
		NSString *doc_id = [doc objectForKey:@"_id"];
		if ([doc_type isEqualToString:@"courselist"]) emit(doc_id, doc);
	}) version: @"1.0"];
	CouchQuery *query = [design queryViewNamed:@"byID"];
	RESTOperation *queryOp = [query start];
	if ([queryOp wait]) {
		for (CouchQueryRow *row in query.rows) {
			if (courseListDocument) {
				NSLog(@"重复课程列表:%@", row.document.properties);
				[row.document DELETE];
			}
			courseListDocument = row.document;
		}
	} else NSLog(@"%@", queryOp.error);
	
	if (!courseListDocument) courseListDocument = [localDatabase untitledDocument];
	return courseListDocument;
}

+ (Course *)userCourseAtIndex:(NSInteger)index
				   courseList:(NSArray *)courseList
{
	if (index >= courseList.count) courseList = [[Course userCourseListDocument] propertyForKey:@"value"];
	CouchDatabase *localDatabase = [(CPAppDelegate *)([[UIApplication sharedApplication] delegate]) localDatabase];
	NSString *courseDocumentID = [courseList objectAtIndex:index];
	return [Course modelForDocument:[localDatabase documentWithID:courseDocumentID]];
}

+ (Course *)courseWithID:(NSNumber *)course_id
{
	Course *course = nil;
	CouchDatabase *localDatabase = [(CPAppDelegate *)([[UIApplication sharedApplication] delegate]) localDatabase];
	CouchDesignDocument *design = [localDatabase designDocumentWithName: @"course"];
	NSString *viewName = [NSString stringWithFormat:@"id=%@", course_id];
	[design defineViewNamed:viewName mapBlock: MAPBLOCK({
		NSString *doc_type = [doc objectForKey:@"doc_type"];
		NSNumber *course_id = [doc objectForKey: @"id"];
		NSNumber *doc_id = [doc objectForKey:@"_id"];
		if ([doc_type isEqualToString:@"course"] && [course_id isEqualToNumber:course_id]) emit(doc_id, doc);
	}) version: @"1.0"];
	
	CouchQuery *query = [design queryViewNamed:viewName];
	RESTOperation *queryOp = [query start];
	if ([queryOp wait]) {
		for (CouchQueryRow *row in query.rows) {
			if (course && [[row.document.properties objectForKey:@"doc_type"] isEqualToString:@"course"] && [[row.document.properties objectForKey:@"id"] isEqualToNumber:course_id]) {
				NSLog(@"%@", [NSString stringWithFormat:@"重复课程:%@", row.document.properties]);
				[row.document DELETE];
			}
			if ([[row.document.properties objectForKey:@"id"] isEqualToNumber:course_id])
				course = [Course modelForDocument:row.document];
		}
	} else NSLog(@"%@", queryOp.error);
	if (!course) course = [[Course alloc] initWithNewDocumentInDatabase:localDatabase];
	return course;
}

@end
