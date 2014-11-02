//
//  BenchmarkRecorder.h
//  NativeBridgeBenchmark
//
//  Created by mpa on 28/09/14.
//
//

#import <Foundation/Foundation.h>

@interface BenchmarkRecorder : NSObject

+(BenchmarkRecorder*) instance;

-(BOOL) queue:(NSString*) messageURLString;
-(NSInteger) flush;

//-(BOOL) recordRequest:(NSURLRequest*) request;
//-(BOOL) recordMessage:(NSString*) messageURLString;
//-(BOOL) recordMessage:(NSString *)messageURLString withReferer: (NSString *) referer;

@end
