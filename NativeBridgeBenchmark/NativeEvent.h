//
//  NativeEvent.h
//  NativeBridgeBenchmark
//
//  Created by mpa on 17/08/15.
//
//

#import <Foundation/Foundation.h>

@interface NativeEvent : NSObject

-(id) initWithPayload:(NSString *)givenPayload andMethod:(NSString *)givenMethod;
-(id) initWithPayload:(NSString *)givenPayload andMethod:(NSString *)givenMethod andWebviewStartedAt: (NSString*) givenWebviewStartedAt;

-(NSString*) asJSON;
-(NSData*) asData;

@property(retain, readonly) NSMutableDictionary* message;

@end
