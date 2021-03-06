//
//  NativeBridgeURLProtocol.h
//  NativeBridgeBenchmark
//
//  Created by mpa on 14/09/14.
//
//

#import <Foundation/Foundation.h>

@interface NativeBridgeURLProtocol : NSURLProtocol

+(BOOL) isNativeBridgeURLProtocol: (NSURLRequest *) request;

+(NSURLRequest*) parseRequestFromNativeBridgeURLProtocolPongWith: (NSString *)messageURLString;

+(NSString*)extractNativeBridgeMessageWith: (NSURLRequest *) request;

+(BOOL) canInitWith: (NSString*) messageURLString;

@end
