//
//  BenchmarkViewController.m
//  NativeBridgeBenchmark
//
//  Created by mpa on 19/05/14.
//
//

#import "BenchmarkViewController.h"

#import "NativeBridgeURLProtocol.h"
#import "BenchmarkRecorder.h"

BenchmarkViewController* gBenchmarkViewController;


// JScore
@protocol JS_TSViewController <JSExport>
- (void) nativeBridge:(NSString *)msg;
@end


@interface BenchmarkViewController () <TSWebViewDelegate, JS_TSViewController>
@end




@implementation BenchmarkViewController

#pragma mark - WebViewDelegate


-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {

    return (![ NativeBridgeURLProtocol canInitWithRequest:request ]);
}

//-(void)webViewDidStartLoad:(UIWebView *)webView {
//}
//
//-(void)webViewDidFinishLoad:(UIWebView *)webView {
//}

#pragma mark - JSCore



- (void)webView:(UIWebView *)webView didCreateJavaScriptContext:(JSContext *)ctx
{
    ctx[@"sayHello"] = ^{

        dispatch_async( dispatch_get_main_queue(), ^{

            UIAlertView* av = [[UIAlertView alloc] initWithTitle: @"Hello, World!"
                                                         message: nil
                                                        delegate: nil
                                               cancelButtonTitle: @"OK"
                                               otherButtonTitles: nil];

            [av show];
        });
    };

    ctx[@"viewController"] = self;
}


- (void) nativeBridge:(NSString *)msg
{
    dispatch_async(dispatch_get_main_queue(), ^{

        NSURL *url = [NSURL URLWithString:msg];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];

        [gBenchmarkViewController webView:gBenchmarkViewController.webView shouldStartLoadWithRequest:request navigationType:UIWebViewNavigationTypeOther];

    });
}


#pragma mark - ViewController

- (void)loadView
{
    
    [self setWebView:[UIWebView new]];
    [self setView: self.webView ];

    // fix ios7
    [self.webView.scrollView setContentInset:UIEdgeInsetsMake(44, 0, 0, 0)];
    [self.webView.scrollView setScrollIndicatorInsets:UIEdgeInsetsMake(44, 0, 0, 0)];
    [self.webView.scrollView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];

    // change pagination + bounces
    /*
    self.webView.paginationMode = UIWebPaginationModeLeftToRight;
    self.webView.paginationBreakingMode = UIWebPaginationBreakingModePage;
    self.webView.gapBetweenPages = 10;
    */
     
    self.webView.scrollView.bounces = false;

    [ self.webView setDelegate:self];

    // XHR TODO: in iOS8 ?
    gBenchmarkViewController = self;

    //[NSURLProtocol registerClass:PongUrlProtocol.class];

    
    [ super loadView ];

}




@end
