//
//  Sender.m
//  NativeBridgeBenchmark
//
//  Created by mpa on 02/11/14.
//
//

#import "Sender.h"

#import "GreatDate.h"
#import "CpuUsage.h"
#import "MemUsage.h"

#import "UIWebViewViewController.h"

@implementation Sender {
    NSTimer *timer;
    
    double interval;
    NSInteger messages;
    NSString *payload;
    NSString *method;
    
    UIWebViewViewController *currentUIWebViewController;
    
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

-(void) send:(NSString *)configurationMessage withWebSocket:(MyWebSocket *)ws {

    currentUIWebViewController = (UIWebViewViewController*)[[[[UIApplication sharedApplication ] delegate] window ] rootViewController];

    
    webSocket = ws;
    
    NSData *json = [configurationMessage dataUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary *configuration = [NSJSONSerialization JSONObjectWithData:json options:kNilOptions error:nil];
    
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
    
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    
    // pump the run loop until someone tells us to stop
    while(messages > 0)
    {
        // allow the run loop to run for, arbitrarily, 2 seconds
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:2.0]];
        
    }


    
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
    
    NSDictionary *response = @{
                               @"payload": payload,
                               @"native_started_at": [[GreatDate new] format: [ NSDate new ]],
                               @"method": method,
                               @"cpu": [[ CpuUsage new ] cpuUsageString],
                               @"mem": [[ MemUsage new ] memUsageString]
                               };
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject: response
                                                       options: 0
                                                         error: nil];
    
    if ( [method isEqualToString: @"http.websockets"] ) {
        
        [webSocket sendData: jsonData ];
        
    } else if ( [ method isEqualToString: @"jscore.sync" ]) {
        
        NSString *jsonString = [[ NSString alloc ] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSString *evalString = [ NSString stringWithFormat:@"bridgeHead('%@');", jsonString ];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            [currentUIWebViewController.jsContext evaluateScript:evalString];
        });
        
    } else if ( [ method isEqualToString:@"webview.eval" ]) {
        
        NSString *jsonString = [[ NSString alloc ] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSString *evalString = [ NSString stringWithFormat:@"bridgeHead('%@');", jsonString ];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            [currentUIWebViewController.webView stringByEvaluatingJavaScriptFromString:evalString];
            
        });
        
        
    } else if ( [ method isEqualToString: @"location.hash"]) {
        
        NSURLComponents *urlComponents = [ NSURLComponents componentsWithString: [currentUIWebViewController.webView.request.URL absoluteString ]];
        
        NSString *jsonString = [[ NSString alloc ] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        urlComponents.fragment = [ NSString stringWithFormat:@"#webviewbridge:%@", jsonString];
        
        NSURL *newURL = [urlComponents URL];
        NSURLRequest *newRequest = [[ NSURLRequest alloc ] initWithURL: newURL ];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            [currentUIWebViewController.webView loadRequest:newRequest];
        });
        
    }
    
    messages--;

    NSLog(@"sent");
}


@end
