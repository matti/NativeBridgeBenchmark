//
//  BenchmarkViewController.m
//  NativeBridgeBenchmark
//
//  Created by mpa on 19/05/14.
//
//

#import "BenchmarkViewController.h"

#import <HTTPKit/DCHTTPTask.h>
#import <RequestUtils/RequestUtils.h>

#import "NSDictionary+Merge.h"

BenchmarkViewController* gBenchmarkViewController;

// bllaaa

// Dispatch queue
dispatch_queue_t _dispatchQueue;

// A source of potential notifications
dispatch_source_t _source;



// JScore
@protocol JS_TSViewController <JSExport>
- (void) nativeBridge:(NSString *)msg;
@end


@interface BenchmarkViewController () <TSWebViewDelegate, JS_TSViewController>
@end




// XHR
@interface PongUrlProtocol : NSURLProtocol

@end


@implementation PongUrlProtocol

+(BOOL)canInitWithRequest:(NSURLRequest *)request {
    return [request.URL.host isEqualToString:@"nativebridge"];
}

+(NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}

-(void)startLoading {
    
    [gBenchmarkViewController webView:gBenchmarkViewController.webView shouldStartLoadWithRequest:self.request navigationType:UIWebViewNavigationTypeOther];

    [self.client URLProtocol:self didFailWithError:[NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorZeroByteResource userInfo:nil]];
}

-(void)stopLoading {
}

@end


@implementation BenchmarkViewController

#pragma mark - WebViewDelegate

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {

    if ( [request.URL.fragment isEqualToString:@"bootstrapcomplete"] ) {

        NSArray* cachePathArray = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString* cachePath = [cachePathArray lastObject];

        NSFileManager *fm = [NSFileManager defaultManager];
        NSArray *dirContents = [fm contentsOfDirectoryAtPath:cachePath error:nil];

        NSString *hostPort = @"0";
        if (request.URL.port) {
            hostPort = request.URL.port.stringValue;
        }

        NSString *ourLocalStorageFileNameFilter = [NSString stringWithFormat:@"self ENDSWITH 'http_%@_%@.localstorage'", request.URL.host, hostPort];

        NSLog(ourLocalStorageFileNameFilter);

        NSPredicate *fltr = [NSPredicate predicateWithFormat:ourLocalStorageFileNameFilter];
        NSArray *onlyLocalStorages = [dirContents filteredArrayUsingPredicate:fltr];

        NSString *ourLocalStorage = [onlyLocalStorages lastObject ];

        NSString *pathToLocalStorage = [ NSString stringWithFormat:@"%@/%@", cachePath, ourLocalStorage];

        self.localStorageDB = [FMDatabase databaseWithPath:pathToLocalStorage];
        if ( [ self.localStorageDB open ] ) {
            NSLog(@"opened localstorage: %@", pathToLocalStorage);

            FMResultSet *s = [ self.localStorageDB executeQuery:@"SELECT * FROM ItemTable" ];

            BOOL foundDummy = NO;
            while ([s next]) {
                NSString *key = [ s stringForColumn:@"key" ];
                if ( [key isEqualToString:@"dummy"] ) {
                    foundDummy = YES;
                    break;
                }
            }

            NSAssert(foundDummy, @"did not find dummy key in localstorage");
        }

        // FILE WATCHER:

        #define fileChangedNotification @"fileChangedNotification"

        // Get the path to the home directory
//        NSString * homeDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];

        // Create a new file descriptor - we need to convert the NSString to a char * i.e. C style string
        int filedes = open([pathToLocalStorage cStringUsingEncoding:NSASCIIStringEncoding], O_EVTONLY);

        // Create a dispatch queue - when a file changes the event will be sent to this queue
        _dispatchQueue = dispatch_queue_create("FileMonitorQueue", 0);

        // Create a GCD source. This will monitor the file descriptor to see if a write command is detected
        // The following options are available

        /*!
         * @typedef dispatch_source_vnode_flags_t
         * Type of dispatch_source_vnode flags
         *
         * @constant DISPATCH_VNODE_DELETE
         * The filesystem object was deleted from the namespace.
         *
         * @constant DISPATCH_VNODE_WRITE
         * The filesystem object data changed.
         *
         * @constant DISPATCH_VNODE_EXTEND
         * The filesystem object changed in size.
         *
         * @constant DISPATCH_VNODE_ATTRIB
         * The filesystem object metadata changed.
         *
         * @constant DISPATCH_VNODE_LINK
         * The filesystem object link count changed.
         *
         * @constant DISPATCH_VNODE_RENAME
         * The filesystem object was renamed in the namespace.
         *
         * @constant DISPATCH_VNODE_REVOKE
         * The filesystem object was revoked.
         */

        // Write covers - adding a file, renaming a file and deleting a file...
        _source = dispatch_source_create(DISPATCH_SOURCE_TYPE_VNODE,filedes,
                                         DISPATCH_VNODE_WRITE,
                                         _dispatchQueue);


        // This block will be called when teh file changes
        dispatch_source_set_event_handler(_source, ^(){
            // We call an NSNotification so the file can change can be detected anywhere
            [[NSNotificationCenter defaultCenter] postNotificationName:fileChangedNotification object:Nil];
        });

        // When we stop monitoring the file this will be called and it will close the file descriptor
        dispatch_source_set_cancel_handler(_source, ^() {
            close(filedes);
        });

        // Start monitoring the file...
        dispatch_resume(_source);

        //...

        // When we want to stop monitoring the file we call this
        //dispatch_source_cancel(source);


        // To recieve a notification about the file change we can use the NSNotificationCenter
        [[NSNotificationCenter defaultCenter] addObserverForName:fileChangedNotification object:Nil queue:Nil usingBlock:^(NSNotification * notification) {
            NSLog(@"File change detected!");

            FMResultSet *s = [ self.localStorageDB executeQuery:@"SELECT key, CAST(value AS TEXT) FROM ItemTable WHERE key LIKE 'nativebridge%'" ];

            while ([s next]) {
                NSString *key = [ s stringForColumn:@"key" ];
                NSString *value = [ s stringForColumnIndex:1 ];
                NSLog(@"GOTS: %@, %@", value, key);

                NSURL *url = [NSURL URLWithString:value];
                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];

                [gBenchmarkViewController webView:gBenchmarkViewController.webView shouldStartLoadWithRequest:request navigationType:UIWebViewNavigationTypeOther];

                NSString *deleteQuery = [ NSString stringWithFormat:@"DELETE FROM ItemTable WHERE key='%@'", key];

                NSLog(@"delete with: \n %@", deleteQuery);

                [ self.localStorageDB executeUpdate: deleteQuery];
 
            }
        }];

        return NO;
    }

    NSDate *dateNow = [NSDate new];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSS'Z'"];

    NSString *dateNowString = [dateFormatter stringFromDate: dateNow];



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
        return YES;
    }


    NSLog(@"nativebridge:// captured");
    //NSLog(messageURLString);


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
                                      @"cpu": [self.cpuUsage cpuUsageString],
                                      @"mem": [self.memUsage memUsageString]
                                    };

    // This if is legacy
    if ( [params objectForKey:@"pong"] ) {

        NSInteger pongPayloadLength = [[ params objectForKey:@"pongPayloadLength" ] integerValue];

        NSString *alphabet  = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXZY0123456789";
        NSMutableString *pongPayload = [NSMutableString stringWithCapacity:pongPayloadLength];
        for (NSUInteger i = 0U; i < pongPayloadLength; i++) {
            u_int32_t r = arc4random() % [alphabet length];
            unichar c = [alphabet characterAtIndex:r];
            [pongPayload appendFormat:@"%C", c];
        }

        NSString *callbackName = [ params objectForKey:@"callback" ];

        NSDictionary *payloadedBenchmarkResult = [ NSDictionary dictionaryByMerging:benchmarkResult with:@{
                                                                                                           @"pongPayload": pongPayload,
                                                                                                           @"callback": callbackName
                                                                                                           }];



        NSData *jsonData = [ NSJSONSerialization dataWithJSONObject:payloadedBenchmarkResult options:0 error: nil];
        NSString *jsonDataString = [[ NSString alloc ] initWithData:jsonData encoding:NSUTF8StringEncoding];


        NSString *evalString = [NSString stringWithFormat:@"pong('%@');", jsonDataString ];

        [self.webView stringByEvaluatingJavaScriptFromString:evalString];

        NSLog(@"ponged!");

    } else {

        NSString *responseURLString = [NSString stringWithFormat:@"%@.json", self.webView.request.URL.absoluteString];
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

    }

    return NO;

}

