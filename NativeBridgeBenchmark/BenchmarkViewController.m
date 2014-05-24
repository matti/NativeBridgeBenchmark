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

- (void)loadView
{
    [self setWebView:[UIWebView new]];
    [self setView: self.webView ];

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

    DCHTTPTask *task = [DCHTTPTask GET:@"http://cs.helsinki.fi"];

    task.thenMain(^(DCHTTPResponse *response){
        NSString *str = [[NSString alloc] initWithData:response.responseObject encoding:NSUTF8StringEncoding];
        NSLog(@"web request finished: %@",str);
    }).catch(^(NSError *error){
        NSLog(@"failed to load Request: %@",[error localizedDescription]);
    });
    [task start];

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
