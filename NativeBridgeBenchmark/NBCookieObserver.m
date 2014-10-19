//
//  NBCookieObserver.m
//  NativeBridgeBenchmark
//
//  Created by mpa on 17/10/14.
//
//

#import "NBCookieObserver.h"
#import "NativeBridgeURLProtocol.h"

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

                                                    
                                                    [ NativeBridgeURLProtocol canInitWith:messageCookie.value ];
                                                    
                                                    [cookieStorage deleteCookie:messageCookie];
                                                }];
    
}

@end
