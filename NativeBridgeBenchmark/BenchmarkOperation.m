//
//  BenchmarkOperation.m
//  NativeBridgeBenchmark
//
//  Created by mpa on 02/11/14.
//
//

#import "BenchmarkOperation.h"

#import "NSDictionary+Merge.h"
#import <RequestUtils/RequestUtils.h>
#import <HTTPKit/DCHTTPTask.h>

#import "GreatDate.h"

@implementation BenchmarkOperation {
    BenchmarkEvent *benchmarkEvent;
}

-(id) initWithBenchmarkEvent:(BenchmarkEvent *)event {
    self = [ self init ];
    
    benchmarkEvent = event;
    
    return self;
}

-(void) main {
    
    NSString *dateNowString = [[ GreatDate new ] format: benchmarkEvent.created_at];
    
    
    NSDictionary *params = [benchmarkEvent.message URLQueryParameters];

    NSUInteger payloadLength = [[params valueForKey:@"payload"] length];
    NSString *payloadLengthString = [NSString stringWithFormat:@"%lu", (unsigned long)payloadLength];

    
    NSDictionary *benchmarkResult = @{
                                      @"webview_started_at": [params valueForKey:@"webview_started_at"],
                                      @"native_received_at": dateNowString,
                                      @"webview_payload_length": payloadLengthString,
                                      @"from": @"native",
                                      @"method_name": [params valueForKey:@"method_name"],
                                      @"fps": [params valueForKey:@"fps"],
                                      @"cpu": benchmarkEvent.cpuUsageString,
                                      @"mem": benchmarkEvent.memUsageString,
                                      @"render_paused":[ params valueForKey:@"render_paused"]
                                      };

    NSString *responseURLString = [NSString stringWithFormat:@"%@.json", benchmarkEvent.targetURL];
    NSLog(@"posting to %@", responseURLString);

    
    DCHTTPTask *task = [DCHTTPTask POST: responseURLString
                             parameters: @{ @"result": benchmarkResult }];
    
    
    [task setResponseSerializer:[DCJSONResponseSerializer new] forContentType:@"application/json"];
    
    task.then(^(DCHTTPResponse *response){
        //NSString *str = [[NSString alloc] initWithData:response.responseObject encoding:NSUTF8StringEncoding];
        //NSLog(str);
    }).catch(^(NSError *error){
        NSLog(@"failed to upload file: %@",[error localizedDescription]);
    });
    [task start];

}
@end
