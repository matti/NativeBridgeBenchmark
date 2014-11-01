//
//  BenchmarkEvent.m
//  NativeBridgeBenchmark
//
//  Created by mpa on 01/11/14.
//
//

#import "BenchmarkEvent.h"

@implementation BenchmarkEvent {
    NSDate *created_at;
    NSString *message;
    NSURL *targetURL;
}

-(id) init {
    self = [ super init ];
    
    created_at = [NSDate new];
    
    return self;
}

-(id) initWithMessage:(NSString *)msg andTargetURL:(NSURL *)url {
    
    self = [ self init ];
    
    message = msg;
    targetURL = url;
    
    return self;
}

@end
