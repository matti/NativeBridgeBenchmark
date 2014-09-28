//
//  NativeBridgeURLProtocol.m
//  NativeBridgeBenchmark
//
//  Created by mpa on 14/09/14.
//
//

#import "NativeBridgeURLProtocol.h"
#import "BenchmarkViewController.h"

#import <MobileCoreServices/MobileCoreServices.h>

@implementation NativeBridgeURLProtocol


+(BOOL) canInitWithRequest:(NSURLRequest *)request {

    if ([ [[request URL] host ] isEqualToString:@"nativebridge" ]) {

        NSLog(@"URLPROTOCOL captured");

        BenchmarkViewController *bvc = (BenchmarkViewController*)[[[[UIApplication sharedApplication ] delegate] window ] rootViewController];
        
//        NSURL *url = [NSURL URLWithString:msg];
//        NSMutableURLRequest *betterRequest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
        
        [bvc webView: bvc.webView shouldStartLoadWithRequest:request navigationType:UIWebViewNavigationTypeOther];
        
        return YES;
    };
    
    
//    if ([[[request URL] host] isEqualToString:@"localhost"]) {
//        return YES;
//    }
//
    

    // Do not capture, fall back to webview default behaviour
    return NO;
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
