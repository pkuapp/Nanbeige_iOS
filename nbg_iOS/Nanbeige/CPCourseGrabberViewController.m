//
//  CPCourseGrabberViewController.m
//  CP
//
//  Created by ZongZiWang on 12-8-10.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import "CPCourseGrabberViewController.h"
#import "Environment.h"
#import "Coffeepot.h"
#import "Models+addon.h"

@interface CPCourseGrabberViewController () {

}

@end

@implementation CPCourseGrabberViewController

#pragma mark - Setter and Getter Methods

- (void)setQuickDialogTableView:(QuickDialogTableView *)aQuickDialogTableView {
    [super setQuickDialogTableView:aQuickDialogTableView];
	[self.quickDialogTableView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg-TableView"]]];
}

#pragma mark - View Lifecycle

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self) {
		self.root = [[QRootElement alloc] initWithJSONFile:@"courseGrabber"];
		self.resizeWhenKeyboardPresented = YES;
	}
	return self;
}

- (id)init
{
	self = [super init];
	if (self) {
		self.root = [[QRootElement alloc] initWithJSONFile:@"courseGrabber"];
		self.resizeWhenKeyboardPresented = YES;
	}
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	UIBarButtonItem *loginButton = [UIBarButtonItem styledBlueBarButtonItemWithTitle:sCONFIRM target:self selector:@selector(onConfirm:)];
	UIBarButtonItem *closeButton = [UIBarButtonItem styledPlainBarButtonItemWithTitle:sCANCEL target:self selector:@selector(close)];
	self.navigationItem.rightBarButtonItem = loginButton;
	self.navigationItem.leftBarButtonItem = closeButton;

	[[Coffeepot shared] requestWithMethodPath:@"course/grabber/" params:nil requestMethod:@"POST" success:^(CPRequest *_req, id collection) {
		
		if (![collection isKindOfClass:[NSDictionary class]] || ![[collection objectForKey:@"available"] boolValue]) {
			
			[self loading:NO];
			
			[self showAlert:@"该学期抓课器暂不可用"];
			[self performSelector:@selector(close) withObject:nil afterDelay:1.0];
			
		} else if ([[collection objectForKey:@"require_captcha"] boolValue]) {
			
			[[Coffeepot shared] requestWithMethodPath:@"course/grabber/captcha/" params:nil requestMethod:@"GET" raw:^(CPRequest *_req, NSData *data) {
				
				if ([data isKindOfClass:[NSData class]]) {
					
					NSDictionary *dict = @{@"captcha":@[@{ @"placeholder" : @"验证码" }]};
					[self.root bindToObject:dict];
					UIImage *image = [UIImage imageWithData:data];
					CGFloat width = image.size.width * 31.0 / image.size.height;
					UIImageView *captchaImageView = [[UIImageView alloc] initWithFrame:CGRectMake(252 - width, 6, width, 31)];
					captchaImageView.image = image;
					
					[self.quickDialogTableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationBottom];
					[[[self.quickDialogTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]] contentView] addSubview:captchaImageView];
					
					[self loading:NO];
					
				} else {
					[self loading:NO];
					[self showAlert:@"验证码返回非NSData"];
				}
				
			} error:^(CPRequest *request, NSError *error) {
				[self loading:NO];
				if ([error.userInfo objectForKey:@"error"]) [self showAlert:[error.userInfo objectForKey:@"error"]]; else [self showAlert:[error description]];//NSLog(@"%@", [error description]);
			}];
		}
		
	} error:^(CPRequest *request, NSError *error) {
		[self loading:NO];
		if ([error.userInfo objectForKey:@"error"]) [self showAlert:[error.userInfo objectForKey:@"error"]]; else [self showAlert:[error description]];//NSLog(@"%@", [error description]);
	}];

	[[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    [self loading:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

#pragma mark - Display

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
	    return YES;
	} else {
	    return (interfaceOrientation == UIInterfaceOrientationPortrait);
	}
}

-(void)showAlert:(NSString*)message{
	[[[UIAlertView alloc] initWithTitle:nil
								message:message
							   delegate:nil
					  cancelButtonTitle:sCONFIRM
					  otherButtonTitles:nil] show];
}

#pragma mark - Button controllerAction

- (void)onConfirm:(UIBarButtonItem *)sender {
	NSMutableDictionary *loginInfo = [[NSMutableDictionary alloc] init];
    [self.root fetchValueUsingBindingsIntoObject:loginInfo];
	NSString *username = [loginInfo objectForKey:kAPIUSERNAME];
	NSString *password = [loginInfo objectForKey:kAPIPASSWORD];
	NSString *captcha = [loginInfo objectForKey:kAPICAPTCHA];
	
	if ([username length] <= 0) {
		[self showAlert:@"用户名不能为空！"];
		return ;
    }
	if ([password length] <= 0) {
        [self showAlert:@"密码不能为空！"];
		return ;
    }
	
	NSMutableDictionary *params = [@{ @"username":username, @"password":password } mutableCopy];
	if (captcha) [params setObject:captcha forKey:@"captcha"];
	[[Coffeepot shared] requestWithMethodPath:@"course/grabber/start/" params:params requestMethod:@"POST" success:^(CPRequest *_req, id collection) {
		
		NSDictionary *dict;
		if ([User sharedAppUser].course_imported) dict = @{ @"course_imported" : [[User sharedAppUser].course_imported arrayByAddingObject:[collection objectForKey:@"semester_id"]] };
		else dict = @{ @"course_imported" : [collection objectForKey:@"semester_id"] };
		
		[User updateSharedAppUserProfile:dict];
		
		[[Coffeepot shared] requestWithMethodPath:@"course/" params:nil requestMethod:@"GET" success:^(CPRequest *_req, id collection) {
			
			CouchDatabase *localDatabase = [(CPAppDelegate *)([[UIApplication sharedApplication] delegate]) localDatabase];
			
			if ([collection isKindOfClass:[NSArray class]]) {
				
				NSMutableArray *courses = [[NSMutableArray alloc] init];
				for (NSDictionary *courseDict in collection) {
					
					Course *course = [Course courseWithID:[courseDict objectForKey:@"id"]];
					
					course.doc_type = @"course";
					course.status = [courseDict objectForKey:@"status"];
					course.id = [courseDict objectForKey:@"id"];
					course.name = [courseDict objectForKey:@"name"];
					course.credit = [courseDict objectForKey:@"credit"];
					course.orig_id = [courseDict objectForKey:@"orig_id"];
					course.semester_id = [courseDict objectForKey:@"semester_id"];
					course.ta = [courseDict objectForKey:@"ta"];
					course.teacher = [courseDict objectForKey:@"teacher"];
					
					if (course.lessons) {
						for (NSString *lessonDocumentID in course.lessons) {
							CouchDocument *lessonDocument = [localDatabase documentWithID:lessonDocumentID];
							RESTOperation *deleteOp = [lessonDocument DELETE];
							if (![deleteOp wait])
								[self showAlert:[deleteOp.error description]];
						}
					}
					
					NSMutableArray *lessons = [[NSMutableArray alloc] init];
					for (NSDictionary *lessonDict in [courseDict objectForKey:@"lessons"]) {
						
						Lesson *lesson = [[Lesson alloc] initWithNewDocumentInDatabase:localDatabase];
						
						lesson.doc_type = @"lesson";
						lesson.course = course;
						lesson.start = [lessonDict objectForKey:@"start"];
						lesson.end = [lessonDict objectForKey:@"end"];
						lesson.day = [lessonDict objectForKey:@"day"];
						lesson.location = [lessonDict objectForKey:@"location"];
						lesson.weekset_id = [lessonDict objectForKey:@"weekset_id"];
						
						RESTOperation *lessonSaveOp = [lesson save];
						if (lessonSaveOp && ![lessonSaveOp wait])
							[self showAlert:[lessonSaveOp.error description]];
						else
							[lessons addObject:lesson.document.documentID];
						
					}
					course.lessons = lessons;
					
					RESTOperation *courseSaveOp = [course save];
					if (courseSaveOp && ![courseSaveOp wait])
						[self showAlert:[courseSaveOp.error description]];
					else
						[courses addObject:course.document.documentID];
					
				}
				
				NSMutableDictionary *courseListDict = [@{ @"doc_type" : @"usercourselist", @"value" : courses } mutableCopy];
				CouchDocument *courseListDocument = [Course userCourseListDocument];
				if ([courseListDocument propertyForKey:@"_rev"]) [courseListDict setObject:[courseListDocument propertyForKey:@"_rev"] forKey:@"_rev"];
				RESTOperation *putOp = [courseListDocument putProperties:courseListDict];
				if (![putOp wait])
					[self showAlert:[putOp.error description]];
				else
					[self close];
				
				[self loading:NO];
				
			} else {
				[self loading:NO];
				[self showAlert:@"返回结果不是NSArray"];
			}
			
		} error:^(CPRequest *request, NSError *error) {
			[self loading:NO];
			if ([error.userInfo objectForKey:@"error"]) [self showAlert:[error.userInfo objectForKey:@"error"]]; else [self showAlert:[error description]];//NSLog(@"%@", [error description]);
		}];
		
	} error:^(CPRequest *request, NSError *error) {
		[self loading:NO];
		if ([error.userInfo isKindOfClass:[NSDictionary class]] && [error.userInfo objectForKey:@"error_code"]) {
			NSString *errorCode = [error.userInfo objectForKey:@"error_code"];
			if ([errorCode isEqualToString:@"AuthError"]) [self showAlert:@"用户名或密码错误"];
			else if ([errorCode isEqualToString:@"GrabberExpired"]) [self showAlert:@"验证码过期"];
			else if ([errorCode isEqualToString:@"CaptchaError"]) [self showAlert:@"验证码错误"];
			else if ([errorCode isEqualToString:@"UnknownLoginError"]) [self showAlert:@"未知登录错误"];
			else if ([errorCode isEqualToString:@"GrabError"]) [self showAlert: [error.userInfo objectForKey:@"error"]];
			else [self showAlert:errorCode];
		} else if ([error.userInfo objectForKey:@"error"]) [self showAlert:[error.userInfo objectForKey:@"error"]]; else [self showAlert:[error description]];//NSLog(@"%@", [error description]);
	}];
	
	[[[UIApplication sharedApplication] keyWindow] endEditing:YES];
	[self loading:YES];
}

- (void)close
{
	[self dismissModalViewControllerAnimated:YES];
}

- (void)loading:(BOOL)value
{
	if (!value) {
		[self.quickDialogTableView deselectRowAtIndexPath:[self.quickDialogTableView indexPathForSelectedRow] animated:YES];
	}
	[super loading:value];
}

@end
