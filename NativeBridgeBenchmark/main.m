//
//  main.m
//  NativeBridgeBenchmark
//
//  Created by mpa on 17/05/14.
//
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"

#import "NBHTTPService.h"

int main(int argc, char * argv[])
{
    @autoreleasepool {
        NBHTTPService *httpService = [ NBHTTPService new ];
        [httpService start];
        
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
