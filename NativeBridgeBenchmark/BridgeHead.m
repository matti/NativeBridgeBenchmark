//
//  BridgeHead.m
//  NativeBridgeBenchmark
//
//  Created by mpa on 19/10/14.
//
//

#import "BridgeHead.h"
#import "BenchmarkRecorder.h"

@implementation BridgeHead

-(void)perform: (NSString*) messageURLString {
    NSLog(@"performing native call");
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void){
        BenchmarkRecorder *recorder = [ BenchmarkRecorder new ];
        [ recorder recordMessage:messageURLString ];
    });
}
@end
