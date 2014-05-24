//
//  BenchmarkViewController.m
//  NativeBridgeBenchmark
//
//  Created by mpa on 19/05/14.
//
//

#import "BenchmarkViewController.h"

#import <HTTPKit/DCHTTPTask.h>


@interface BenchmarkViewController ()
@property(nonatomic, retain) UIWebView *webView;
@end

@implementation BenchmarkViewController

#pragma mark - WebViewDelegate

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {

    NSString *targetURLString = request.URL.absoluteString;
    NSString *targetURLQueryString = request.URL.query;

    NSLog(@"shouldStartLoad: %@", targetURLString);


    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];

    for (NSString *param in [ targetURLQueryString componentsSeparatedByString:@"&"]) {
        NSArray *elts = [param componentsSeparatedByString:@"="];
        if([elts count] < 2) continue;

        [params setObject:[elts objectAtIndex:1] forKey:[elts objectAtIndex:0]];
    }

    NSLog(@"TIME WHEN WEBVIEW SENT: %@", [params valueForKey:@"webview_started_at"]);


    if ([ targetURLString hasPrefix:@"nativebridge://" ]) {
        NSLog(@"nativebridge:// captured");


        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS"];

        NSDate *dateNow = [NSDate new];

        NSString *dateNowString = [dateFormat stringFromDate: dateNow];
        NSLog(@"TIME WHEN HIT NATIVE: %@", dateNowString);

        NSString *responseURLString = self.webView.request.URL.absoluteString;

        // [NSString stringWithFormat: @"%@/%@", self.webView.request.URL.absoluteString, @"results"];
        NSLog(@"posting to %@", responseURLString);

        DCHTTPTask *task = [DCHTTPTask POST: responseURLString
                                 parameters:@{
                                              @"result": @{
                                                      @"webview_started_at": [params valueForKey:@"webview_started_at"],
                                                      @"native_received_at": dateNowString,
                                                      @"native_started_at": dateNowString,
                                                      },
                                            }];

//        [task.requestSerializer setValue:[NSString stringWithFormat:@"Token token=\"%@\"", API_TOKEN] forHTTPHeaderField:@"Authorization"];

        task.responseSerializer = [DCJSONResponseSerializer new];

        task.thenMain(^(DCHTTPResponse *response){
            NSLog(@"payload: %@",response.responseObject);
            NSLog(@"finished POST task");
        }).catch(^(NSError *error){
            NSLog(@"failed to upload file: %@",[error localizedDescription]);
        });
        [task start];


        return NO;
    } else {
        return YES;
    }
}

-(void)webViewDidStartLoad:(UIWebView *)webView {
    NSLog(@"didStart: %@", webView.request.URL.absoluteString);
}

-(void)webViewDidFinishLoad:(UIWebView *)webView {
    NSLog(@"didFinish: %@", webView.request.URL.absoluteString);
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


    [ self.webView setDelegate:self];

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
