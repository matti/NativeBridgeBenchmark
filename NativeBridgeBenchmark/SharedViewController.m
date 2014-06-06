//
//  SharedViewController.m
//  NativeBridgeBenchmark
//
//  Created by Matti Paksula on 06/06/14.
//
//

#import "SharedViewController.h"

@interface SharedViewController ()

@end

#import "BenchmarkViewController.h"

BenchmarkViewController *gBenchmarkViewController;

@implementation SharedViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

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
        //[ self.wkWebView reload];
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
