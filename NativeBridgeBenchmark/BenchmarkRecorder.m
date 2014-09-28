//
//  BenchmarkRecorder.m
//  NativeBridgeBenchmark
//
//  Created by mpa on 28/09/14.
//
//

#import "BenchmarkRecorder.h"

#import "NSDictionary+Merge.h"
#import <RequestUtils/RequestUtils.h>
#import <HTTPKit/DCHTTPTask.h>

#import "MemUsage.h"
#import "CpuUsage.h"

#import "BenchmarkViewController.h"

@implementation BenchmarkRecorder

-(BOOL) recordMessage:(NSString *)messageURLString withReferer:(NSString *)referer {
    MemUsage *memUsage = [[MemUsage alloc] init];
    CpuUsage *cpuUsage = [[CpuUsage alloc] init];
    
    NSDate *dateNow = [NSDate new];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSS'Z'"];
    
    NSString *dateNowString = [dateFormatter stringFromDate: dateNow];
    
    
    NSDictionary *params = [messageURLString URLQueryParameters];
    
    NSUInteger payloadLength = [[params valueForKey:@"payload"] length];
    NSString *payloadLengthString = [NSString stringWithFormat:@"%lu", (unsigned long)payloadLength];
    
    
    NSDictionary *benchmarkResult = @{
                                      @"webview_started_at": [params valueForKey:@"webview_started_at"],
                                      @"native_received_at": dateNowString,
                                      @"native_started_at": dateNowString,
                                      @"webview_payload_length": payloadLengthString,
                                      @"from": @"native",
                                      @"method_name": [params valueForKey:@"method_name"],
                                      @"fps": [params valueForKey:@"fps"],
                                      @"cpu": [cpuUsage cpuUsageString],
                                      @"mem": [memUsage memUsageString],
                                      @"render_paused":[ params valueForKey:@"render_paused"]
                                      };
    
    NSString *responseURLString = [NSString stringWithFormat:@"%@.json", referer];
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
    
    return YES;

}

-(BOOL) recordMessage:(NSString *)messageURLString {

    // TODO: ugly
    BenchmarkViewController *bvc = (BenchmarkViewController*)[[[[UIApplication sharedApplication ] delegate] window ] rootViewController];

    NSString *referer = bvc.webView.request.URL.absoluteString;
    
    return [ self recordMessage:messageURLString withReferer:referer ];
}

-(BOOL) recordRequest:(NSURLRequest *)request {
    

    NSString *messageURLString = @"";
    
    if ( [request.URL.absoluteString hasPrefix:@"nativebridge://"] ) {
        messageURLString = request.URL.absoluteString;
    }
    
    if ( [request.URL.fragment hasPrefix:@"nativebridge://"]) {
        messageURLString = request.URL.fragment;
    }
    
    
    if ( [request.URL.host isEqualToString:@"nativebridge"] ) {
        messageURLString = [ NSString stringWithFormat:@"nativebridge:%@?%@", request.URL.path, request.URL.query];
    }
    
    if ( [messageURLString isEqualToString:@""] ) {
        return NO;
    }
    

    NSLog(@"nativebridge:// captured");
    //NSLog(messageURLString);


    NSString *referer = [[request allHTTPHeaderFields] objectForKey:@"Referer"];

    return [ self recordMessage:messageURLString withReferer:referer];
}
@end
