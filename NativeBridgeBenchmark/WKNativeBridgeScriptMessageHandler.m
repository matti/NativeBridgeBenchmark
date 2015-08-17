//
//  wkNativeBridgeUserContentController.m
//  NativeBridgeBenchmark
//
//  Created by mpa on 17/08/15.
//
//

#import "WKNativeBridgeScriptMessageHandler.h"
#import "NativeBridgeURLProtocol.h"

@implementation WKNativeBridgeScriptMessageHandler

-(void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    
    NSString *msg = (NSString*) message.body;
    
    [ NativeBridgeURLProtocol canInitWith: msg ];
}


@end
