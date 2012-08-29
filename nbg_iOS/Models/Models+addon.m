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
	if (![dict isKindOfClass:[NSDictionary class]]) raise(-1);
    User *user = [self sharedAppUser];
    
	if ([dict objectForKey:@"password"]) {
		user.password = [dict objectForKey:@"password"];
	}
	if ([dict objectForKey:@"gate_id"]) {
		user.gate_id = [dict objectForKey:@"gate_id"];
	}
	if ([dict objectForKey:@"gate_password"]) {
		user.gate_password = [dict objectForKey:@"gate_password"];
	}
	
    if ([dict objectForKey:@"id"]) {
        user.id = [dict objectForKey:@"id"];
    }
    if ([dict objectForKey:@"email"]) {
        user.email = [dict objectForKey:@"email"];
    }
	if ([dict objectForKey:@"nickname"]) {
        user.nickname = [dict objectForKey:@"nickname"];
    }
	if ([dict objectForKey:@"course_imported"]) {
		user.course_imported = [dict objectForKey:@"course_imported"];
	}
	
    if ([dict objectForKey:@"weibo"] && ![[dict objectForKey:@"weibo"] isKindOfClass:[NSNull class]]) {
        user.weibo_id = [[dict objectForKey:@"weibo"] objectForKey:@"id"];
        user.weibo_name = [[dict objectForKey:@"weibo"] objectForKey:@"name"];
        user.weibo_token = [[dict objectForKey:@"weibo"] objectForKey:@"token"];
    }
    if ([dict objectForKey:@"renren"] && ![[dict objectForKey:@"renren"] isKindOfClass:[NSNull class]]) {
        user.renren_id = [[dict objectForKey:@"renren"] objectForKey:@"id"];
        user.renren_name = [[dict objectForKey:@"renren"] objectForKey:@"name"];
        user.renren_token = [[dict objectForKey:@"renren"] objectForKey:@"token"];
    }
    if ([dict objectForKey:@"university"] && ![[dict objectForKey:@"university"] isKindOfClass:[NSNull class]]) {
        user.university_id = [[dict objectForKey:@"university"] objectForKey:@"id"];
		user.university_name = [[dict objectForKey:@"university"] objectForKey:@"name"];
	}
    if ([dict objectForKey:@"campus"] && ![[dict objectForKey:@"campus"] isKindOfClass:[NSNull class]]) {
        user.campus_id = [[dict objectForKey:@"campus"] objectForKey:@"id"];
		user.campus_name = [[dict objectForKey:@"campus"] objectForKey:@"name"];
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

+ (CouchDocument *)courseListDocument
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
	} else NSLog(@"Models+addon:courseListDocument %@", queryOp.error);
	
	if (!courseListDocument) courseListDocument = [localDatabase untitledDocument];
	return courseListDocument;
}

+ (Course *)courseAtIndex:(NSInteger)index
				   courseList:(NSArray *)courseList
{
	if (index >= courseList.count) courseList = [[Course courseListDocument] propertyForKey:@"value"];
	CouchDatabase *localDatabase = [(CPAppDelegate *)([[UIApplication sharedApplication] delegate]) localDatabase];
	NSString *courseDocumentID = [courseList objectAtIndex:index];
	return [Course modelForDocument:[localDatabase documentWithID:courseDocumentID]];
}

+ (CouchDocument *)userCourseListDocument
{
	CouchDocument *courseListDocument = nil;
	CouchDatabase *localDatabase = [(CPAppDelegate *)([[UIApplication sharedApplication] delegate]) localDatabase];
	CouchDesignDocument *design = [localDatabase designDocumentWithName: @"usercourselist"];
	[design defineViewNamed:@"byID" mapBlock: MAPBLOCK({
		NSString *doc_type = [doc objectForKey:@"doc_type"];
		NSString *doc_id = [doc objectForKey:@"_id"];
		if ([doc_type isEqualToString:@"usercourselist"]) emit(doc_id, doc);
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
	} else NSLog(@"Models+addon:userCourseListDocument %@", queryOp.error);
	
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
		NSNumber *id = [doc objectForKey: @"id"];
		NSNumber *doc_id = [doc objectForKey:@"_id"];
		if ([doc_type isEqualToString:@"course"] && [id isEqualToNumber:course_id]) emit(doc_id, doc);
	}) version: @"1.0"];
	
	CouchQuery *query = [design queryViewNamed:viewName];
	RESTOperation *queryOp = [query start];
	if ([queryOp wait]) {
		for (CouchQueryRow *row in query.rows) {
			if (course && [[row.document.properties objectForKey:@"doc_type"] isEqualToString:@"course"] && [[row.document.properties objectForKey:@"id"] isEqualToNumber:course_id]) {
				NSLog(@"Models+addon:courseWithID %@", [NSString stringWithFormat:@"重复课程:%@", row.document.properties]);
				[row.document DELETE];
			}
			if ([[row.document.properties objectForKey:@"id"] isEqualToNumber:course_id])
				course = [Course modelForDocument:row.document];
		}
	} else NSLog(@"Models+addon:courseWithID %@", queryOp.error);
	if (!course) course = [[Course alloc] initWithNewDocumentInDatabase:localDatabase];
	return course;
}

@end

@implementation University (addon)

