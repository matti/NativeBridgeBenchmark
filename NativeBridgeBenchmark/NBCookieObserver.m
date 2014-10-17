//
//  NBCookieObserver.m
//  NativeBridgeBenchmark
//
//  Created by mpa on 17/10/14.
//
//

#import "NBCookieObserver.h"
#import "BenchmarkRecorder.h"

@implementation NBCookieObserver

-(void)observe {
    [NSNotificationCenter.defaultCenter addObserverForName:NSHTTPCookieManagerCookiesChangedNotification
                                                    object:nil
                                                     queue:nil
                                                usingBlock:^(NSNotification *notification) {
                                                    NSHTTPCookieStorage *cookieStorage = notification.object;
                                                    NSHTTPCookie *messageCookie = nil;
                                                    for (NSHTTPCookie *cookie in cookieStorage.cookies) {
                                                        if ([cookie.name hasPrefix:@"nativebridge" ]) {
                                                            messageCookie = cookie;
                                                            break;
                                                        }
                                                    }
                                                    if (!messageCookie) {
                                                        return;
                                                    }
                                                    
                                                    BenchmarkRecorder *recorder = [BenchmarkRecorder new];
                                                    
                                                    
                                                    [ recorder recordMessage:messageCookie.value ];
                                                    
                                                    [cookieStorage deleteCookie:messageCookie];
                                                }];
    
}

@end