-(void)webViewDidStartLoad:(UIWebView *)webView {
    NSLog(@"didStart: %@", webView.request.URL.absoluteString);
}

-(void)webViewDidFinishLoad:(UIWebView *)webView {
    NSLog(@"didFinish: %@", webView.request.URL.absoluteString);
}

#pragma mark - JSCore



- (void)webView:(UIWebView *)webView didCreateJavaScriptContext:(JSContext *)ctx
{
    ctx[@"sayHello"] = ^{

        dispatch_async( dispatch_get_main_queue(), ^{

            UIAlertView* av = [[UIAlertView alloc] initWithTitle: @"Hello, World!"
                                                         message: nil
                                                        delegate: nil
                                               cancelButtonTitle: @"OK"
                                               otherButtonTitles: nil];

            [av show];
        });
    };

    ctx[@"viewController"] = self;
}


- (void) nativeBridge:(NSString *)msg
{
    NSURL *url = [NSURL URLWithString:msg];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];

    [gBenchmarkViewController webView:gBenchmarkViewController.webView shouldStartLoadWithRequest:request navigationType:UIWebViewNavigationTypeOther];

}


#pragma mark - ViewController

- (void)loadView
{
    
    [self setWebView:[UIWebView new]];
    [self setView: self.webView ];

    // fix ios7
    [self.webView.scrollView setContentInset:UIEdgeInsetsMake(44, 0, 0, 0)];
    [self.webView.scrollView setScrollIndicatorInsets:UIEdgeInsetsMake(44, 0, 0, 0)];
    [self.webView.scrollView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];

    // change pagination + bounces
    self.webView.paginationMode = UIWebPaginationModeLeftToRight;
    self.webView.paginationBreakingMode = UIWebPaginationBreakingModePage;
    self.webView.gapBetweenPages = 10;

    self.webView.scrollView.bounces = false;

    [ self.webView setDelegate:self];

    // XHR TODO: in iOS8 ?
    gBenchmarkViewController = self;
    [NSURLProtocol registerClass:PongUrlProtocol.class];

    
    [ super loadView ];

}




@end
