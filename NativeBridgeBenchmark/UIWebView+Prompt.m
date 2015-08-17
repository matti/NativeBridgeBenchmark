//
//  UIWebView+Prompt.m
//  NativeBridgeBenchmark
//
//  Created by mpa on 15/08/15.
//
//

#import "UIWebView+Prompt.h"

#import "NativeBridgeURLProtocol.h"
#import <RequestUtils/RequestUtils.h>
#import "NativeEvent.h"

@implementation UIWebView (Prompt)

-(NSString *)webView:(UIWebView *)sender runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(__autoreleasing id *)frame {
    
    NSURLRequest* request = nil;
    
    if ( (request = [NativeBridgeURLProtocol parseRequestFromNativeBridgeURLProtocolPongWith:prompt]) ) {
        NSDictionary *params = [ request GETParameters ];
        
        NativeEvent *nativeEvent = [[NativeEvent alloc] initWithPayload:@"" andMethod:[params valueForKey:@"method_name"] andWebviewStartedAt:[params valueForKey:@"webview_started_at"]];
        
        return [nativeEvent asJSON];
                                
        
    } else if ([NativeBridgeURLProtocol canInitWith:prompt]) {
        return nil;
    }
    
    return @"prompt has been overridden, sorry";
}

-(BOOL)webView:(UIWebView *)sender runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(__autoreleasing id *)frame {

    if ([NativeBridgeURLProtocol canInitWith:message]) {
        return nil;
    } else {
        NSLog(@"window.confirm has been overridden, message:");
        NSLog(message);
    }

    
    return YES;
}

-(void)webView:(UIWebView *)sender runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(__autoreleasing id *)frame {
    
    if ([NativeBridgeURLProtocol canInitWith:message]) {
    } else {
        NSLog(@"window.alert has been overridden, message:");
        NSLog(message);
    }
    
    return;
}


@end
