//
//  WebViewURLProtocol.m
//  NativeBridgeBenchmark
//
//  Created by mpa on 05/11/14.
//
//

#import "WebViewURLProtocol.h"

@implementation WebViewURLProtocol

+(BOOL)canInitWithRequest:(NSURLRequest *)request {
    
    return ( [request.URL.absoluteString containsString:@"results#%23webviewbridge:"] );
}

+ (NSURLRequest*) canonicalRequestForRequest:(NSURLRequest*)request {
    return request;
}


-(void) startLoading {
    // every other blocking leaks..
    
    id<NSURLProtocolClient> client = [self client];
    NSError* error = [NSError errorWithDomain:NSURLErrorDomain
                                         code:kCFURLErrorNotConnectedToInternet // = -1009 = error code when network is down
                                     userInfo:@{ NSLocalizedDescriptionKey:@"All network requests are blocked by the application"}];
    [client URLProtocol:self didFailWithError:error];
}

-(void) stopLoading {

}

@end
