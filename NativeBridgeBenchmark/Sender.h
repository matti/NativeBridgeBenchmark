//
//  Sender.h
//  NativeBridgeBenchmark
//
//  Created by mpa on 02/11/14.
//
//

#import <Foundation/Foundation.h>

#import "MyWebsocket.h"

@interface Sender : NSObject

+(Sender*) instance;

-(BOOL) send: (NSString*) configurationMessage withWebSocket: (MyWebSocket*) webSocket;

-(NSString*) randomStringWithLength: (NSInteger) len;

@end
