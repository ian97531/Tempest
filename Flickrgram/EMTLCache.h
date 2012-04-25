//
//  EMTLCache.h
//  Flickrgram
//
//  Created by Ian White on 4/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EMTLCache;
@class EMTLCachedObject;
@class EMTLCacheRequest;

typedef enum {
    EMTLDictionary,
    EMTLImage
}EMTLDataType;

@protocol EMTLCacheClient <NSObject>

@required
- (void)retrievedObject:(id)object ForRequest:(EMTLCacheRequest *)request;
- (void)unableToRetrieveObjectForRequest:(EMTLCacheRequest *)request;

@optional
- (void)fetchedBytes:(int)bytes ofTotal:(int)total forRequest:(EMTLCacheRequest *)request;

@end


@protocol EMTLCacheHandler <NSObject>

@required
- (void)fetchObjectForRequest:(EMTLCacheRequest *)request;

@optional
- (void)cancelRequest:(EMTLCacheRequest *)request;

@end


@protocol EMTLCachePostProcessor <NSObject>

- (id)processObject:(id)object forRequest:(EMTLCacheRequest *)request;

@end



@interface EMTLCache : NSObject

{
    NSCache *memoryCache;
    NSMutableDictionary *diskAccessRecord;
    NSMutableDictionary *domainHandlers;
    NSMutableDictionary *postProcessors;
    NSMutableArray *invocations;
    NSMutableArray *pausingObjects;
    NSString *cacheDir;
    
    BOOL paused;
}

+ (id)cache;
- (id)init;
- (void)setObject:(id <NSCoding>)object forDomain:(NSString *)domain forKey:(NSString *)key type:(EMTLDataType)type;
- (id)objectInMemoryForRequest:(EMTLCacheRequest *)request;
- (BOOL)objectOnDiskForRequest:(EMTLCacheRequest *)request;
- (void)execute:(void (^)(void))block;
- (void)clearQueue;

// Methods for EMTLCacheHandlers and EMTLCachePostProcessors
- (void)setHandler:(id <EMTLCacheHandler>)handler forDomain:(NSString *)domain;
- (void)setPostProcessor:(id <EMTLCachePostProcessor>)processor forDomain:(NSString *)domain;
- (id <EMTLCacheHandler>)handlerForDomain:(NSString *)domain;
- (id <EMTLCachePostProcessor>)postProcessorForDomain:(NSString *)domain;

// Methods for UI Controllers
- (void)requestPause:(id)object;
- (void)requestResume:(id)object;

@end



@interface EMTLCacheRequest : NSObject <NSCopying>

@property (nonatomic, strong) NSString *domain;
@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSDate *newerThan;
@property (nonatomic) EMTLDataType type;
@property (nonatomic, assign) id <EMTLCacheClient> target;
@property (nonatomic, assign) id <EMTLCacheHandler> handler;
@property (nonatomic, assign) id <EMTLCachePostProcessor> processor;
@property (nonatomic, strong, readonly) EMTLCache *cache;
@property (nonatomic, strong) NSDictionary *userInfo;

- (id)initWithDomain:(NSString *)domain key:(NSString *)key type:(EMTLDataType)type;
- (void)execute;
- (void)cancel;

// For EMTLHandlers
- (void)fetchedObject:(id)object;
- (void)fetchedBytes:(int)bytes ofTotal:(int)total;
- (void)unableToFetchObject;
- (void)fetchedObjectFromDisk:(id)object withDate:(NSDate *)date;

@end
