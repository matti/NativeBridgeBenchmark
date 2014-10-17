//
//  NBHTTPService.h
//  NativeBridgeBenchmark
//
//  Created by mpa on 17/10/14.
//
//

#import <Foundation/Foundation.h>

@class HTTPServer;

@interface NBHTTPService : NSObject

@property(nonatomic, retain) HTTPServer* httpServer;

-(void)start;

@end
