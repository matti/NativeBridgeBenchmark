//
//  NativeEvent.m
//  NativeBridgeBenchmark
//
//  Created by mpa on 17/08/15.
//
//

#import "NativeEvent.h"
#import "GreatDate.h"
#import "CpuUsage.h"
#import "MemUsage.h"


@implementation NativeEvent

-(id) init {
    self = [ super init ];
    
    NSDictionary *betterMessage = @{
                 @"payload": @"",
                 @"native_started_at": [[GreatDate new] format: [ NSDate new ]],
                 @"method": @"",
                 @"cpu": [[ CpuUsage new ] cpuUsageString],
                 @"mem": [[ MemUsage new ] memUsageString]
                 };
    
    _message = [betterMessage mutableCopy];
    
    return self;
}

-(id) initWithPayload:(NSString *)givenPayload andMethod:(NSString *)givenMethod {
    
    self = [ self init ];
    
    [_message setObject:givenPayload forKey:@"payload"];
    [_message setObject:givenMethod forKey:@"method"];
    
    return self;
}

-(id) initWithPayload:(NSString *)givenPayload andMethod:(NSString *)givenMethod andWebviewStartedAt:(NSString *)givenWebviewStartedAt {

    self = [ self initWithPayload:givenPayload andMethod:givenMethod ];
    [_message setObject:givenWebviewStartedAt forKey:@"webview_started_at"];
    
    return self;
}

-(NSString*) asJSON {
    return [[ NSString alloc ] initWithData:[self asData] encoding:NSUTF8StringEncoding];
}

-(NSData*) asData {
    return [NSJSONSerialization dataWithJSONObject: _message
                                                       options: 0
                                                         error: nil];
}

@end