+ (University *)universityWithID:(NSNumber *)university_id
{
	University *university = nil;
	CouchDatabase *localDatabase = [(CPAppDelegate *)([[UIApplication sharedApplication] delegate]) localDatabase];
	CouchDesignDocument *design = [localDatabase designDocumentWithName: @"university"];
	NSString *viewName = [NSString stringWithFormat:@"id=%@", university_id];
	[design defineViewNamed:viewName mapBlock: MAPBLOCK({
		NSString *doc_type = [doc objectForKey:@"doc_type"];
		NSNumber *id = [doc objectForKey: @"id"];
		NSNumber *doc_id = [doc objectForKey:@"_id"];
		if ([doc_type isEqualToString:@"university"] && [id isEqualToNumber:university_id]) emit(doc_id, doc);
	}) version: @"1.0"];
	
	CouchQuery *query = [design queryViewNamed:viewName];
	RESTOperation *queryOp = [query start];
	if ([queryOp wait]) {
		for (CouchQueryRow *row in query.rows) {
			if (university && [[row.document.properties objectForKey:@"doc_type"] isEqualToString:@"university"] && [[row.document.properties objectForKey:@"id"] isEqualToNumber:university_id]) {
				NSLog(@"Models+addon:universityWithID %@", [NSString stringWithFormat:@"重复课程:%@", row.document.properties]);
				[row.document DELETE];
			}
			if ([[row.document.properties objectForKey:@"id"] isEqualToNumber:university_id])
				university = [University modelForDocument:row.document];
		}
	} else NSLog(@"Models+addon:universityWithID %@", queryOp.error);
	if (!university) university = [[University alloc] initWithNewDocumentInDatabase:localDatabase];
	return university;
}

@end

@implementation Semester (addon)

+ (Semester *)semesterWithID:(NSNumber *)semester_id
{
	Semester *semester = nil;
	CouchDatabase *localDatabase = [(CPAppDelegate *)([[UIApplication sharedApplication] delegate]) localDatabase];
	CouchDesignDocument *design = [localDatabase designDocumentWithName: @"semester"];
	NSString *viewName = [NSString stringWithFormat:@"id=%@", semester_id];
	[design defineViewNamed:viewName mapBlock: MAPBLOCK({
		NSString *doc_type = [doc objectForKey:@"doc_type"];
		NSNumber *id = [doc objectForKey: @"id"];
		NSNumber *doc_id = [doc objectForKey:@"_id"];
		if ([doc_type isEqualToString:@"semester"] && [id isEqualToNumber:semester_id]) emit(doc_id, doc);
	}) version: @"1.0"];
	
	CouchQuery *query = [design queryViewNamed:viewName];
	RESTOperation *queryOp = [query start];
	if ([queryOp wait]) {
		for (CouchQueryRow *row in query.rows) {
			if (semester && [[row.document.properties objectForKey:@"doc_type"] isEqualToString:@"semester"] && [[row.document.properties objectForKey:@"id"] isEqualToNumber:semester_id]) {
				NSLog(@"Models+addon:semesterWithID %@", [NSString stringWithFormat:@"重复课程:%@", row.document.properties]);
				[row.document DELETE];
			}
			if ([[row.document.properties objectForKey:@"id"] isEqualToNumber:semester_id])
				semester = [Semester modelForDocument:row.document];
		}
	} else NSLog(@"Models+addon:semesterWithID %@", queryOp.error);
	if (!semester) semester = [[Semester alloc] initWithNewDocumentInDatabase:localDatabase];
	return semester;
}

@end

@implementation Weekset (addon)

+ (Weekset *)weeksetWithID:(NSNumber *)weekset_id
{
	Weekset *weekset = nil;
	CouchDatabase *localDatabase = [(CPAppDelegate *)([[UIApplication sharedApplication] delegate]) localDatabase];
	CouchDesignDocument *design = [localDatabase designDocumentWithName: @"weekset"];
	NSString *viewName = [NSString stringWithFormat:@"id=%@", weekset_id];
	[design defineViewNamed:viewName mapBlock: MAPBLOCK({
		NSString *doc_type = [doc objectForKey:@"doc_type"];
		NSNumber *id = [doc objectForKey: @"id"];
		NSNumber *doc_id = [doc objectForKey:@"_id"];
		if ([doc_type isEqualToString:@"weekset"] && [id isEqualToNumber:weekset_id]) emit(doc_id, doc);
	}) version: @"1.0"];
	
	CouchQuery *query = [design queryViewNamed:viewName];
	RESTOperation *queryOp = [query start];
	if ([queryOp wait]) {
		for (CouchQueryRow *row in query.rows) {
			if (weekset && [[row.document.properties objectForKey:@"doc_type"] isEqualToString:@"weekset"] && [[row.document.properties objectForKey:@"id"] isEqualToNumber:weekset_id]) {
				NSLog(@"Models+addon:weeksetWithID %@", [NSString stringWithFormat:@"重复课程:%@", row.document.properties]);
				[row.document DELETE];
			}
			if ([[row.document.properties objectForKey:@"id"] isEqualToNumber:weekset_id])
				weekset = [Weekset modelForDocument:row.document];
		}
	} else NSLog(@"Models+addon:weeksetWithID %@", queryOp.error);
	if (!weekset) weekset = [[Weekset alloc] initWithNewDocumentInDatabase:localDatabase];
	return weekset;
}

@end