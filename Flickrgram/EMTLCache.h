//
//  EMTLCache.h
//  Flickrgram
//
//  Created by Ian White on 4/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EMTLCache;
typedef long long EMTLCacheRequestIdentifier;

@protocol EMTLCacheClient <NSObject>

@required
- (void)retreivedObject:(id)forDomain:(NSString *)domain key:(NSString *)key request_id:(EMTLCacheRequestIdentifier)request_id;
- (void)unableToRetrieveObjectForDomain:(NSString *)domain key:(NSString *)key request_id:(EMTLCacheRequestIdentifier)request_id;

@optional
- (void)fetchedBytes:(int)bytes ofTotal:(int)total forDomain:(NSString *)domain key:(NSString *)key request_id:(EMTLCacheRequestIdentifier)request_id;

@end

@protocol EMTLCacheHandler <NSObject>

- (void)fetchObjectForDomain:(NSString *)domain key:(NSString *)key request_id:(EMTLCacheRequestIdentifier)request_id target:(EMTLCache *)cache;
- (void)cancelRequest:(EMTLCacheRequestIdentifier)request_identifier;

@end

@protocol EMTLCachePostProcessor <NSObject>

- (id)processObjectForDomain:(NSString *)domain key:(NSString *)key request_id:(EMTLCacheRequestIdentifier)request_id;

@end

@interface EMTLCache : NSObject

{
    NSCache *memoryCache;
    NSMutableDictionary *domainHandlers;
    NSMutableDictionary *requests;
    NSMutableDictionary *accessRecord;
    NSMutableArray *pauseRequests;
    
    BOOL paused;
}


+ (id)cache;
- (void)setObject:(id)object forDomain:(NSString *)domain key:(NSString *)key;

// Methods for EMTLCacheClients
- (EMTLCacheRequestIdentifier)getObjectForDomain:(NSString *)domain key:(NSString *)key toTarget:(id <EMTLCacheClient>)target;
- (EMTLCacheRequestIdentifier)getObjectForDomain:(NSString *)domain key:(NSString *)key toTarget:(id <EMTLCacheClient>)target withHandler:(id <EMTLCacheHandler>)handler;
- (EMTLCacheRequestIdentifier)getObjectForDomain:(NSString *)domain key:(NSString *)key toTarget:(id <EMTLCacheClient>)target withPostProcessor:(id <EMTLCachePostProcessor>)processor;
- (EMTLCacheRequestIdentifier)getObjectForDomain:(NSString *)domain key:(NSString *)key toTarget:(id <EMTLCacheClient>)target withHandler:(id <EMTLCacheHandler>)handler withPostProcessor:(id <EMTLCachePostProcessor>)processor;
- (void)cancelRequest:(EMTLCacheRequestIdentifier)request_identifier;

// Methods for EMTLCacheHandlers and EMTLCachePostProcessors
- (void)setHandler:(id <EMTLCacheHandler>)handler forDomain:(NSString *)domain;
- (void)setPostProcessor:(id <EMTLCachePostProcessor>)processor forDomain:(NSString *)domain;
- (void)fetchedObject:(id)object forDomain:(NSString *)domain key:(NSString *)key request_id:(EMTLCacheRequestIdentifier)request_id;
- (void)fetchedBytes:(int)bytes ofTotal:(int)total forDomain:(NSString *)domain key:(NSString *)key request_id:(EMTLCacheRequestIdentifier)request_id;
- (void)unableToFetchObjectForDomain:(NSString *)domain key:(NSString *)key request_id:(EMTLCacheRequestIdentifier)request_id;

// Methods for UI Controllers
- (void)requestPause:(id)object;
- (void)requestResume:(id)object;

@end

@interface EMTLCachedObject : NSObject

@property (nonatomic, strong) id object;
@property (nonatomic, strong) NSDate *date_created;

@end
