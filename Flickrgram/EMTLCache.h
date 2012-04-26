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
    EMTLKeyedObject,
    EMTLImage
} EMTLDataType;



@protocol EMTLCacheClient <NSObject>

@required
- (void)retrievedObject:(id)object ForRequest:(EMTLCacheRequest *)request;
- (void)unableToRetrieveObjectForRequest:(EMTLCacheRequest *)request;

@optional
- (void)fetchedBytes:(int)bytes ofTotal:(int)total forRequest:(EMTLCacheRequest *)request;

@end


@protocol EMTLCacheHandler <NSObject>

- (NSURLRequest *)urlRequestForRequest:(EMTLCacheRequest *)request;

@end


@protocol EMTLCachePostProcessor <NSObject>

- (id)processData:(NSData *)data forRequest:(EMTLCacheRequest *)request;

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

@property (nonatomic, strong) NSMutableDictionary *runningRequests;

+ (id)cache;
- (id)init;
- (void)setObject:(id)object key:(NSString *)key type:(EMTLDataType)type;
- (id)objectInMemoryForRequest:(EMTLCacheRequest *)request;
- (BOOL)objectOnDiskForRequest:(EMTLCacheRequest *)request;
- (BOOL)objectIsCachedForRequest:(EMTLCacheRequest *)request;

// Methods for EMTLCacheHandlers and EMTLCachePostProcessors
- (void)setHandler:(id <EMTLCacheHandler>)handler forDomain:(NSString *)domain;
- (void)setPostProcessor:(id <EMTLCachePostProcessor>)processor forDomain:(NSString *)domain;
- (id <EMTLCacheHandler>)handlerForDomain:(NSString *)domain;
- (id <EMTLCachePostProcessor>)postProcessorForDomain:(NSString *)domain;

@end



@interface EMTLCacheRequest : NSObject <NSURLConnectionDataDelegate>
{
    NSURLConnection *connection;
    NSMutableData *receivedData;
    uint totalSize;
    
}

@property (nonatomic, strong) NSString *domain;
@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong, readonly) NSString *combinedKey;
@property (nonatomic, strong) NSDate *newerThan;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic) EMTLDataType type;
@property (nonatomic, assign) id <EMTLCacheClient> target;
@property (nonatomic, assign) id <EMTLCacheHandler> handler;
@property (nonatomic, assign) id <EMTLCachePostProcessor> processor;
@property (nonatomic, strong, readonly) EMTLCache *cache;
@property (nonatomic, strong) NSDictionary *userInfo;
@property (nonatomic, strong) NSMutableArray *siblingRequests;

+ (id)requestWithDomain:(NSString *)theDomain key:(NSString *)theKey type:(EMTLDataType)theType;
- (id)initWithDomain:(NSString *)domain key:(NSString *)key type:(EMTLDataType)type;
- (id)fetch;
- (void)cancel;

// For EMTLCache and EMTLCacheRequests
- (void)unableToFetchObjectFromDisk;
- (void)fetchedObjectFromDisk:(id)object withDate:(NSDate *)date;
- (void)fetchedObject:(id)object fromAnotherRequest:(EMTLCache *)request;

// NSURLConnectionDataDelegate
- (void)connection:(NSURLConnection *)aConnection didReceiveResponse:(NSURLResponse *)aResponse;
- (void)connection:(NSURLConnection *)aConnection didFailWithError:(NSError *)error;
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;

@end
