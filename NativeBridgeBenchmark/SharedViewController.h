//
//  SharedViewController.h
//  NativeBridgeBenchmark
//
//  Created by Matti Paksula on 06/06/14.
//
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

#import <CocoaHTTPServer/HTTPServer.h>
#import "MyHTTPConnection.h"



@interface SharedViewController : UIViewController

@property(nonatomic, retain) WKWebView* wkWebView;
@property(nonatomic, retain) UIWebView* webView;

-(void) reload;
-(void) restart;
-(void) changeWebView;

-(void) addNavigationBar;
@end
