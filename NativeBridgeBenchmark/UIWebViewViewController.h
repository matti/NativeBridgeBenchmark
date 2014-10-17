//
//  BenchmarkViewController.h
//  NativeBridgeBenchmark
//
//  Created by mpa on 19/05/14.
//
//

#import <UIKit/UIKit.h>
#import "SharedViewController.h"

#import "UIWebView+TS_JavaScriptContext.h"

@interface UIWebViewViewController :  SharedViewController <TSWebViewDelegate>


@end
