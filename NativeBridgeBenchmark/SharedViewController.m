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

#import "UIWebViewViewController.h"
#import "IOS8BenchmarkViewController.h"


@implementation SharedViewController

-(void)loadView {
    [self addNavigationBar];
    [self restart];
}

-(void)addNavigationBar
{
    UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    
    
    navBar.backgroundColor = [UIColor yellowColor];
    
    UINavigationItem *navItem = [[UINavigationItem alloc] init];
    navItem.title = @"Benchmark";
    
    UIBarButtonItem *reloadButton = [[UIBarButtonItem alloc] initWithTitle:@"Reload" style:UIBarButtonItemStylePlain target:self action:@selector(reload)];
    navItem.leftBarButtonItem = reloadButton;
    
    UIBarButtonItem *restartButton = [[UIBarButtonItem alloc] initWithTitle:@"Restart" style:UIBarButtonItemStylePlain target:self action:@selector(restart)];

    UIBarButtonItem *webviewButton = [[UIBarButtonItem alloc] initWithTitle:@"W" style:UIBarButtonItemStylePlain target:self action:@selector(changeWebView)];

    navItem.rightBarButtonItems = @[restartButton, webviewButton];
    
    
    navBar.items = @[ navItem ];
    
    [self.view insertSubview:navBar aboveSubview: self.view];
}

-(void)changeWebView {

    UIWindow *window = [[ [ UIApplication sharedApplication ] delegate ] window ];
                                 
    SharedViewController *currentRootVC = (SharedViewController*)window.rootViewController;

    for (UIView *view in [currentRootVC.view subviews]) {
        [view removeFromSuperview];
    }
    
    
    SharedViewController *newVC;
    
    if (currentRootVC.wkWebView) {
        newVC = [UIWebViewViewController new];
        
    } else {
        newVC = [IOS8BenchmarkViewController new];
        currentRootVC.webView.delegate = nil;
        currentRootVC.webView = nil;
    }


    [currentRootVC.view removeFromSuperview];
    currentRootVC.view = nil;

    [currentRootVC dismissViewControllerAnimated:NO completion:nil];
    [currentRootVC removeFromParentViewController];
    
    [window setRootViewController:newVC];
    
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



@end
