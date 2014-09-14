//
//  SharedViewController.m
//  NativeBridgeBenchmark
//
//  Created by Matti Paksula on 06/06/14.
//
//

#import "SharedViewController.h"

#import "NSDictionary+Merge.h"
#import <RequestUtils/RequestUtils.h>
#import <HTTPKit/DCHTTPTask.h>


@interface SharedViewController ()

@end

#import "BenchmarkViewController.h"
BenchmarkViewController *gBenchmarkViewController;

@implementation SharedViewController


-(BOOL) handleRequest:(NSURLRequest *) request {
    
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
                                      @"mem": [self.memUsage memUsageString],
                                      @"render_paused":[ params valueForKey:@"render_paused"]
                                      };
    
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
    
    
    
    return NO;
}



-(void)loadView {
    self.memUsage = [[MemUsage alloc] init];
    self.cpuUsage = [[CpuUsage alloc] init];
    
    [ self startHTTPServer ];
    
    if ( self.webView ) {
        [ self addCookieObserver ];
    } else {
        // TODO: ios8?
    }
    
    [self addNavigationBar];
    [self restart];
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

    
    if (self.webView) {
        [[ self webView ] stringByEvaluatingJavaScriptFromString:@"window.location.reload();"];
    } else {
        [ self.wkWebView reload];
    }
}

-(void)restart {
    NSString *localHTMLPath = [NSBundle.mainBundle pathForResource:@"index" ofType:@"html"];
    NSURL *localHTMLURL = [NSURL fileURLWithPath:localHTMLPath];
    NSURLRequest *request = [NSURLRequest requestWithURL: localHTMLURL];
    
    if (self.webView) {
        [self.webView loadRequest: request];
    } else {
        [self.wkWebView loadRequest: request];

    }
}

-(void)startHTTPServer {
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

}

-(void)addCookieObserver {
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
                                                    
                                                    if (gBenchmarkViewController) {
                                                    [gBenchmarkViewController webView: gBenchmarkViewController.webView shouldStartLoadWithRequest:request navigationType:UIWebViewNavigationTypeOther];
                                                    } else {
                                                        NSLog(@"TODO: wkWebView w/ Cookies");
                                                    }
                                                    [cookieStorage deleteCookie:pongCookie];
                                                }];
    
}

@end
