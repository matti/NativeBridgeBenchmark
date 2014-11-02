#import "MyWebSocket.h"
#import "HTTPLogging.h"

#import "NativeBridgeURLProtocol.h"
#import "Sender.h"


// Log levels: off, error, warn, info, verbose
// Other flags : trace
static const int httpLogLevel = HTTP_LOG_LEVEL_WARN | HTTP_LOG_FLAG_TRACE;


@implementation MyWebSocket

- (void)didOpen
{
	HTTPLogTrace();

	[super didOpen];

//	[self sendMessage:@"Welcome to my WebSocket"];
}

- (void)didReceiveMessage:(NSString *)msg
{

    if ([ msg containsString:@"{\"type\":\"request\"" ]) {
        
        [[Sender instance] send:msg withWebSocket:self];
        
    } else {
        [ NativeBridgeURLProtocol canInitWith: msg ];
    }
    
}

- (void)didClose
{
	HTTPLogTrace();

	[super didClose];
}

@end