//
//  WebViewURLProtocol.h
//  NativeBridgeBenchmark
//
//  Created by mpa on 05/11/14.
//
//

#import <Foundation/Foundation.h>

@interface WebViewURLProtocol : NSURLProtocol <NSURLConnectionDelegate>

@property(nonatomic, strong) NSURLConnection *connection;

@end
