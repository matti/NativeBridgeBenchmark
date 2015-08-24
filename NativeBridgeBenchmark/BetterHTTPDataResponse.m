//
//  BetterHTTPDataResponse.m
//  NativeBridgeBenchmark
//
//  Created by mpa on 24/08/15.
//
//

#import "BetterHTTPDataResponse.h"

@implementation BetterHTTPDataResponse

-(id)initWithData:(NSData *)givenData andHeaders:(NSDictionary *)givenHeaders {
    self = [ self initWithData:givenData ];
    _headers = givenHeaders;
    
    return self;
}

-(NSDictionary *)httpHeaders {
    return _headers;
}

@end
