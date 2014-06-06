//
//  IOS8BenchmarkViewController.h
//  NativeBridgeBenchmark
//
//  Created by Matti Paksula on 06/06/14.
//
//

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "SharedViewController.h"

@interface IOS8BenchmarkViewController : SharedViewController
@property(nonatomic, retain) WKWebView* wkWebView;
@end

#endif