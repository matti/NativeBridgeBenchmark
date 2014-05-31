//
//  BenchmarkViewController.h
//  NativeBridgeBenchmark
//
//  Created by mpa on 19/05/14.
//
//

#import <UIKit/UIKit.h>
#import "UIWebView+TS_JavaScriptContext.h"
#import <CocoaHTTPServer/HTTPServer.h>

@interface BenchmarkViewController : UIViewController <TSWebViewDelegate>
@property (nonatomic, retain) UIWebView* webView;
@property(nonatomic, retain) HTTPServer* httpServer;

@end
