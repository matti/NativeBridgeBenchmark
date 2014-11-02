//
//  BenchmarkOperation.h
//  NativeBridgeBenchmark
//
//  Created by mpa on 02/11/14.
//
//

#import <Foundation/Foundation.h>
#import "BenchmarkEvent.h"

@interface BenchmarkOperation : NSOperation

-(id) initWithBenchmarkEvent: (BenchmarkEvent*) event;

@end
