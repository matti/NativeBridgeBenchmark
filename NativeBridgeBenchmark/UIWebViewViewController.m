//
//  BenchmarkViewController.m
//  NativeBridgeBenchmark
//
//  Created by mpa on 19/05/14.
//
//

#import "UIWebViewViewController.h"

#import "NativeBridgeURLProtocol.h"

#import "BridgeHead.h"

#import "UIWebView+Prompt.h"
#import "NativeEvent.h"
#import <RequestUtils/RequestUtils.h>

// JScore
@protocol JS_TSViewController <JSExport>
- (void) nativeBridge:(NSString *)msg;
- (NSString*) nativeBridgePong:(NSString *)msg;
@end


@interface UIWebViewViewController () <TSWebViewDelegate, JS_TSViewController>
@end


@implementation UIWebViewViewController

#pragma mark - WebViewDelegate


-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    if ([ NativeBridgeURLProtocol isNativeBridgeURLProtocol:request ]) {
        // TODO: wat, suddenly urlprotocol doesn't capture the old requests? based on assembly it goes to internal policydecide ala wkWebView?
        NSString* messageURLString = [NativeBridgeURLProtocol extractNativeBridgeMessageWith:request];
        
        BridgeHead *bridgeHead = [BridgeHead new];
        [bridgeHead perform: messageURLString];
        
        return NO;
    } else {
        return YES;
    }
}

-(void)restart {
    [super restart ];
    [self.webView loadRequest: self.startingRequest ];
}

-(void)reload
{
    [super reload];
    [self.webView stringByEvaluatingJavaScriptFromString:@"window.location.reload();" ];
}


#pragma mark - JSCore

- (void)webView:(UIWebView *)webView didCreateJavaScriptContext:(JSContext *)ctx
{
    ctx[@"viewController"] = self;
    
    self.jsContext = ctx;
}


-(NSString*) nativeBridgePong:(NSString *)msg {
    
    NSURLRequest *request = [NativeBridgeURLProtocol parseRequestFromNativeBridgeURLProtocolPongWith:msg];
    
    NSDictionary *params = [ request GETParameters ];
    
    NativeEvent *nativeEvent = [[ NativeEvent alloc ] initWithPayload:@"" andMethod:[params valueForKey:@"method_name"] andWebviewStartedAt:[params valueForKey:@"webview_started_at"]];
    
    return [nativeEvent asJSON];
}

- (void) nativeBridge:(NSString *)msg
{
    
    dispatch_async(dispatch_get_main_queue(), ^{

        NSURL *url = [NSURL URLWithString:msg];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];

        UIWebViewViewController *bvc = (UIWebViewViewController*)[[[[UIApplication sharedApplication ] delegate] window ] rootViewController];
        
        [bvc webView:bvc.webView shouldStartLoadWithRequest:request navigationType:UIWebViewNavigationTypeOther];

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
    
    self.webView.scrollView.bounces = false;

    [ self.webView setDelegate:self];

    
    [ super loadView ];

}




@end
