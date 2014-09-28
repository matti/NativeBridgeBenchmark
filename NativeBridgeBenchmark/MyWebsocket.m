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
    // TODO: ugly
    BenchmarkViewController *bvc = (BenchmarkViewController*)[[[[UIApplication sharedApplication ] delegate] window ] rootViewController];

    
    BenchmarkRecorder *recorder = [BenchmarkRecorder new];
    
    [recorder recordMessage: msg
                withReferer: bvc.webView.request.URL.absoluteString];
    
}

- (void)didClose
{
	HTTPLogTrace();

	[super didClose];
}

@end