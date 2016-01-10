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

-(BOOL) supportsMethod:(NSString *)method atPath:(NSString *)path {
    return YES;
}

- (BOOL)expectsRequestBodyFromMethod:(NSString *)method atPath:(NSString *)path
{
    HTTPLogTrace();
    
    // Inform HTTP server that we expect a body to accompany a POST request
    
    if([method isEqualToString:@"POST"])
        return YES;
    
    return [super expectsRequestBodyFromMethod:method atPath:path];
}

- (void)processBodyData:(NSData *)postDataChunk
{
    HTTPLogTrace();
    
    // Remember: In order to support LARGE POST uploads, the data is read in chunks.
    // This prevents a 50 MB upload from being stored in RAM.
    // The size of the chunks are limited by the POST_CHUNKSIZE definition.
    // Therefore, this method may be called multiple times for the same POST request.
    
    BOOL result = [request appendData:postDataChunk];
    if (!result)
    {
        HTTPLogError(@"%@[%p]: %@ - Couldn't append bytes!", THIS_FILE, self, THIS_METHOD);
    }
}

- (NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path
{
    
    // xhrget.* and xhrpost.*
    if ([path hasPrefix:@"/nativebridge://"]) {
    
//        NSLog(@"body length %@",[NSByteCountFormatter stringFromByteCount:[[request body ]length] countStyle:NSByteCountFormatterCountStyleFile]);
//        NSString* newStr = [[NSString alloc] initWithData:[request body] encoding:NSUTF8StringEncoding];
//        
//        NSLog(newStr);
        
        NativeEvent *nativeEvent = nil;
        
        NSString *messageURLString = [path substringFromIndex:1];
        
        if ( [NativeBridgeURLProtocol parseRequestFromNativeBridgeURLProtocolPongWith:messageURLString]) {
    
            // moved lolsponse below for all cases as iOS9 was more stricter with CORS
            
        } else {
            
            BridgeHead *bridgeHead = [BridgeHead new];
            [bridgeHead perform: messageURLString ];
        
            // return [super httpResponseForMethod:method URI:path];
        }
        
        
        NSURL *tempURL = [[NSURL alloc ] initWithScheme:@"http" host:@"localhost" path:path];
        
        NSURLRequest *tempURLRequest = [[NSURLRequest alloc ] initWithURL:tempURL];
        NSDictionary *params = [ tempURLRequest GETParameters ];
        
        nativeEvent = [[NativeEvent alloc] initWithPayload:@"" andMethod:[params valueForKey:@"method_name"] andWebviewStartedAt:[params valueForKey:@"webview_started_at"]];
        
        NSDictionary *headers = @{
                                  @"Connection": @"keep-alive",
                                  @"Cache-Control": @"public, max-age=0",
                                  @"Content-Type": @"application/javascript",
                                  @"Access-Control-Allow-Origin": @"*"
                                  };
        
        BetterHTTPDataResponse *lolsponse = [[BetterHTTPDataResponse alloc ] initWithData:[nativeEvent asData] andHeaders:headers];
        
        return lolsponse;
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