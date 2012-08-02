//
//  NanbeigeWeiboLoginViewController.h
//  Nanbeige
//
//  Created by ZongZiWang on 12-8-2.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NanbeigeWeiboLoginDelegate <NSObject>

- (void)authorizeViewController:(UIViewController *)viewController didReceiveAuthorizeCode:(NSString *)code;

@end

@interface NanbeigeWeiboLoginViewController : UIViewController<UIWebViewDelegate>

@property (strong, nonatomic) UIWebView *webView;
@property (strong, nonatomic) id<NanbeigeWeiboLoginDelegate> delegate;
@property (strong, nonatomic) NSURL *requestURL;

@property (nonatomic, retain) UINavigationBar *navigationBar;
@property (nonatomic, assign) UIDeviceOrientation orientation;
@property (nonatomic, retain) UIActivityIndicatorView *indicatorView;

@end
