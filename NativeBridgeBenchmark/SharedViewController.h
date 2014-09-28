//
//  SharedViewController.h
//  NativeBridgeBenchmark
//
//  Created by Matti Paksula on 06/06/14.
//
//

#import <UIKit/UIKit.h>

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 80000
#import <WebKit/WebKit.h>
#endif

#import <FMDB/FMDB.h>

#import <CocoaHTTPServer/HTTPServer.h>
#import "MyHTTPConnection.h"



@interface SharedViewController : UIViewController

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 80000
@property(nonatomic, retain) WKWebView* wkWebView;
#else
@property(nonatomic, retain) UIWebView* wkWebView;
#endif

@property(nonatomic, retain) UIWebView* webView;

@property(nonatomic, retain) FMDatabase* localStorageDB;


-(BOOL) handleRequest: (NSURLRequest*) request;

-(void) reload;
-(void) restart;
-(void) addNavigationBar;
-(void) addCookieObserver;

@end
