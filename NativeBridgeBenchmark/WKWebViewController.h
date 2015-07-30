//
//  IOS8BenchmarkViewController.h
//  NativeBridgeBenchmark
//
//  Created by Matti Paksula on 06/06/14.
//
//

#import <UIKit/UIKit.h>
#import "SharedViewController.h"

@interface WKWebViewController : SharedViewController<WKNavigationDelegate, WKScriptMessageHandler, WKUIDelegate>
@property(nonatomic, retain) WKWebView* wkWebView;
@end
