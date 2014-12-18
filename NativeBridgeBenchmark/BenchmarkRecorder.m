//
//  BenchmarkRecorder.m
//  NativeBridgeBenchmark
//
//  Created by mpa on 28/09/14.
//
//

#import "BenchmarkRecorder.h"




#import "SharedViewController.h"

#import "BenchmarkEvent.h"
#import "BenchmarkOperation.h"


@implementation BenchmarkRecorder {
    NSOperationQueue *operationQueue;
}

static BenchmarkRecorder *instance;

+(BenchmarkRecorder*) instance {
    if ( instance == nil )
        instance = [[ BenchmarkRecorder alloc ] init];
    
    return instance;
}


-(id) init {
    self = [ super init ];
    
    operationQueue = [NSOperationQueue new];
    [operationQueue setMaxConcurrentOperationCount:3];
    [operationQueue setSuspended:YES];
    
    return self;
}

-(NSInteger) flush {
    [operationQueue setSuspended:NO];
    
    NSInteger amountFlushed = operationQueue.operationCount;

    [operationQueue waitUntilAllOperationsAreFinished ];

    [operationQueue setSuspended:YES];
    
    
    SharedViewController *svc = (SharedViewController*)[[[[UIApplication sharedApplication ] delegate] window ] rootViewController];
    
    if (svc.webView) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [svc.webView stringByEvaluatingJavaScriptFromString:@"bridgeHead('{\"type\":\"flush_end\"}\');"];
        });
        NSLog(@"Signaled flush_end");
    } else {
        assert(NO);
    }
    
    return amountFlushed;
}

-(BOOL) queue:(NSString *)messageURLString {

    
    SharedViewController *svc = (SharedViewController*)[[[[UIApplication sharedApplication ] delegate] window ] rootViewController];
    
    NSURL *url;
    
    if (svc.webView) {
        url = svc.webView.request.URL;
    } else {
        url = svc.wkWebView.URL;
    }
    
    BenchmarkEvent *event = [[ BenchmarkEvent alloc ] initWithMessage:messageURLString andTargetURL:url ];
    
    BenchmarkOperation *benchmarkOperation = [[BenchmarkOperation alloc] initWithBenchmarkEvent:event];
    
    [operationQueue addOperation:benchmarkOperation];
    
    return YES;

}
@end
