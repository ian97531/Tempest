//
//  EMTLCache.m
//  Flickrgram
//
//  Created by Ian White on 4/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EMTLCache.h"

@implementation EMTLCache
@synthesize runningRequests;

static EMTLCache *cache;


+ (id)cache
{
    if(!cache) {
        cache = [[EMTLCache alloc] init];
    }
    return cache;
}

- (id)init
{
    self = [super init];
    if (self) {
        memoryCache = [[NSCache alloc] init];
        diskAccessRecord = [NSMutableDictionary dictionaryWithCapacity:300];
        domainHandlers = [NSMutableDictionary dictionaryWithCapacity:10];
        postProcessors = [NSMutableDictionary dictionaryWithCapacity:10];
        invocations = [NSMutableArray arrayWithCapacity:100];
        pausingObjects = [NSMutableArray arrayWithCapacity:10];
        runningRequests = [NSMutableDictionary dictionaryWithCapacity:10];
        
        NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, 
                                                       NSUserDomainMask, YES);
        cacheDir = [dirPaths objectAtIndex:0];
        
        // Populate the diskCacheArray so that we can use the file cache.
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSArray *cacheContents = [fileManager contentsOfDirectoryAtPath:cacheDir error:nil];
        for (NSString *file in cacheContents) {
            [diskAccessRecord setValue:[NSDate date] forKey:file];
            NSLog(@"loading %@", file);
        }
        
        NSLog(@"loaded %i items from disk cache", cacheContents.count);
        paused = NO;

    }
    
    return self;
}

- (void)setObject:(id)object key:(NSString *)key type:(EMTLDataType)type
{
    
    [memoryCache setObject:object forKey:key];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0ul);
    
    dispatch_async(queue, ^{
        if(![diskAccessRecord objectForKey:key]) {
            [diskAccessRecord setObject:[NSDate date] forKey:key];
            NSString *filePath = [NSString stringWithFormat:@"%@/%@", cacheDir, key];
            if (type == EMTLImage) {
                NSData *data = UIImagePNGRepresentation((UIImage *)object);
                [data writeToFile:filePath atomically:YES];
            }
            else {
                
                [NSKeyedArchiver archiveRootObject:object toFile:filePath];
                
            }
        }
    });
    
    
        
                
        

}

- (id)objectInMemoryForRequest:(EMTLCacheRequest *)request;
{
    return [memoryCache objectForKey:request.combinedKey];
}

- (BOOL)objectOnDiskForRequest:(EMTLCacheRequest *)request
{
    NSDate *date_stored = [diskAccessRecord objectForKey:request.combinedKey];
    if(date_stored) {
        
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0ul);
        
        dispatch_async(queue, ^{
        
            NSData *data = [NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/%@-%@", cacheDir, request.domain, request.key]];
            
            id object;
            if (request.type == EMTLImage) {
                object = [UIImage imageWithData:data];
            }
            else {
                object = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            }
            
            [memoryCache setObject:object forKey:request.combinedKey];
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                [request fetchedObjectFromDisk:object withDate:date_stored];
            });
            
        });

        
        return YES;
    }
    
    return NO;
}

- (BOOL)objectIsCachedForRequest:(EMTLCacheRequest *)request
{
    return ([memoryCache objectForKey:request.combinedKey] || [diskAccessRecord objectForKey:request.combinedKey]);
}


// Methods for EMTLCacheHandlers and EMTLCachePostProcessors
- (void)setHandler:(id <EMTLCacheHandler>)handler forDomain:(NSString *)domain
{
    [domainHandlers setObject:handler forKey:domain];
}

- (void)setPostProcessor:(id <EMTLCachePostProcessor>)processor forDomain:(NSString *)domain
{
    [postProcessors setObject:processor forKey:domain];
}

- (id <EMTLCacheHandler>)handlerForDomain:(NSString *)domain
{
    return [domainHandlers objectForKey:domain];
}

- (id <EMTLCachePostProcessor>)postProcessorForDomain:(NSString *)domain
{
    return [postProcessors objectForKey:domain];
}


@end



@implementation EMTLCacheRequest

@synthesize domain;
@synthesize key;
@synthesize combinedKey;
@synthesize url;
@synthesize newerThan;
@synthesize target;
@synthesize handler;
@synthesize processor;
@synthesize cache;
@synthesize type;
@synthesize userInfo;
@synthesize siblingRequests;

+ (id)requestWithDomain:(NSString *)theDomain key:(NSString *)theKey type:(EMTLDataType)theType
{
    return [[EMTLCacheRequest alloc] initWithDomain:theDomain key:theKey type:theType];
}


