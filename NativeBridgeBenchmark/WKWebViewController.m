//
//  IOS8BenchmarkViewController.m
//  NativeBridgeBenchmark
//
//  Created by Matti Paksula on 06/06/14.
//
//



#import "WKWebViewController.h"

#import "BenchmarkRecorder.h"
#import "NativeBridgeURLProtocol.h"

#import "BridgeHead.h"

@interface WKWebViewController ()
@end

@implementation WKWebViewController

- (void)loadView
{
    WKWebViewConfiguration *wkConfiguration = [WKWebViewConfiguration new];
    [wkConfiguration.userContentController addScriptMessageHandler:self name:@"nativeBridge"];

    // TODO: wat, pitäiskö oll addSubView paradigmalla sittenki...? vähän epäilyttää cgrectzero
    self.wkWebView = [[ WKWebView alloc] initWithFrame:CGRectZero configuration:wkConfiguration];

    
    [self setView: self.wkWebView];

    [ super loadView ];


    [self.wkWebView.scrollView setContentInset:UIEdgeInsetsMake(44, 0, 0, 0)];
    [self.wkWebView.scrollView setScrollIndicatorInsets:UIEdgeInsetsMake(44, 0, 0, 0)];
    [self.wkWebView.scrollView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];

    
    [ self.wkWebView setNavigationDelegate: self ];
    [ self.wkWebView setUIDelegate: self ]; // alert, prompt, confirm
    [ self.wkWebView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL]; // title
    
    [ self.wkWebView setContentScaleFactor:2.0];
    
}


-(void) viewDidLoad {

}

-(void)reload
{
    [super reload];
    [self.wkWebView reload];
}

-(void)restart {
    [super restart];
    [self.wkWebView loadRequest: self.startingRequest];
}


# pragma mark - WKScriptMessageHandler

-(void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    NSString *msg = (NSString*) message.body;
    
    [ NativeBridgeURLProtocol canInitWith: msg ];
}

# pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView
decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction
decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {


    if ([NativeBridgeURLProtocol isNativeBridgeURLProtocol: navigationAction.request ]) {
        // huge debug outputs
        //NSLog(@"cancel this %@", [navigationAction.request.URL absoluteString]);
        
        [NativeBridgeURLProtocol canInitWithRequest: navigationAction.request ];

        decisionHandler(WKNavigationActionPolicyCancel);
    } else {
        NSLog(@"allow nav");

        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

-(void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)())completionHandler {

    
    if ( [NativeBridgeURLProtocol canInitWith:message] ) {
        completionHandler();
// TODO: can init already performs..
//        BridgeHead *bridgeHead = [BridgeHead new];
//        [bridgeHead perform:message];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc ] initWithTitle:@"Alert" message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
        
        [alertView show];
        [alertView dismissWithClickedButtonIndex:0 animated:YES];
        
        
        completionHandler();
    }


}

-(void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler {

    if ( [NativeBridgeURLProtocol canInitWith:message] ) {
        completionHandler(false);
// TODO: can init already performs..
        //        BridgeHead *bridgeHead = [BridgeHead new];
//        [bridgeHead perform:message];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc ] initWithTitle:@"Confirm autoyes" message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
        
        [alertView show];
        [alertView dismissWithClickedButtonIndex:0 animated:YES];
        
        completionHandler(true);
    }
    
}


-(void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)message defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString *))completionHandler {

    if ( [NativeBridgeURLProtocol canInitWith:message] ) {
        completionHandler(nil);
//        BridgeHead *bridgeHead = [BridgeHead new];
//        [bridgeHead perform:message];
    } else if ( [ message containsString:@"lel" ] ) {
        completionHandler(@"lul");
    } else {
        UIAlertView *alertView = [[UIAlertView alloc ] initWithTitle:@"Textinput" message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
        
        [alertView show];
        [alertView dismissWithClickedButtonIndex:0 animated:YES];
        
        completionHandler(nil);
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {

    if (object == self.wkWebView && [keyPath isEqualToString:@"title"]) {

        NSString *message = change[NSKeyValueChangeNewKey];
        
        if ( [NativeBridgeURLProtocol canInitWith:message] ) {
            //BridgeHead *bridgeHead = [BridgeHead new];
            //[bridgeHead perform:message];
        } else {
            // wuz not message
        }
    }
}


@end

