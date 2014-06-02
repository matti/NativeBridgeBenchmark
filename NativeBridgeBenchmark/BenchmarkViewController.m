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

#import <CocoaHTTPServer/HTTPServer.h>
#import "MyHTTPConnection.h"

#import "Memusage.h"
#import "Cpuusage.h"


// JScore
@protocol JS_TSViewController <JSExport>
- (void) nativeBridge:(NSString *)msg;
@end


@interface BenchmarkViewController () <TSWebViewDelegate, JS_TSViewController>
@end

BenchmarkViewController* gController;


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

    [gController webView:gController.webView shouldStartLoadWithRequest:self.request navigationType:UIWebViewNavigationTypeOther];

    [self.client URLProtocol:self didFailWithError:[NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorZeroByteResource userInfo:nil]];
}

-(void)stopLoading {
}

@end


@implementation BenchmarkViewController

#pragma mark - WebViewDelegate

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {


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

    [gController webView:gController.webView shouldStartLoadWithRequest:request navigationType:UIWebViewNavigationTypeOther];

}


#pragma mark - ViewController

- (void)loadView
{

    self.memUsage = [[MemUsage alloc] init];
    self.cpuUsage = [[CpuUsage alloc] init];

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

    // XHR
    gController = self;
    [NSURLProtocol registerClass:PongUrlProtocol.class];

    // HTTPServer

    self.httpServer = [[HTTPServer alloc] init];
    [self.httpServer setConnectionClass:[MyHTTPConnection class]];
    [self.httpServer setType:@"_http._tcp."];
    [self.httpServer setPort: 31337];
    
    NSString *webPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Web"];
    [self.httpServer setDocumentRoot:webPath];

    NSError *error;
	if(![self.httpServer start:&error])
	{
		NSLog(@"Error starting HTTP Server: %@", error);
	} else {
        NSLog(@"HTTPServer started: %i", [self.httpServer port]);
    }

    // Cookies

    [NSNotificationCenter.defaultCenter addObserverForName:NSHTTPCookieManagerCookiesChangedNotification
                                                    object:nil
                                                     queue:nil
                                                usingBlock:^(NSNotification *notification) {
                                                    NSHTTPCookieStorage *cookieStorage = notification.object;
                                                    NSHTTPCookie *pongCookie = nil;
                                                    for (NSHTTPCookie *cookie in cookieStorage.cookies) {
                                                        if ([cookie.name hasPrefix:@"nativebridge" ]) {
                                                            pongCookie = cookie;
                                                            break;
                                                        }
                                                    }
                                                    if (!pongCookie) {
                                                        return;
                                                    }

                                                    NSURL *url = [NSURL URLWithString:pongCookie.value];
                                                    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];

                                                    [gController webView:gController.webView shouldStartLoadWithRequest:request navigationType:UIWebViewNavigationTypeOther];

                                                    [cookieStorage deleteCookie:pongCookie];
                                                }];


    [self restart];

    [self addNavigationBar];

}

-(void)addNavigationBar
{
    UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];


    navBar.backgroundColor = [UIColor yellowColor];

    UINavigationItem *navItem = [[UINavigationItem alloc] init];
    navItem.title = @"Benchmark";

    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"Reload" style:UIBarButtonItemStylePlain target:self action:@selector(reload)];
    navItem.leftBarButtonItem = leftButton;

    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Restart" style:UIBarButtonItemStylePlain target:self action:@selector(restart)];
    navItem.rightBarButtonItem = rightButton;


    
    navBar.items = @[ navItem ];

    [self.view insertSubview:navBar aboveSubview: self.view];
}

-(void)reload
{

    [[ self webView ] stringByEvaluatingJavaScriptFromString:@"window.location.reload();"];

}

-(void)restart {
    NSString *localHTMLPath = [NSBundle.mainBundle pathForResource:@"index" ofType:@"html"];
    NSURL *localHTMLURL = [NSURL fileURLWithPath:localHTMLPath];
    NSURLRequest *request = [NSURLRequest requestWithURL: localHTMLURL];
    
    [self.webView loadRequest: request ];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
