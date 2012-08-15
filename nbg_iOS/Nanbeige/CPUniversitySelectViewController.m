//
//  CPChooseSchoolViewController.m
//  CP
//
//  Created by ZongZiWang on 12-8-1.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import "CPUniversitySelectViewController.h"
#import "Environment.h"
#import "Coffeepot.h"
#import "Models+addon.h"

@interface CPUniversitySelectViewController () {
	NSMutableArray *campuses;
}

@end

@implementation CPUniversitySelectViewController

#pragma mark - Setter and Getter Methods

- (void)setQuickDialogTableView:(QuickDialogTableView *)aQuickDialogTableView {
    [super setQuickDialogTableView:aQuickDialogTableView];
    self.quickDialogTableView.backgroundView = nil;
    self.quickDialogTableView.backgroundColor = tableBgColor1;
	self.quickDialogTableView.deselectRowWhenViewAppears = YES;
}

#pragma mark - View Lifecycle

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self) {
		self.root = [[QRootElement alloc] initWithJSONFile:@"universitySelect"];
	}
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"欢迎" style:UIBarButtonItemStyleBordered target:nil action:nil];
	if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"CPIsSignedIn"] boolValue]) {
		UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:sCANCEL style:UIBarButtonItemStyleBordered target:self action:@selector(close)];
		self.navigationItem.leftBarButtonItem = closeButton;
		self.navigationController.navigationBar.tintColor = navBarBgColor1;
	}
	
	[[Coffeepot shared] requestWithMethodPath:@"university/" params:nil requestMethod:@"GET" success:^(CPRequest *_req, id collection) {
		[self loading:NO];
		
		campuses = [[NSMutableArray alloc] init];
		for (NSDictionary *university in collection) {
			for (NSDictionary *campus in [university objectForKey:@"campuses"]) {
				NSDictionary *displayCampus = @{
				@"campus" : @{
					@"id" : [campus objectForKey:@"id"],
					@"name" : [campus objectForKey:@"name"]},
				@"university" : @{
					@"id" : [university objectForKey:@"id"],
					@"name" : [university objectForKey:@"name"]},
				@"display_name" : [[university objectForKey:@"name"] stringByAppendingFormat:@" %@", [campus objectForKey:@"name"]]};
				[campuses addObject:displayCampus];
			}
		}
		
		NSDictionary *dict = @{@"campuses":campuses};
		[self.root bindToObject:dict];
		[self.quickDialogTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationBottom];
		
	} error:^(CPRequest *_req, id collection, NSError *error) {
		[self loading:NO];
		if ([collection isKindOfClass:[NSDictionary class]] && [collection objectForKey:@"error"])
			[self showAlert:[collection objectForKey:@"error"]];//raise(-1);
		if ([collection isKindOfClass:[NSDictionary class]] && [collection objectForKey:@"error_code"])
			[self showAlert:[collection objectForKey:@"error_code"]];//raise(-1);
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

- (void)close
{
	[self dismissModalViewControllerAnimated:YES];
}

- (void)onCampusSelect:(id)sender
{
	NSUInteger index = [[[sender parentSection] elements] indexOfObject:sender];
	NSDictionary *campus = [campuses objectAtIndex:index];
	[User updateSharedAppUserProfile:campus];
	
	[[Coffeepot shared] requestWithMethodPath:@"user/edit/" params:@{ @"campus_id" : [[campus objectForKey:@"campus"] objectForKey:@"id"] } requestMethod:@"POST" success:^(CPRequest *_req, id collection) {
		[self loading:NO];
		
		[[Coffeepot shared] requestWithMethodPath:[NSString stringWithFormat:@"university/%@/", [User sharedAppUser].university_id] params:nil requestMethod:@"GET" success:^(CPRequest *_req, id collection) {
			[self loading:NO];
			
//			NSMutableDictionary *mutableResult = [collection mutableCopy];
//			[mutableResult setObject:[User sharedAppUser].university_id forKey:@"id"];
//			[mutableResult setObject:@"university" forKey:@"doc_type"];
//			
//			CouchDatabase *localDatabase = [(CPAppDelegate *)([[UIApplication sharedApplication] delegate]) localDatabase];
//			CouchDocument *doc = [localDatabase documentWithID:[NSString stringWithFormat:@"university%@", [[User sharedAppUser] university_id]]];
//			if ([doc propertyForKey:@"_rev"]) [mutableResult setObject:[doc propertyForKey:@"_rev"] forKey:@"_rev"];
//			RESTOperation *op = [doc putProperties:mutableResult];

			if (![collection isKindOfClass:[NSDictionary class]]) return ;
			NSDictionary *universityDict = collection;
			
			University *university = [University universityWithID:[User sharedAppUser].university_id];
			university.doc_type = @"university";
			university.id = [User sharedAppUser].university_id;
			university.name = [universityDict objectForKey:@"name"];
			university.support_import_course = [[universityDict objectForKey:@"support"] objectForKey:@"import_course"];
			university.support_list_course = [[universityDict objectForKey:@"support"] objectForKey:@"list_course"];
			university.lessons_count_afternoon = [[[universityDict objectForKey:@"lessons"] objectForKey:@"count"] objectForKey:@"afternoon"];
			university.lessons_count_evening = [[[universityDict objectForKey:@"lessons"] objectForKey:@"count"] objectForKey:@"evening"];
			university.lessons_count_morning = [[[universityDict objectForKey:@"lessons"] objectForKey:@"count"] objectForKey:@"morning"];
			university.lessons_count_total = [[[universityDict objectForKey:@"lessons"] objectForKey:@"count"] objectForKey:@"total"];
			university.lessons_detail = [[universityDict objectForKey:@"lessons"] objectForKey:@"detail"];
			university.lessons_separators = [[universityDict objectForKey:@"lessons"] objectForKey:@"separators"];
			
			RESTOperation *op = [university save];
			[op onCompletion:^{
				if (op.error) NSLog(@"%@", op.error);
				else if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"CPIsSignedIn"] boolValue]) {
					[self dismissModalViewControllerAnimated:YES];
				} else {
					[self performSegueWithIdentifier:@"SigninConfirmSegue" sender:self];
				}
			}];
			
		} error:^(CPRequest *_req, id collection, NSError *error) {
			[self loading:NO];
			if ([collection isKindOfClass:[NSDictionary class]] && [collection objectForKey:@"error"])
				[self showAlert:[collection objectForKey:@"error"]];//raise(-1);
			if ([collection isKindOfClass:[NSDictionary class]] && [collection objectForKey:@"error_code"])
				[self showAlert:[collection objectForKey:@"error_code"]];//raise(-1);
		}];
		
		[[[UIApplication sharedApplication] keyWindow] endEditing:YES];
		[self loading:YES];
		
	} error:^(CPRequest *_req, id collection, NSError *error) {
		[self loading:NO];
		if ([collection isKindOfClass:[NSDictionary class]] && [collection objectForKey:@"error"])
			[self showAlert:[collection objectForKey:@"error"]];//raise(-1);
		if ([collection isKindOfClass:[NSDictionary class]] && [collection objectForKey:@"error_code"])
			[self showAlert:[collection objectForKey:@"error_code"]];//raise(-1);
	}];
	
	[[[UIApplication sharedApplication] keyWindow] endEditing:YES];
	[self loading:YES];
}

@end
