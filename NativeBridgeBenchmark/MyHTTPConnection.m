#import "MyHTTPConnection.h"
#import "HTTPMessage.h"
#import "HTTPResponse.h"
#import "HTTPDynamicFileResponse.h"
#import "GCDAsyncSocket.h"
#import "MyWebSocket.h"
#import "HTTPLogging.h"

#import "BridgeHead.h"
#import "NativeBridgeURLProtocol.h"
#import <RequestUtils/RequestUtils.h>
#import "NativeEvent.h"

#import "BetterHTTPDataResponse.h"

// Log levels: off, error, warn, info, verbose
// Other flags: trace
static const int httpLogLevel = HTTP_LOG_LEVEL_WARN; // | HTTP_LOG_FLAG_TRACE;


@implementation MyHTTPConnection

- (NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path
{
    
    // xhrlocal.async and xhrlocal.sync + xhrlocal.pongweb
    if ([path hasPrefix:@"/nativebridge://"]) {
        
        NSString *messageURLString = [path substringFromIndex:1];
        
        if ( [NativeBridgeURLProtocol parseRequestFromNativeBridgeURLProtocolPongWith:messageURLString]) {
            
            NSURL *tempURL = [[NSURL alloc ] initWithScheme:@"http" host:@"localhost" path:path];
            
            NSURLRequest *tempURLRequest = [[NSURLRequest alloc ] initWithURL:tempURL];
            NSDictionary *params = [ tempURLRequest GETParameters ];
            
            NativeEvent *nativeEvent = [[NativeEvent alloc] initWithPayload:@"" andMethod:[params valueForKey:@"method_name"] andWebviewStartedAt:[params valueForKey:@"webview_started_at"]];
            
            
            NSDictionary *headers = @{
                                      @"Connection": @"keep-alive",
                                      @"Cache-Control": @"public, max-age=0",
                                      @"Content-Type": @"application/javascript",
                                      @"Access-Control-Allow-Origin": @"*"
                                      };
            
            BetterHTTPDataResponse *lolsponse = [[BetterHTTPDataResponse alloc ] initWithData:[nativeEvent asData] andHeaders:headers];
            
            return lolsponse;
            
        } else {
            BridgeHead *bridgeHead = [BridgeHead new];
            [bridgeHead perform: messageURLString ];
        
            return [super httpResponseForMethod:method URI:path];
        }
    }

	if ([path isEqualToString:@"/WebSocketTest2.js"]) {
		// The socket.js file contains a URL template that needs to be completed:
		//
		// ws = new WebSocket("%%WEBSOCKET_URL%%");
		//
		// We need to replace "%%WEBSOCKET_URL%%" with whatever URL the server is running on.
		// We can accomplish this easily with the HTTPDynamicFileResponse class,
		// which takes a dictionary of replacement key-value pairs,
		// and performs replacements on the fly as it uploads the file.

		NSString *wsLocation;

		NSString *wsHost = [request headerField:@"Host"];
		if (wsHost == nil)
		{
			NSString *port = [NSString stringWithFormat:@"%hu", [asyncSocket localPort]];
			wsLocation = [NSString stringWithFormat:@"ws://localhost:%@/service", port];
		}
		else
		{
			wsLocation = [NSString stringWithFormat:@"ws://%@/service", wsHost];
		}

		NSDictionary *replacementDict = [NSDictionary dictionaryWithObject:wsLocation forKey:@"WEBSOCKET_URL"];

		return [[HTTPDynamicFileResponse alloc] initWithFilePath:[self filePathForURI:path]
                                                   forConnection:self
                                                       separator:@"%%"
                                           replacementDictionary:replacementDict];
	}

	return [super httpResponseForMethod:method URI:path];
}

- (WebSocket *)webSocketForURI:(NSString *)path
{
	HTTPLogTrace2(@"%@[%p]: webSocketForURI: %@", THIS_FILE, self, path);

	if([path isEqualToString:@"/service"])
	{
		HTTPLogInfo(@"MyHTTPConnection: Creating MyWebSocket...");

		return [[MyWebSocket alloc] initWithRequest:request socket:asyncSocket];
	}

	return [super webSocketForURI:path];
}

@end