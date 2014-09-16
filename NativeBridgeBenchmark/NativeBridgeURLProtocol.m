//
//  NativeBridgeURLProtocol.m
//  NativeBridgeBenchmark
//
//  Created by mpa on 14/09/14.
//
//

#import "NativeBridgeURLProtocol.h"

@implementation NativeBridgeURLProtocol


+(BOOL) canInitWithRequest:(NSURLRequest *)request {
    if ([ [[request URL] scheme ] isEqualToString:@"nativebridge" ]) {
        NSLog(@"URLPROTOCOL captured");

        NSLog([[request URL] path]);
        return YES;
    };
    
    
//    if ([[[request URL] host] isEqualToString:@"localhost"]) {
//        return YES;
//    }
//    
    
    return NO;
}

@end
