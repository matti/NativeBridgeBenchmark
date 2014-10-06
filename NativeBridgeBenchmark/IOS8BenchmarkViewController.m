//
//  IOS8BenchmarkViewController.m
//  NativeBridgeBenchmark
//
//  Created by Matti Paksula on 06/06/14.
//
//



#import "IOS8BenchmarkViewController.h"
#import <WebKit/WebKit.h>

#import "BenchmarkRecorder.h"
#import "NativeBridgeURLProtocol.h"

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
    
    [ self.wkWebView setContentScaleFactor:2.0];
    
}


- (void)webView:(WKWebView *)webView
decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction
decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {


    if ([NativeBridgeURLProtocol isNativeBridgeURLProtocol: navigationAction.request ]) {
        NSLog(@"cancel this %@", [navigationAction.request.URL absoluteString]);

        [NativeBridgeURLProtocol canInitWithRequest: navigationAction.request ];

        decisionHandler(WKNavigationActionPolicyCancel);
    } else {
        NSLog(@"allow this %@", [navigationAction.request.URL absoluteString]);

        decisionHandler(WKNavigationActionPolicyAllow);
    }
}


@end

