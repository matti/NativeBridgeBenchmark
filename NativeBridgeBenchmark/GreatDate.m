//
//  GreatDate.m
//  NativeBridgeBenchmark
//
//  Created by mpa on 02/11/14.
//
//

#import "GreatDate.h"

@implementation GreatDate

-(NSString*) format:(NSDate *)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSS'Z'"];
    
    return [dateFormatter stringFromDate: date ];
}
@end
