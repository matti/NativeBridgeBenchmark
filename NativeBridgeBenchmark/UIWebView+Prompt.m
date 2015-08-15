//
//  UIWebView+Prompt.m
//  NativeBridgeBenchmark
//
//  Created by mpa on 15/08/15.
//
//

#import "UIWebView+Prompt.h"

#import "NativeBridgeURLProtocol.h"


@implementation UIWebView (Prompt)

-(NSString *)webView:(UIWebView *)sender runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(__autoreleasing id *)frame {
    
    if ([NativeBridgeURLProtocol canInitWith:prompt]) {
        // TODO: sync bridge
        return nil;
    } else {
        return @"prompt has been overridden, sorry";
    }
    
}

@end
