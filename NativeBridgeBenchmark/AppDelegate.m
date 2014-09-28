//
//  AppDelegate.m
//  NativeBridgeBenchmark
//
//  Created by mpa on 17/05/14.
//
//

#import "AppDelegate.h"
#import "BenchmarkViewController.h"

#import "NativeBridgeURLProtocol.h"
#import "BenchmarkRecorder.h"


#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 80000
#import "IOS8BenchmarkViewController.h"
#endif

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor redColor];

    UIViewController *benchmarkViewController = nil;
    
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 80000
    benchmarkViewController = [IOS8BenchmarkViewController new];
#else
    benchmarkViewController = [BenchmarkViewController new];
#endif

    [self.window setRootViewController: benchmarkViewController];
    
    [self.window makeKeyAndVisible];
    
    
    [NSURLProtocol registerClass:[NativeBridgeURLProtocol class]];

    [ self startHTTPServer ];
    [ self addCookieObserver ];
    
    return YES;
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
                                                    
                                                    // TODO: Ugly
                                                    BenchmarkRecorder *recorder = [BenchmarkRecorder new];

                                                    BenchmarkViewController *bvc = self.window.rootViewController;
                                                    
                                                    NSString *referer = bvc.webView.request.URL.absoluteString;
                                                    
                                                    [ recorder recordMessage:pongCookie.value withReferer: referer ];
                                                    
                                                    [cookieStorage deleteCookie:pongCookie];
                                                }];
    
}



- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
