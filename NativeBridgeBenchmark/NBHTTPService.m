//
//  NBHTTPService.m
//  NativeBridgeBenchmark
//
//  Created by mpa on 17/10/14.
//
//

#import "NBHTTPService.h"

#import <CocoaHTTPServer/HTTPServer.h>
#import "MyHTTPConnection.h"

@implementation NBHTTPService

-(void)start {

    self.httpServer = [[HTTPServer alloc] init];
    [self.httpServer setConnectionClass:[MyHTTPConnection class]];
    [self.httpServer setType:@"_http._tcp."];
    [self.httpServer setPort: 31337];
    
    NSString *webPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Web"];
    [self.httpServer setDocumentRoot:webPath];
    
    NSError *error;
    if(![self.httpServer start:&error])
    {
        NSLog(@"Error starting HTTP Server: %@", error);
    } else {
        NSLog(@"HTTPServer started: %i", [self.httpServer port]);
    }
    
}

@end
