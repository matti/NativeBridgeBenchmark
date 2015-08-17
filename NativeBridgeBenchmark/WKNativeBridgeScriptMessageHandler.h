//
//  wkNativeBridgeUserContentController.h
//  NativeBridgeBenchmark
//
//  Created by mpa on 17/08/15.
//
//

#import <Foundation/Foundation.h>
@import WebKit;


//@interface WKWebViewController : SharedViewController<WKNavigationDelegate, WKScriptMessageHandler, WKUIDelegate>

@interface WKNativeBridgeScriptMessageHandler : UIViewController<WKScriptMessageHandler>

@end
