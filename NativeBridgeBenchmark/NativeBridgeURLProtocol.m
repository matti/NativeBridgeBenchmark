//
//  NativeBridgeURLProtocol.m
//  NativeBridgeBenchmark
//
//  Created by mpa on 14/09/14.
//
//

#import "NativeBridgeURLProtocol.h"
#import "BenchmarkRecorder.h"

#import "BenchmarkViewController.h"

#import "LocalStorageObserver.h"


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
        
       LocalStorageObserver *localStorageObserver = [ LocalStorageObserver new ];
       [localStorageObserver observeWithHTTPPort:request.URL.port andHost:request.URL.host];

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
    

//        BenchmarkViewController *bvc = (BenchmarkViewController*)[[[[UIApplication sharedApplication ] delegate] window ] rootViewController];
        
//        NSURL *url = [NSURL URLWithString:msg];
//        NSMutableURLRequest *betterRequest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
        
        // TODO: check if faster?
        //    [self.client URLProtocol:self didFailWithError:[NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorZeroByteResource userInfo:nil]];

           //        [bvc webView: bvc.webView shouldStartLoadWithRequest:request navigationType:UIWebViewNavigationTypeOther];
        
        
    
    
//    if ([[[request URL] host] isEqualToString:@"localhost"]) {
//        return YES;
//    }
//

}

+ (NSURLRequest*) canonicalRequestForRequest:(NSURLRequest*)request {
    //    NSMutableURLRequest *copy = [[request mutableCopy] autorelease];
    //    copy.URL = [NSURL URLWithString:[[[request URL] absoluteString] stringByReplacingOccurrencesOfString:@"http" withString:[NSString stringWithFormat:@"http+%f", [[NSDate date] timeIntervalSince1970]]]];
    return request;
}

-(void) startLoading {

    
    NSString *requestPath = [[[self request] URL] path];
    NSString *requestMethod = [[self request] HTTPMethod];

    NSData *body = [@"{}" dataUsingEncoding:NSUTF8StringEncoding];
    
    NSHTTPURLResponse *response = [NSHTTPURLResponse alloc];

    
    [response initWithURL:[[self request] URL]
                statusCode:200
               HTTPVersion:@"HTTP/1.1"
              headerFields: @{
                              @"Connection": @"keep-alive",
                              @"Cache-Control": @"public, max-age=0",
                              @"Content-Type": @"application/javascript",
                              @"Access-Control-Allow-Origin": @"*"
                              }];
    
    [self respondWithResponse:response Body:body];
}

-(void) stopLoading {
    
}

-(void) respondWithResponse:(NSHTTPURLResponse*)response Body:(NSData*)body {
    [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    
    [[self client] URLProtocol:self didLoadData:body];
    
    [[self client] URLProtocolDidFinishLoading:self];
}



@end
