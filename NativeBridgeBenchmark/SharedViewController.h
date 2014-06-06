//
//  SharedViewController.h
//  NativeBridgeBenchmark
//
//  Created by Matti Paksula on 06/06/14.
//
//

#import <UIKit/UIKit.h>

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
#import <WebKit/WebKit.h>
#endif

#import "Memusage.h"
#import "Cpuusage.h"

#import <CocoaHTTPServer/HTTPServer.h>
#import "MyHTTPConnection.h"

#import <FMDB/FMDB.h>


@interface SharedViewController : UIViewController

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
@property(nonatomic, retain) WKWebView* wkWebView;
#else
@property(nonatomic, retain) UIWebView* wkWebView;
#endif

@property(nonatomic, retain) UIWebView* webView;

@property(nonatomic, retain) HTTPServer* httpServer;
@property(nonatomic, retain) FMDatabase* localStorageDB;

@property(nonatomic, retain) MemUsage* memUsage;
@property(nonatomic, retain) CpuUsage* cpuUsage;

-(void) reload;
-(void) restart;
-(void) addNavigationBar;
-(void) startHTTPServer;
-(void) addCookieObserver;

@end
