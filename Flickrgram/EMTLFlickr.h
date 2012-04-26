//
//  EMTLFlickr.h
//  Flickrgram
//
//  Created by Ian White on 4/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMTLPhotoSource.h"
#import "EMTLCache.h"

@class EMTLPhoto;

@interface EMTLFlickr : NSObject <PhotoSource, EMTLCacheHandler, EMTLCachePostProcessor>

{
    int currentPage;
    int totalPages;
    
    int maxYear;
    int maxMonth;
    int maxDay;
    
    int minYear;
    int minMonth;
    int minDay;
    
    OAConsumer *consumer;
    OAToken *requestToken;
    OAToken *accessToken;
    
    BOOL loading;
}

@property (nonatomic, assign) id <Authorizable> delegate;
@property (nonatomic, assign) id <PhotoConsumer> photoDelegate;

@property (readonly, nonatomic, strong) NSString *key;
@property (readonly, strong) NSString *user_id;
@property (readonly, strong) NSString *username;

- (void)authorize;
- (void)authorizedWithVerifier:(NSString *)verfier;
- (void)morePhotos;

// EMTLCacheHandler methods
- (NSURLRequest *)urlRequestForRequest:(EMTLCacheRequest *)request;

// EMTLCachePostProcessor method
- (id)processData:(NSData *)data forRequest:(EMTLCacheRequest *)request;

@end
