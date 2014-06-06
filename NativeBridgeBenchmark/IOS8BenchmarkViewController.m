//
//  IOS8BenchmarkViewController.m
//  NativeBridgeBenchmark
//
//  Created by Matti Paksula on 06/06/14.
//
//


#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 80000


#import "IOS8BenchmarkViewController.h"
#import <WebKit/WebKit.h>


@interface IOS8BenchmarkViewController ()
@end

@implementation IOS8BenchmarkViewController

- (void)loadView
{
    self.wkWebView = [ WKWebView new ];
    [self setView: self.wkWebView];
        
    [ super loadView ];


    [self.wkWebView.scrollView setContentInset:UIEdgeInsetsMake(44, 0, 0, 0)];
    [self.wkWebView.scrollView setScrollIndicatorInsets:UIEdgeInsetsMake(44, 0, 0, 0)];
    [self.wkWebView.scrollView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];

    
    [ self.wkWebView setNavigationDelegate: self ];
    
}

- (void)webView:(WKWebView *)webView
decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction
decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {

    NSLog(@"ALLOW! %@", [navigationAction.request.URL absoluteString]);

    
    decisionHandler(WKNavigationActionPolicyAllow);
}


@end

#endif
