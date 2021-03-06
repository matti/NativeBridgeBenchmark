//
//  LocalStorageObserver.m
//  NativeBridgeBenchmark
//
//  Created by mpa on 28/09/14.
//
//

#import "LocalStorageObserver.h"

#import <FMDB/FMDB.h>
#import "NativeBridgeURLProtocol.h"

// Dispatch queue
dispatch_queue_t _dispatchQueue;

// A source of potential notifications
dispatch_source_t _source;


@implementation LocalStorageObserver

-(void) observeWithHTTPPort:(NSNumber *)port andHost:(NSString *)host andBasePath:(NSString *)basePath {
    
    // TODO ios8 in here: /Users/mpa/Library/Developer/CoreSimulator/Devices/40F7B20A-CC92-41E6-9839-BE282C2D85EC/data/Containers/Data/Application/1A4A6540-7F85-41D4-8522-666111F1425A/Library/WebKit/fi.helsinki.cs.paksula.NativeBridgeBenchmark/WebsiteData/LocalStorage

    // Wk webview?
//    NSString *basePath = [@"~/Library/WebKit/fi.helsinki.cs.paksula.NativeBridgeBenchmark/WebsiteData/LocalStorage" stringByExpandingTildeInPath];
    
    // gives "the other one", seems like ios8 stores uiwebview localstorage in own sandbox (with simulator, not in device)
    //NSString *basePath = [@"~/Library/Caches" stringByExpandingTildeInPath];

    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *dirContents = [fm contentsOfDirectoryAtPath:basePath error:nil];
    
    NSString *hostPort = @"0";
    if (port) {
        hostPort = port.stringValue;
    }
    
    NSString *ourLocalStorageFileNameFilter = [NSString stringWithFormat:@"self ENDSWITH 'http_%@_%@.localstorage'", host, hostPort];
    
    
    NSPredicate *fltr = [NSPredicate predicateWithFormat:ourLocalStorageFileNameFilter];
    NSArray *onlyLocalStorages = [dirContents filteredArrayUsingPredicate:fltr];
    
    NSString *ourLocalStorage = [onlyLocalStorages lastObject ];
    
    NSString *pathToLocalStorage = [ NSString stringWithFormat:@"%@/%@", basePath, ourLocalStorage];

    
    self.localStorageDB = [FMDatabase databaseWithPath:pathToLocalStorage];
    if ( [ self.localStorageDB open ] ) {
        NSLog(@"opened localstorage: %@", pathToLocalStorage);
        
        FMResultSet *s = [ self.localStorageDB executeQuery:@"SELECT * FROM ItemTable" ];
        
        BOOL foundDummy = NO;
        while ([s next]) {
            NSString *key = [ s stringForColumn:@"key" ];
            if ( [key isEqualToString:@"dummy"] ) {
                foundDummy = YES;
                break;
            }
        }
        
        NSAssert(foundDummy, @"did not find dummy key in localstorage");
    }
    
    // FILE WATCHER:
    
#define fileChangedNotification @"fileChangedNotification"
    
    // Get the path to the home directory
    //        NSString * homeDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    
    // Create a new file descriptor - we need to convert the NSString to a char * i.e. C style string
    int filedes = open([pathToLocalStorage cStringUsingEncoding:NSASCIIStringEncoding], O_EVTONLY);
    
    // Create a dispatch queue - when a file changes the event will be sent to this queue
    _dispatchQueue = dispatch_queue_create("FileMonitorQueue", 0);
    
    // Create a GCD source. This will monitor the file descriptor to see if a write command is detected
    // The following options are available
    
    /*!
     * @typedef dispatch_source_vnode_flags_t
     * Type of dispatch_source_vnode flags
     *
     * @constant DISPATCH_VNODE_DELETE
     * The filesystem object was deleted from the namespace.
     *
     * @constant DISPATCH_VNODE_WRITE
     * The filesystem object data changed.
     *
     * @constant DISPATCH_VNODE_EXTEND
     * The filesystem object changed in size.
     *
     * @constant DISPATCH_VNODE_ATTRIB
     * The filesystem object metadata changed.
     *
     * @constant DISPATCH_VNODE_LINK
     * The filesystem object link count changed.
     *
     * @constant DISPATCH_VNODE_RENAME
     * The filesystem object was renamed in the namespace.
     *
     * @constant DISPATCH_VNODE_REVOKE
     * The filesystem object was revoked.
     */
    
    // Write covers - adding a file, renaming a file and deleting a file...
    _source = dispatch_source_create(DISPATCH_SOURCE_TYPE_VNODE,filedes,
                                     DISPATCH_VNODE_WRITE,
                                     _dispatchQueue);
    
    
    // This block will be called when teh file changes
    dispatch_source_set_event_handler(_source, ^(){
        // We call an NSNotification so the file can change can be detected anywhere
        [[NSNotificationCenter defaultCenter] postNotificationName:fileChangedNotification object:Nil];
    });
    
    // When we stop monitoring the file this will be called and it will close the file descriptor
    dispatch_source_set_cancel_handler(_source, ^() {
        close(filedes);
    });
    
    // Start monitoring the file...
    dispatch_resume(_source);
    
    //...
    
    // When we want to stop monitoring the file we call this
    //dispatch_source_cancel(source);
    
    
    // To recieve a notification about the file change we can use the NSNotificationCenter
    [[NSNotificationCenter defaultCenter] addObserverForName:fileChangedNotification object:Nil queue:Nil usingBlock:^(NSNotification * notification) {
        // NSLog(@"File change detected!");
        
        // TODO: always returns "n" as value...
        FMResultSet *s = [ self.localStorageDB executeQuery:@"SELECT key, CAST(value AS TEXT) FROM ItemTable WHERE key LIKE 'nativebridge%'" ];


        while ([s next]) {
            NSString *key = [ s stringForColumn:@"key" ];
            NSString *value = [ s stringForColumnIndex:1 ];
            NSLog(@"GOTS: %@, %@", value, key);
            
            [NativeBridgeURLProtocol canInitWith: value];
            
            NSString *deleteQuery = [ NSString stringWithFormat:@"DELETE FROM ItemTable WHERE key='%@'", key];
            
            // NSLog(@"delete with: \n %@", deleteQuery);
            
            [ self.localStorageDB executeUpdate: deleteQuery];
            
        }
    }];

}
@end
