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

@property(retain,readonly) NSString* message;
@property(retain,readonly) NSURL* targetURL;

@property(retain,readonly) NSDate* created_at;
@property(retain,readonly) NSString* memUsageString;
@property(retain,readonly) NSString* cpuUsageString;

@end
