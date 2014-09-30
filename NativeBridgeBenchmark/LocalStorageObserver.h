//
//  LocalStorageObserver.h
//  NativeBridgeBenchmark
//
//  Created by mpa on 28/09/14.
//
//

#import <Foundation/Foundation.h>

#import <FMDB/FMDB.h>

@interface LocalStorageObserver : NSObject

-(void) observeWithHTTPPort: (NSNumber*) port andHost: (NSString *) host andBasePath: (NSString*) basePath;

@property(nonatomic, retain) FMDatabase* localStorageDB;

@end
