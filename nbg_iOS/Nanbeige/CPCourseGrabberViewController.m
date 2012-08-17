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
    self.quickDialogTableView.backgroundView = nil;
    self.quickDialogTableView.backgroundColor = tableBgColorGrouped;
    self.quickDialogTableView.bounces = YES;
}

#pragma mark - View Lifecycle

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self) {
		self.root = [[QRootElement alloc] initWithJSONFile:@"courseGrabber"];
	}
	return self;
}

- (id)init
{
	self = [super init];
	if (self) {
		self.root = [[QRootElement alloc] initWithJSONFile:@"courseGrabber"];
	}
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	UIBarButtonItem *loginButton = [[UIBarButtonItem alloc] initWithTitle:sCONFIRM style:UIBarButtonItemStyleBordered target:self action:@selector(onConfirm:)];
	UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:sCANCEL style:UIBarButtonItemStyleBordered target:self action:@selector(close)];
	self.navigationItem.rightBarButtonItem = loginButton;
	self.navigationItem.leftBarButtonItem = closeButton;
	
	self.navigationController.navigationBar.tintColor = navBarBgColor1;
	NSMutableDictionary *titleTextAttributes = [self.navigationController.navigationBar.titleTextAttributes mutableCopy];
	if (!titleTextAttributes) titleTextAttributes = [@{} mutableCopy];
	[titleTextAttributes setObject:navBarTextColor1 forKey:UITextAttributeTextColor];
	[titleTextAttributes setObject:[NSValue valueWithUIOffset:UIOffsetMake(0, 0)] forKey:UITextAttributeTextShadowOffset];
	self.navigationController.navigationBar.titleTextAttributes = titleTextAttributes;

	[[Coffeepot shared] requestWithMethodPath:@"course/grabber/" params:nil requestMethod:@"POST" success:^(CPRequest *_req, id collection) {
		
		if (![collection isKindOfClass:[NSDictionary class]] || ![[collection objectForKey:@"available"] boolValue]) {
			
			[self loading:NO];
			
			[self showAlert:@"抓课器暂不可用"];
			[self performSelector:@selector(close) withObject:nil afterDelay:1.0];
			
		} else if ([[collection objectForKey:@"require_captcha"] boolValue]) {
			
			[[Coffeepot shared] requestWithMethodPath:@"course/grabber/captcha/" params:nil requestMethod:@"GET" raw:^(CPRequest *_req, NSData *data) {
				
				if ([data isKindOfClass:[NSData class]]) {
					
					NSDictionary *dict = @{@"captcha":@[@{ @"placeholder" : @"验证码" }]};
					[self.root bindToObject:dict];
					UIImage *image = [UIImage imageWithData:data];
					CGFloat width = image.size.width * 31.0 / image.size.height;
					UIImageView *captchaImageView = [[UIImageView alloc] initWithFrame:CGRectMake(290 - width, 6, width, 31)];
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
				[self showAlert:[error description]];//NSLog(%"%@", [error description]);
			}];
		}
		
	} error:^(CPRequest *request, NSError *error) {
		[self loading:NO];
		[self showAlert:[error description]];//NSLog(%"%@", [error description]);
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
		
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:kCOURSE_IMPORTED];
		
		[[Coffeepot shared] requestWithMethodPath:@"course/" params:nil requestMethod:@"GET" success:^(CPRequest *_req, id collection) {
			
			CouchDatabase *localDatabase = [(CPAppDelegate *)([[UIApplication sharedApplication] delegate]) localDatabase];
			
			if ([collection isKindOfClass:[NSArray class]]) {
				
				NSMutableArray *courses = [[NSMutableArray alloc] init];
				for (NSDictionary *courseDict in collection) {
					
					Course *course = [Course courseWithID:[courseDict objectForKey:@"id"]];
					
					NSLog(@"%@", course.document.documentID);
					
					course.doc_type = @"course";
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
							if (![deleteOp wait]) NSLog(@"%@", deleteOp.error);
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
						lesson.week = [lessonDict objectForKey:@"week"];
						
						RESTOperation *saveOp = [lesson save];
						if ([saveOp wait])
							[lessons addObject:lesson.document.documentID];
						else NSLog(@"%@", saveOp.error);
						
					}
					course.lessons = lessons;
					
					RESTOperation *saveOp = [course save];
					if ([saveOp wait]) [courses addObject:course.document.documentID];
					else [self showAlert:[saveOp.error description]];
					
				}
				
				NSMutableDictionary *courseListDict = [@{ @"doc_type" : @"courselist", @"value" : courses } mutableCopy];
				CouchDocument *courseListDocument = [Course userCourseListDocument];
				if ([courseListDocument propertyForKey:@"_rev"]) [courseListDict setObject:[courseListDocument propertyForKey:@"_rev"] forKey:@"_rev"];
				RESTOperation *putOp = [courseListDocument putProperties:courseListDict];
				
				if (![putOp wait]) [self showAlert:[putOp.error description]];
				else [self close];
				
				[self loading:NO];
				
			} else {
				[self loading:NO];
				[self showAlert:@"返回结果不是NSArray"];
			}
			
		} error:^(CPRequest *request, NSError *error) {
			[self loading:NO];
			[self showAlert:[error description]];//NSLog(%"%@", [error description]);
		}];
		
	} error:^(CPRequest *request, NSError *error) {
		[self loading:NO];
		[self showAlert:[error description]];//NSLog(%"%@", [error description]);
	}];
	
	[[[UIApplication sharedApplication] keyWindow] endEditing:YES];
	[self loading:YES];
}

- (void)close
{
	[self dismissModalViewControllerAnimated:YES];
}

@end
