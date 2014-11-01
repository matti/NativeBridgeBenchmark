//
//  BenchmarkEvent.h
//  NativeBridgeBenchmark
//
//  Created by mpa on 01/11/14.
//
//

#import <Foundation/Foundation.h>

@interface BenchmarkEvent : NSObject

-(id) initWithMessage: (NSString *) msg andTargetURL: (NSURL*) url;

@end
