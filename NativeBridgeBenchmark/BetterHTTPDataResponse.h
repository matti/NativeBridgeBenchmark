//
//  BetterHTTPDataResponse.h
//  NativeBridgeBenchmark
//
//  Created by mpa on 24/08/15.
//
//

#import <Foundation/Foundation.h>
#import "HTTPDataResponse.h"
#import "HTTPConnection.h"

@interface BetterHTTPDataResponse : HTTPDataResponse

-(id)initWithData:(NSData *)data andHeaders:(NSDictionary*) givenHeaders;

@property(retain,readonly) NSDictionary* headers;

@end
