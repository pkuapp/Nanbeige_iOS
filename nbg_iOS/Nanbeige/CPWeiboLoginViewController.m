//
//  CPWeiboLoginViewController.m
//  CP
//
//  Created by ZongZiWang on 12-8-2.
//  Copyright (c) 2012年 Peking University. All rights reserved.
//

#import "CPWeiboLoginViewController.h"
#import "Environment.h"
#import <QuartzCore/QuartzCore.h>

@interface CPWeiboLoginViewController ()

@end

@implementation CPWeiboLoginViewController

- (id)init
{
	self = [super init];
	if (self) {
        self.navigationBar = [[UINavigationBar alloc] initWithFrame: CGRectMake(0, 0, self.view.frame.size.width, 44)];
        
        self.navigationBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [self.view addSubview:self.navigationBar];
		
		CGFloat navigationBarBottom = self.navigationBar.frame.origin.y + self.navigationBar.frame.size.height;
		UIImage *shadowImg = [UIImage imageNamed:@"NavigationBar-shadow"];
		CALayer *shadowLayer = [CALayer layer];
		shadowLayer.frame = CGRectMake(0, navigationBarBottom, self.view.frame.size.width, shadowImg.size.height);
		shadowLayer.contents = (id)shadowImg.CGImage;
		shadowLayer.zPosition = 1;
		[self.view.layer addSublayer:shadowLayer];
        
        UINavigationItem *navItem = [[UINavigationItem alloc] initWithTitle:@"连接到新浪微博"];
        navItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:sCANCEL style:UIBarButtonItemStylePlain target:self action:@selector(close)];

        [self.navigationBar pushNavigationItem: navItem animated: NO];
		
		self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, self.navigationBar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - self.navigationBar.frame.size.height)];
        self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		self.webView.delegate = self;
		
        [self.view addSubview:self.webView];
        
        self.indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		self.indicatorView.hidesWhenStopped = YES;
        self.indicatorView.center = self.webView.center;
		
        [self.view addSubview:self.indicatorView];
		
    }
	return self;
}

- (void)close
{
	[self dismissModalViewControllerAnimated:YES];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

}
- (void)viewDidAppear:(BOOL)animated
{
    NSURLRequest *request =[NSURLRequest requestWithURL:self.requestURL
                                            cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                        timeoutInterval:60.0];
    [self.webView loadRequest:request];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
	    return YES;
	} else {
	    return (interfaceOrientation == UIInterfaceOrientationPortrait);
	}
}

- (void)webViewDidStartLoad:(UIWebView *)aWebView
{
	self.indicatorView.hidden = NO;
	[self.indicatorView startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)aWebView
{
	[self.indicatorView stopAnimating];
}

- (void)webView:(UIWebView *)aWebView didFailLoadWithError:(NSError *)error
{
    [self.indicatorView stopAnimating];
}

- (BOOL)webView:(UIWebView *)aWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSRange range = [request.URL.absoluteString rangeOfString:@"code="];
    
    if (range.location != NSNotFound)
    {
        NSString *code = [request.URL.absoluteString substringFromIndex:range.location + range.length];
        
        if ([self.delegate respondsToSelector:@selector(authorizeViewController:didReceiveAuthorizeCode:)])
        {
            [self.delegate authorizeViewController:self didReceiveAuthorizeCode:code];
        }
    }
    
    return YES;
}

@end
