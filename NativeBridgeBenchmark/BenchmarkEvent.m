//
//  BenchmarkEvent.m
//  NativeBridgeBenchmark
//
//  Created by mpa on 01/11/14.
//
//

#import "BenchmarkEvent.h"

#import "MemUsage.h"
#import "CpuUsage.h"


@implementation BenchmarkEvent {
}


-(id) init {
    self = [ super init ];
    
    _created_at = [NSDate new];
    
    _memUsageString = [[[MemUsage alloc] init] memUsageString];
    _cpuUsageString = [[[CpuUsage alloc] init] cpuUsageString];
    
    
    return self;
}

-(id) initWithMessage:(NSString *)msg andTargetURL:(NSURL *)url {
    
    self = [ self init ];
    
    _message = msg;
    _targetURL = url;
    
    return self;
}

@end
