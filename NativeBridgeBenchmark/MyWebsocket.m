#import "MyWebSocket.h"
#import "HTTPLogging.h"

#import "BenchmarkViewController.h"
#import "AppDelegate.h"

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
    BenchmarkViewController *bvc = (BenchmarkViewController*)[[[[UIApplication sharedApplication ] delegate] window ] rootViewController];

    NSURL *url = [NSURL URLWithString:msg];
    NSMutableURLRequest *betterRequest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];

    [bvc webView: bvc.webView shouldStartLoadWithRequest:betterRequest navigationType:UIWebViewNavigationTypeOther];

    //	HTTPLogTrace2(@"%@[%p]: didReceiveMessage: %@", THIS_FILE, self, msg);

//	[self sendMessage:[NSString stringWithFormat:@"%@", [NSDate date]]];
}

- (void)didClose
{
	HTTPLogTrace();

	[super didClose];
}

@end