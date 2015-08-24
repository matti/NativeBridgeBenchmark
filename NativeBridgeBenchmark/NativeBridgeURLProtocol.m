//
//  NativeBridgeURLProtocol.m
//  NativeBridgeBenchmark
//
//  Created by mpa on 14/09/14.
//
//

#import "NativeBridgeURLProtocol.h"
#import "BridgeHead.h"
#import "NativeEvent.h"
#import <RequestUtils/RequestUtils.h>

@implementation NativeBridgeURLProtocol

+(NSString*) extractNativeBridgeMessageWith:(NSURLRequest *)request {

    NSString *messageURLString = nil;
    
    if ( [request.URL.absoluteString hasPrefix:@"nativebridge://"] ) {
        messageURLString = request.URL.absoluteString;
    }
    
    if ( [request.URL.fragment hasPrefix:@"nativebridge://"] ) {
        messageURLString = request.URL.fragment;
    }
    
    // TODO: which one is this?? http fallback? check if still needed.
    if ( [request.URL.host isEqualToString:@"nativebridge"] ) {
        messageURLString = [ NSString stringWithFormat:@"nativebridge:%@?%@", request.URL.path, request.URL.query];
    }
    
    return messageURLString;
}

+(BOOL) isNativeBridgeURLProtocol:(NSURLRequest *)request {
    
    NSString* messageURL = [ self extractNativeBridgeMessageWith:request ];

    return ( messageURL || [request.URL.host isEqualToString:@"nativebridgebootstrapcomplete"] );

}

+(BOOL) canInitWith:(NSString *)messageURLString {
    NSURL *url = [NSURL URLWithString:messageURLString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    return [ self canInitWithRequest:request];
}

+(BOOL) canInitWithRequest:(NSURLRequest *)request {

    if ( [request.URL.fragment isEqualToString:@"nativebridgebootstrapcomplete"] ) {
        
        // Doesn't work well in iOS8 uiwebview, only has the first char as value..
        
        //NSString *basePath = [@"~/Library/WebKit/fi.helsinki.cs.paksula.NativeBridgeBenchmark/WebsiteData/LocalStorage" stringByExpandingTildeInPath];

//        LocalStorageObserver *localStorageObserver = [ LocalStorageObserver new ];
//        [localStorageObserver observeWithHTTPPort:request.URL.port andHost:request.URL.host andBasePath:basePath];
        
        return NO;
    }
    
    NSString* messageURLString = [self extractNativeBridgeMessageWith:request];
    
    if ( messageURLString ) {
        BridgeHead *bridgeHead = [BridgeHead new];
        [bridgeHead perform:messageURLString];
                
        return YES;
    } else {
        return NO;
    }
    
}


+(NSURLRequest*) parseRequestFromNativeBridgeURLProtocolPongWith:(NSString *)messageURLString {
    if ( [messageURLString containsString:@".pongweb"] ) {
        NSURL *url = [NSURL URLWithString:messageURLString];
        return [NSURLRequest requestWithURL:url];
    }

    return nil;
}


+ (NSURLRequest*) canonicalRequestForRequest:(NSURLRequest*)request {
    return request;
}

-(void) startLoading {
    
    NSData *body;
    NSDictionary *params = [[ self request ] GETParameters];
    
    // xhr.pongWeb
    if ( [[ params valueForKey:@"method_name" ] isEqualToString: @"xhr.pongweb"] ) {
        NativeEvent *nativeEvent = [[NativeEvent alloc] initWithPayload:@"" andMethod:[params valueForKey:@"method_name" ] andWebviewStartedAt: [params valueForKey:@"webview_started_at"]];
        
        body = [nativeEvent asData];
        
    } else {
        body = [@"{}" dataUsingEncoding:NSUTF8StringEncoding];
    }
    
    NSHTTPURLResponse *lolsponse = [NSHTTPURLResponse alloc];
    
    NSHTTPURLResponse *response = [lolsponse initWithURL:[[self request] URL]
                statusCode:200
               HTTPVersion:@"HTTP/1.1"
              headerFields: @{
                              @"Connection": @"keep-alive",
                              @"Cache-Control": @"public, max-age=0",
                              @"Content-Type": @"application/javascript",
                              @"Access-Control-Allow-Origin": @"*"
                              }];
    
    [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    [[self client] URLProtocol:self didLoadData:body];
    [[self client] URLProtocolDidFinishLoading:self];
}

-(void) stopLoading {
    // from abstract
}

@end
