//
//  Sender.m
//  NativeBridgeBenchmark
//
//  Created by mpa on 02/11/14.
//
//

#import "Sender.h"
#import "NativeEvent.h"

#import "UIWebViewViewController.h"
#import "WKWebViewController.h"

#import "BridgeHead.h"


@implementation Sender {
    NSTimer *timer;
    
    double interval;
    NSInteger messages;
    NSString *payload;
    NSString *method;
    
    UIWebViewViewController *currentUIWebViewController;
    WKWebViewController *currentWKWebViewController;
    
    MyWebSocket *webSocket;
}

static Sender *instance;

+(Sender*) instance {
    if ( instance == nil )
        instance = [[ Sender alloc ] init];
    
    return instance;
}

-(NSString*) randomStringWithLength: (NSInteger) len {
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform([letters length])]];
    }
    
    return randomString;
}

-(void)showAlert: (NSString*) message {
    UIAlertView *alertView = [[UIAlertView alloc ] initWithTitle:@"Hai" message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
    
    [alertView show];
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
}

-(NSDictionary*) parseConfigurationMessage:(NSString *)configurationMessage {

    NSData *json = [configurationMessage dataUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary *configuration = [NSJSONSerialization JSONObjectWithData:json options:kNilOptions error:nil];
    
    return configuration;
    
}

-(void) send:(NSString *)configurationMessage withWebSocket:(MyWebSocket *)ws {
    
    SharedViewController *currentRootVC = (SharedViewController*)[[[[UIApplication sharedApplication ] delegate] window ] rootViewController];
    currentWKWebViewController = nil;
    currentUIWebViewController = nil;
    
    if (currentRootVC.webView) {
        NSLog(@"sender: uiwebview");
        currentUIWebViewController = (UIWebViewViewController*)currentRootVC;
    } else {
        NSLog(@"sender: wkwebview");
        currentWKWebViewController = (WKWebViewController*)currentRootVC;
    }
    
    webSocket = ws;

    
    NSDictionary *configuration = [ self parseConfigurationMessage:configurationMessage];
    
    
    interval = [[configuration valueForKey:@"interval" ] integerValue];
    messages = [[configuration valueForKey:@"messages" ] integerValue];
    method = [configuration valueForKey:@"method" ];
    
    [ self performSelectorOnMainThread:@selector(showAlert:) withObject:@"generating payload" waitUntilDone:YES ];
    
    NSInteger payloadLength = [[configuration valueForKey:@"payloadLength" ] integerValue];
    payload = [ self randomStringWithLength: (payloadLength * 1024) ];

    [ self performSelectorOnMainThread:@selector(showAlert:) withObject:@"Starting" waitUntilDone:YES ];
    
    timer = [ NSTimer scheduledTimerWithTimeInterval:interval/1000
                                              target:self
                                            selector:@selector(sender)
                                            userInfo:nil
                                             repeats:YES ];
    
    // lol-fix to prevent bad fps due alert shown
    
    sleep(3);
    
    NSString *evalStringResetRenderLoop = @"window.renderloopHighest = 0;";
    
    if (currentUIWebViewController) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [currentUIWebViewController.jsContext evaluateScript:evalStringResetRenderLoop];
        });
    } else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [currentWKWebViewController.wkWebView evaluateJavaScript:evalStringResetRenderLoop completionHandler:nil];
        });
    }
    
    sleep(1);
    
    
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    
    // pump the run loop until someone tells us to stop
    while(messages > 0)
    {
        // allow the run loop to run for, arbitrarily, 2 seconds
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:2.0]];
        
    }
    
    NSLog(@"done sending, stopping loop pump and sleeping 2 seconds before requesting a flush");
    
    sleep(2);
    
    NSString *evalStringFlush = @"document.querySelector('button#flush').click();";
    
    if (currentUIWebViewController) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [currentUIWebViewController.jsContext evaluateScript:evalStringFlush];
        });
    } else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [currentWKWebViewController.wkWebView evaluateJavaScript:evalStringFlush completionHandler:nil];
        });
    }
    
    NSLog(@"flush requested from webview");
}


-(void) sender {
    if (messages == 0) {
        [timer invalidate];
        
        NSDictionary *response = @{
                                   @"type": @"native_end"
                                   };
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject: response
                                                           options: 0
                                                             error: nil];
        [webSocket sendData: jsonData ];
        
        return;
    }
    
    NativeEvent *nativeEvent = [[ NativeEvent alloc ] initWithPayload:payload andMethod:method];
    
    if ( currentUIWebViewController ) {
        if ( [method isEqualToString: @"http.websockets"] ) {
            
            [webSocket sendData: [ nativeEvent asData ]];
            
        } else if ( [ method isEqualToString: @"jscore.sync" ]) {
      
            NSString *evalString = [ NSString stringWithFormat:@"bridgeHead('%@');", [nativeEvent asJSON]];
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                [currentUIWebViewController.jsContext evaluateScript:evalString];
            });
            
        } else if ( [ method isEqualToString:@"webview.eval" ]) {
            
            NSString *evalString = [ NSString stringWithFormat:@"bridgeHead('%@');", [nativeEvent asJSON] ];
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                
                [currentUIWebViewController.webView stringByEvaluatingJavaScriptFromString:evalString];
                
            });
            
        } else if ( [ method isEqualToString:@"webview.evalpong" ]) {
            
            // TODO: maybe someday
            
        } else if ( [ method isEqualToString: @"location.hash"]) {
            
            NSURLComponents *urlComponents = [ NSURLComponents componentsWithString: [currentUIWebViewController.webView.request.URL absoluteString ]];
            
            urlComponents.fragment = [ NSString stringWithFormat:@"#webviewbridge:%@", [nativeEvent asJSON]];
            
            NSURL *newURL = [urlComponents URL];
            NSURLRequest *newRequest = [[ NSURLRequest alloc ] initWithURL: newURL ];
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                [currentUIWebViewController.webView loadRequest:newRequest];
            });
            
        }
    } else if (currentWKWebViewController) {

        if ( [method isEqualToString: @"http.websockets"] ) {
            
            [webSocket sendData: [nativeEvent asData] ];
            
        } else if ( [ method isEqualToString:@"webview.eval" ]) {
            
            NSString *evalString = [ NSString stringWithFormat:@"bridgeHead('%@');", [nativeEvent asJSON] ];
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                [currentWKWebViewController.wkWebView evaluateJavaScript:evalString completionHandler:nil];
            });
            
        } else if ( [ method isEqualToString: @"location.hash"]) {
            
            NSURLComponents *urlComponents = [ NSURLComponents componentsWithString: [currentWKWebViewController.wkWebView.URL absoluteString ]];
            
            urlComponents.fragment = [ NSString stringWithFormat:@"#webviewbridge:%@", [nativeEvent asJSON]];
            
            NSURL *newURL = [urlComponents URL];
            NSURLRequest *newRequest = [[ NSURLRequest alloc ] initWithURL: newURL ];
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                [currentWKWebViewController.wkWebView loadRequest:newRequest];
            });
            
        }

    } else {
        NSAssert(false, @"no webview active, wat");
    }
    
    messages--;
    
    NSLog(@"sent, %d remaining", messages);
}


@end
