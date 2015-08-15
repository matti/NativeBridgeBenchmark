//
//  UIWebView+Prompt.h
//  NativeBridgeBenchmark
//
//  Created by mpa on 15/08/15.
//
//

#import <Foundation/Foundation.h>

@interface UIWebView (Prompt)

- (NSString *)webView:(UIWebView *)sender
runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt
          defaultText:(NSString *)defaultText
     initiatedByFrame:(id *)frame;

@end
