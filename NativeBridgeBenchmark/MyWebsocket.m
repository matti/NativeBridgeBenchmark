#import "MyWebSocket.h"
#import "HTTPLogging.h"

#import "BenchmarkRecorder.h"
#import "BenchmarkViewController.h"

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
    BenchmarkRecorder *recorder = [BenchmarkRecorder new];
    [recorder recordMessage: msg ];
}

- (void)didClose
{
	HTTPLogTrace();

	[super didClose];
}

@end