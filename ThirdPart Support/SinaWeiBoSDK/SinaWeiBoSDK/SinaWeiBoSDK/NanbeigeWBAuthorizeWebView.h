//
//  NanbeigeWBAuthorizeWebView.h
//  Nanbeige
//
//  Created by Wang Zhongyu on 12-7-9.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class NanbeigeWBAuthorizeWebView;

@protocol NanbeigeWBAuthorizeWebViewDelegate <NSObject>

- (void)authorizeWebView:(NanbeigeWBAuthorizeWebView *)webView
 didReceiveAuthorizeCode:(NSString *)code;

@end

@interface NanbeigeWBAuthorizeWebView : UIView <UIWebViewDelegate> 
{
    UIView *panelView;
    UIView *containerView;
    UIActivityIndicatorView *indicatorView;
	UIWebView *webView;
    
    UIInterfaceOrientation previousOrientation;
    
    id<NanbeigeWBAuthorizeWebViewDelegate> delegate;
}

@property (nonatomic, assign) id<NanbeigeWBAuthorizeWebViewDelegate> delegate;

- (void)loadRequestWithURL:(NSURL *)url;

- (void)show:(BOOL)animated;

- (void)hide:(BOOL)animated;

@end
