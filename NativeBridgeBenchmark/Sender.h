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

-(void) send: (NSString*) configurationMessage withWebSocket: (MyWebSocket*) ws;
-(void) sender;

-(void) showAlert: (NSString*) message;

-(NSDictionary*) parseConfigurationMessage: (NSString *) configurationMessage;

-(NSString*) randomStringWithLength: (NSInteger) len;


@end
