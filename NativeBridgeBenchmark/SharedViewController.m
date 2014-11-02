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
#import "WKWebViewController.h"
#import "BenchmarkRecorder.h"


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
    navItem.title = @"B";
    
    UIBarButtonItem *reloadButton = [[UIBarButtonItem alloc] initWithTitle:@"Reload" style:UIBarButtonItemStylePlain target:self action:@selector(reload)];
    navItem.leftBarButtonItem = reloadButton;
    
    UIBarButtonItem *restartButton = [[UIBarButtonItem alloc] initWithTitle:@"Restart" style:UIBarButtonItemStylePlain target:self action:@selector(restart)];

    UIBarButtonItem *webviewButton = [[UIBarButtonItem alloc] initWithTitle:@"W" style:UIBarButtonItemStylePlain target:[SharedViewController class] action:@selector(toggleAndSetWebView)];

    UIBarButtonItem *flushButton = [[UIBarButtonItem alloc] initWithTitle:@"F" style:UIBarButtonItemStylePlain target:[SharedViewController class] action:@selector(flush)];
    
    navItem.rightBarButtonItems = @[restartButton, webviewButton, flushButton];
    
    
    navBar.items = @[ navItem ];
    
    [self.view insertSubview:navBar aboveSubview: self.view];
}


+(void) flush {
    
    NSLog(@"Flushing events");
    
    
    UIAlertView *alertView = [[UIAlertView alloc ] initWithTitle:@"flushing" message:@"started" delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
    
    [alertView show];
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
    
    
    NSInteger flushed = [[ BenchmarkRecorder instance ] flush ];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        alertView.title = @"flushed";

        alertView.message = [@(flushed) stringValue];

        [alertView show];
        [alertView dismissWithClickedButtonIndex:0 animated:YES];
    });

    
}

-(void) restart {
    
    NSString *localHTMLPath = [NSBundle.mainBundle pathForResource:@"index" ofType:@"html"];
    NSURL *localHTMLURL = [NSURL fileURLWithPath:localHTMLPath];
    self.startingRequest = [NSURLRequest requestWithURL: localHTMLURL];

    NSLog(@"Restarting from %@", localHTMLPath);
}

-(void) reload {
    NSLog(@"Reloading...");
}

# pragma mark - Class

+(void)toggleAndSetWebView {
    
    UIWindow *window = [[ [ UIApplication sharedApplication ] delegate ] window ];
    
    SharedViewController *currentRootVC = (SharedViewController*)window.rootViewController;
    
    for (UIView *view in [currentRootVC.view subviews]) {
        [view removeFromSuperview];
    }
    
    
    SharedViewController *newVC;
    
    if (currentRootVC.webView) {
        newVC = [WKWebViewController new];
        currentRootVC.webView.delegate = nil;
        currentRootVC.webView = nil;
    } else {
        newVC = [UIWebViewViewController new];
    }
    
    
    [currentRootVC.view removeFromSuperview];
    currentRootVC.view = nil;
    
    [currentRootVC dismissViewControllerAnimated:NO completion:nil];
    [currentRootVC removeFromParentViewController];
    
    [window setRootViewController:newVC];
}


@end
