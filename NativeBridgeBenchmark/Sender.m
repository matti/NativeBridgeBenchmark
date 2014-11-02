//
//  Sender.m
//  NativeBridgeBenchmark
//
//  Created by mpa on 02/11/14.
//
//

#import "Sender.h"

#import "GreatDate.h"
#import "CpuUsage.h"
#import "MemUsage.h"

@implementation Sender

static Sender *instance;

+(Sender*) instance {
    if ( instance == nil )
        instance = [[ Sender alloc ] init];
    
    return instance;
}

-(NSString*) randomStringWithLength: (NSInteger) len {
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
        
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform([letters length])]];
    }
        
    return randomString;
}

-(BOOL) send:(NSString *)configurationMessage withWebSocket:(MyWebSocket *)webSocket {
    
    NSData *json = [configurationMessage dataUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary *configuration = [NSJSONSerialization JSONObjectWithData:json options:kNilOptions error:nil];
    
    NSInteger interval = [[configuration valueForKey:@"interval" ] integerValue];
    NSInteger messages = [[configuration valueForKey:@"messages" ] integerValue];
    NSInteger payloadLength = [[configuration valueForKey:@"payloadLength" ] integerValue];
    NSString *method = [configuration valueForKey:@"method" ];
    
    NSString *payload = [ self randomStringWithLength:payloadLength ];

    
    NSString *native_started_at = [[GreatDate new] format: [ NSDate new ]];
    
    if ( [method isEqualToString: @"http.websockets"] ) {
        
        NSDictionary *response = @{
                                   @"payload": payload,
                                   @"native_started_at": native_started_at,
                                   @"method": method,
                                   @"cpu": [[ CpuUsage new ] cpuUsageString],
                                   @"mem": [[ MemUsage new ] memUsageString]
                                   };
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject: response
                                                           options: 0
                                                             error: nil];
        
        [webSocket sendData: jsonData ];
        
    }

    
    
//    {
//        interval = 25;
//        messages = 100;
//        method = "http.websockets";
//        payloadLength = 3;
//        type = request;
//    }

    
    return YES;
}

@end
