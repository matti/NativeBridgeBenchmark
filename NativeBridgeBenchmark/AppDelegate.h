//
//  AppDelegate.h
//  NativeBridgeBenchmark
//
//  Created by mpa on 17/05/14.
//
//

#import <UIKit/UIKit.h>

#import <CocoaHTTPServer/HTTPServer.h>
#import "MyHTTPConnection.h"


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property(nonatomic, retain) HTTPServer* httpServer;

@end
