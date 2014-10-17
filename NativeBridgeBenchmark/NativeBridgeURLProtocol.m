//
//  NativeBridgeURLProtocol.m
//  NativeBridgeBenchmark
//
//  Created by mpa on 14/09/14.
//
//

#import "NativeBridgeURLProtocol.h"
#import "BenchmarkRecorder.h"

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

+(BOOL) canInitWithRequest:(NSURLRequest *)request {
    
    if ( [request.URL.fragment isEqualToString:@"nativebridgebootstrapcomplete"] ) {
        
        // Doesn't work well in iOS8 uiwebview, only has the first char as value..
        
        //NSString *basePath = [@"~/Library/WebKit/fi.helsinki.cs.paksula.NativeBridgeBenchmark/WebsiteData/LocalStorage" stringByExpandingTildeInPath];

//        LocalStorageObserver *localStorageObserver = [ LocalStorageObserver new ];
//        [localStorageObserver observeWithHTTPPort:request.URL.port andHost:request.URL.host andBasePath:basePath];
        
        return YES;
    }
    
    NSString* messageURLString = [self extractNativeBridgeMessageWith:request];
    
    if ( messageURLString ) {
        NSLog(@"URLPROTOCOL captured");
        
        BenchmarkRecorder *recorder = [ BenchmarkRecorder new ];
        [ recorder recordMessage:messageURLString ];
        
        return YES;
    } else {
        return NO;
    }
    
}

+ (NSURLRequest*) canonicalRequestForRequest:(NSURLRequest*)request {
    return request;
}

-(void) startLoading {

    NSData *body = [@"{}" dataUsingEncoding:NSUTF8StringEncoding];
    
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
    
}

-(void) respondWithResponse:(NSHTTPURLResponse*)response Body:(NSData*)body {
}



@end
