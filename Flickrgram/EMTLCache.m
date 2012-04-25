//
//  EMTLCache.m
//  Flickrgram
//
//  Created by Ian White on 4/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EMTLCache.h"

@implementation EMTLCache

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
        
        NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, 
                                                       NSUserDomainMask, YES);
        cacheDir = [dirPaths objectAtIndex:0];
        
        paused = NO;

    }
    
    return self;
}

- (void)setObject:(id <NSCoding>)object forDomain:(NSString *)domain key:(NSString *)key type:(EMTLDataType)type
{
    NSString *combinedKey = [NSString stringWithFormat:@"%@-%@", domain, key];
    [memoryCache setObject:object forKey:combinedKey];
    
    [self execute:^(void) {
        
        NSData *data;
        if (type == EMTLImage) {
            data = UIImagePNGRepresentation((UIImage *)object);
        }
        else {
            NSMutableData *mutableData;
            NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:mutableData];
            [archiver encodeRootObject:object];
            [archiver finishEncoding];
            data = [NSData dataWithData:mutableData];
        }
        
        if (data) {
            [data writeToFile:[NSString stringWithFormat:@"%@/%@-%@.cache", cacheDir, domain, key] atomically:YES];
        }
        
        [diskAccessRecord setObject:[NSDate date] forKey:combinedKey];
        
                
        
    }];
}

- (id)objectInMemoryForRequest:(EMTLCacheRequest *)request;
{
    return [memoryCache objectForKey:request.key];
}

- (BOOL)objectOnDiskForRequest:(EMTLCacheRequest *)request
{
    NSString *combinedKey = [NSString stringWithFormat:@"%@-%@", request.domain, request.key];
    NSDate *date_stored = [diskAccessRecord objectForKey:combinedKey];
    if(date_stored) {
        [self execute:^(void){
            
            NSData *data = [NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/%@-%@.cache", cacheDir, request.domain, request.key]];
            
            id object;
            if (request.type == EMTLImage) {
                object = [UIImage imageWithData:data];
            }
            else {
                NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
                object = [unarchiver decodeObject];
                [unarchiver finishDecoding];
            }
            
            [memoryCache setObject:object forKey:combinedKey];

            [request fetchedObjectFromDisk:object withDate:date_stored];

        }];
        return YES;
    }
    
    return NO;
}

- (void)execute:(void (^)(void))block
{
    
    if (paused) {
        [invocations addObject:block];
    }
    else {
        block();
    }
    
    
}

- (void)clearQueue
{
    while (invocations.count) {
        void (^block)(void) = [invocations objectAtIndex:0];
        block();
    }
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

// Methods for UI Controllers
- (void)requestPause:(id)object
{
    paused = YES;
    [pausingObjects addObject:object];
}

- (void)requestResume:(id)object
{
    [pausingObjects removeObject:object];
    if(pausingObjects.count == 0) {
        paused = NO;
        [self clearQueue];
    }
    
}

@end



@implementation EMTLCacheRequest

@synthesize domain;
@synthesize key;
@synthesize newerThan;
@synthesize target;
@synthesize handler;
@synthesize processor;
@synthesize cache;
@synthesize type;

- (id)initWithDomain:(NSString *)theDomain key:(NSString *)theKey type:(EMTLDataType)theType;
{
    self = [super init];
    if (self) {
        domain = theDomain;
        key = theKey;
        type = theType;
        cache = [EMTLCache cache];
        newerThan = nil;
    }
    return self;
}

- (void)execute
{
    id object = [cache objectInMemoryForRequest:self];
    if (object) {
        [target retrievedObject:object ForRequest:self];
        return;
    }
    else if([cache objectOnDiskForRequest:self]) {
        return;
    }

    [self invokeHandler];
}


- (void)cancel
{
    [handler cancelRequest:self];
}

// For EMTLHandlers
- (void)fetchedObject:(id)object
{
    
    
    if(!processor) {
        processor = [cache postProcessorForDomain:domain];
    }
    
    if (processor) {
        [cache execute:^(void){
            id processedObject = [processor processObject:object forRequest:self];
            [cache setObject:processedObject forDomain:domain key:key type:type];
            [target retrievedObject:processedObject ForRequest:self];
        }];
    }
    else {
        [cache setObject:object forDomain:domain key:key type:type];
        [target retrievedObject:object ForRequest:self];
    }
    
    
}


- (void)fetchedBytes:(int)bytes ofTotal:(int)total
{
    if ([[target class] instancesRespondToSelector:@selector(fetchedBytes:ofTotal:forRequest:)]) {
        [target fetchedBytes:bytes ofTotal:total forRequest:self];
    }
}

- (void)unableToFetchObject
{   
    [target unableToRetrieveObjectForRequest:self];
}

- (void)fetchedObjectFromDisk:(id)object withDate:(NSDate *)date
{
    [cache setObject:object forDomain:domain key:key type:type];
    if (newerThan && [date compare:newerThan] == NSOrderedAscending) {
        [target retrievedObject:object ForRequest:self];
        return;
    }
    else if (!newerThan) {
        [target retrievedObject:object ForRequest:self];
        return;
    }
    
    [self invokeHandler];
    
}

- (void)invokeHandler
{
    if(!handler) {
        handler = [cache handlerForDomain:domain];
    }
    
    if (handler) {
        [cache execute:^(void) {
            [handler fetchObjectForRequest:self];
        }];
    }
    else {
        [target unableToRetrieveObjectForRequest:self];
    }

}

@end