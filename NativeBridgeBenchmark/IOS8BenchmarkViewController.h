//
//  IOS8BenchmarkViewController.h
//  NativeBridgeBenchmark
//
//  Created by Matti Paksula on 06/06/14.
//
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "SharedViewController.h"

@interface IOS8BenchmarkViewController : SharedViewController<WKNavigationDelegate>
@property(nonatomic, retain) WKWebView* wkWebView;
@end
