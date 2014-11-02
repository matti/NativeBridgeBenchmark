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

@implementation Sender {
    NSTimer *timer;
    
    NSInteger interval;
    NSInteger messages;
    NSString *payload;
    NSString *method;
    
    MyWebSocket *webSocket;
}

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

-(void) send:(NSString *)configurationMessage withWebSocket:(MyWebSocket *)ws {
    
    webSocket = ws;
    
    NSData *json = [configurationMessage dataUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary *configuration = [NSJSONSerialization JSONObjectWithData:json options:kNilOptions error:nil];
    
    interval = [[configuration valueForKey:@"interval" ] integerValue];
    messages = [[configuration valueForKey:@"messages" ] integerValue];
    method = [configuration valueForKey:@"method" ];
    
    NSInteger payloadLength = [[configuration valueForKey:@"payloadLength" ] integerValue];
    payload = [ self randomStringWithLength:payloadLength ];

    
    timer = [ NSTimer scheduledTimerWithTimeInterval:interval/1000
                                              target:self
                                            selector:@selector(sender)
                                            userInfo:nil
                                             repeats:YES ];
    
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    
    // pump the run loop until someone tells us to stop
    while(messages > 0)
    {
        // allow the run loop to run for, arbitrarily, 2 seconds
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:2.0]];
        
    }


    
}

-(void) sender {
    
    if (messages == 0) {
        [timer invalidate];
        
        return;
    }
    
    NSDictionary *response = @{
                               @"payload": payload,
                               @"native_started_at": [[GreatDate new] format: [ NSDate new ]],
                               @"method": method,
                               @"cpu": [[ CpuUsage new ] cpuUsageString],
                               @"mem": [[ MemUsage new ] memUsageString]
                               };
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject: response
                                                       options: 0
                                                         error: nil];
    
    
    if ( [method isEqualToString: @"http.websockets"] ) {
        
        [webSocket sendData: jsonData ];
        
    }
    
    messages--;

}


@end
