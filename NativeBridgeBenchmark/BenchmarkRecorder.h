//
//  BenchmarkRecorder.h
//  NativeBridgeBenchmark
//
//  Created by mpa on 28/09/14.
//
//

#import <Foundation/Foundation.h>

@interface BenchmarkRecorder : NSObject

-(BOOL) recordRequest:(NSURLRequest*) request;
@end