- (id)initWithDomain:(NSString *)theDomain key:(NSString *)theKey type:(EMTLDataType)theType;
{
    self = [super init];
    if (self) {
        domain = theDomain;
        key = theKey;
        combinedKey = [NSString stringWithFormat:@"%@-%@", domain, key];
        type = theType;
        cache = [EMTLCache cache];
        newerThan = nil;
        target = nil;
        siblingRequests = [NSMutableArray arrayWithCapacity:5];
    }
    return self;
}

- (id)fetch
{
    // First check the in-memory cache
    id object = [cache objectInMemoryForRequest:self];
    if (object && target) {
        NSLog(@"using memory cache for %@-%@", domain, key);
        return object;
    }
    
    // Next check the on-disk cache
    else if([cache objectOnDiskForRequest:self]) {
        NSLog(@"using disk cache for %@-%@", domain, key);
        return nil;
    }
    
    // If nothing, try to download the object.
    else if([self downloadObject]) {
        NSLog(@"fetching from web for %@-%@", domain, key);
        return nil;
    }
        
    [target unableToRetrieveObjectForRequest:self];
    return nil;
}


- (void)cancel
{
    // If the object is being downloaded, this will cancel the download.
    @synchronized(cache.runningRequests) {
        EMTLCacheRequest *brother = [cache.runningRequests objectForKey:combinedKey];
        if(brother == self) {
            [cache.runningRequests removeObjectForKey:combinedKey];
        }
        if(connection) {
            [connection cancel];
        }
    }
    
    
}

// For EMTLCacheClients
#pragma mark - Methods for EMTLCache
- (void)unableToFetchObjectFromDisk
{   
    // If we couldn't get the object from disk, try to download it.
    if (![self downloadObject] && target) {
        [target unableToRetrieveObjectForRequest:self];
    }
}

- (void)fetchedObjectFromDisk:(id)object withDate:(NSDate *)date
{

    // If we got the object and it's new enough, return it.
    if (newerThan && [date compare:newerThan] == NSOrderedAscending) {
        if (!target) {
            return;
        }
        
        [target retrievedObject:object ForRequest:self];
        return;
    }
    
    // If we got the object and no date was specified, return it.
    else if (!newerThan) {
        if (!target) {
            return;
        }
        
        [target retrievedObject:object ForRequest:self];
        return;
    }
    
    // Otherwise we got an object that's too old. We need to
    // download a newer version if possible. If we can't
    // download a newer version, let the client know.
    if(![self downloadObject] && target) {
        [target unableToRetrieveObjectForRequest:self];
    }
    
}

- (BOOL)downloadObject
{
    @synchronized(cache.runningRequests) {
        EMTLCacheRequest *brother = [cache.runningRequests objectForKey:combinedKey];
        if (brother && target) {
            NSLog(@"adding myself to a sibling request");
            [brother.siblingRequests addObject:self];
            return YES;
        }
        else {
            [cache.runningRequests setValue:self forKey:combinedKey];
        }
    }
    
    NSURLRequest *request;
    
    // If the client specified a specific URL for this resource, use that.
    if(url) {
        request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:10.0];
    }
    else {
        
        // Otherwise, if a handler was given to get the resource, use that.
        // If no, handler was given, check to see if this resource's domain has a handler.
        if(!handler) {
            handler = [cache handlerForDomain:domain];
        }
        
        // Assuming we got a handler, get the request.
        if (handler) {
            request = [handler urlRequestForRequest:self];
        }
    }
    
    // If we have a valid NSURLRequest at this point, then run the request.
    if (request) {
        connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        return YES;
    }
    else  {
        return NO;
    }

}

- (void)connection:(NSURLConnection *)aConnection didReceiveResponse:(NSURLResponse *)aResponse {
    totalSize = (uint)aResponse.expectedContentLength;
    receivedData = [NSMutableData data];
}

- (void)connection:(NSURLConnection *)aConnection didFailWithError:(NSError *)error {
    
    if (target) {
        [target unableToRetrieveObjectForRequest:self];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [receivedData appendData:data];
    if(target) {
        [target fetchedBytes:receivedData.length ofTotal:totalSize forRequest:self];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {

    id object;
    if(!processor) {
        processor = [cache postProcessorForDomain:domain];
    }
    
    if (processor) {
        object = [processor processData:receivedData forRequest:self];
    }
    else if (type == EMTLImage) {
        object = [UIImage imageWithData:receivedData];
    }
    
    else {
        // This is dubious...
        object = receivedData;
    }
    
    [cache setObject:object key:combinedKey type:type];
    
    @synchronized(cache.runningRequests) {
        [cache.runningRequests removeObjectForKey:combinedKey];
    }
    
    if(target) {
        [target retrievedObject:object ForRequest:self];
    }
    
    if(siblingRequests.count) {
        for (EMTLCacheRequest *sibling in siblingRequests) {
            [sibling.target retrievedObject:object ForRequest:sibling];
        }
    }
    
}

@end