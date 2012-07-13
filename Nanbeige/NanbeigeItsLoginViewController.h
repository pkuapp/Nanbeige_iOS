//
//  NanbeigeItsLoginViewController.h
//  Nanbeige
//
//  Created by Wang Zhongyu on 12-7-12.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

#define deanImgWidth 37
#define deanImgHeight 18


@class AppUser;
@class ASINetworkQueue;
@class ASIHTTPRequest,MBProgressHUD;
@class NanbeigeAppDelegate;
@class NSManagedObjectContext;

@interface NanbeigeItsLoginViewController : UIViewController <UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,MBProgressHUDDelegate,UINavigationBarDelegate>{
    UILabel *firstlabel;
	
	UIButton *firstImg;
    UIButton *switchbutton;
	ASINetworkQueue *queueNet;
    MBProgressHUD *HUD;
    NanbeigeAppDelegate *delegate;
    NSManagedObjectContext *context;
    UITableView *tableView;
    
    UITextField *Username;
    UITextField *UserPwd;
    UITextField *validCode;
    UINavigationBar *navigationBar;
}

@property (nonatomic, retain) UITextField *Username;
@property (nonatomic, retain) UITextField *UserPwd;
@property (nonatomic, retain) UITextField *validCode;
@property (nonatomic, retain) UIButton *firstImg;
@property (nonatomic, retain) NSString *sessionid;
@property (nonatomic, readonly) NSManagedObjectContext* context;
@property (nonatomic, retain) ASIHTTPRequest *requestImg;
@property (nonatomic, retain) MBProgressHUD *HUD;
@property (nonatomic, readonly) NanbeigeAppDelegate *delegate;
@property (nonatomic, retain,readonly) AppUser *appUser;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, assign) BOOL didInputUsername;
@property (nonatomic, retain) UIActivityIndicatorView *activityView;

- (void) myLogin:(id)sender;
- (BOOL) refreshImg;

- (void)didSelectNeXTBtn;
- (void)requestFinished: (ASIHTTPRequest *)request;
- (void)requestFailed: (ASIHTTPRequest *)request;
- (void)viewDidAppear:(BOOL)animated;

- (IBAction)onCancelButtonPressed:(id)sender;

@end
