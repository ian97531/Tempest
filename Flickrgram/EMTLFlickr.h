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
@property (readonly, nonatomic) NSURL *authorizationURL;

@property (readonly, strong) NSString *user_id;
@property (readonly, strong) NSString *username;
@property (readonly) BOOL expired;
@property (nonatomic, strong) NSMutableDictionary *requests;

- (void)authorize;
- (void)authorizedWithVerifier:(NSString *)verfier;

- (void)requestTokenTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data;
- (void)requestTokenTicket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error;
- (void)accessTokenTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data;
- (void)accessTokenTicket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error;

- (void)callMethod:(NSString *)method didFinishSelector:(SEL)finishSelector didFailSelector:(SEL)failSelector;
- (void)callMethod:(NSString *)method withArguments:(NSDictionary *)args didFinishSelector:(SEL)finishSelector didFailSelector:(SEL)failSelector;
- (void)callMethod:(NSString *)method delegate:(id)delegate didFinishSelector:(SEL)finishSelector didFailSelector:(SEL)failSelector;
- (void)callMethod:(NSString *)method withArguments:(NSDictionary *)args delegate:(id)delegate didFinishSelector:(SEL)finishSelector didFailSelector:(SEL)failSelector;

- (void)testLoginFinished:(OAServiceTicket *)ticket withData:(NSData *)data;
- (void)testLoginFailed:(OAServiceTicket *)ticket withData:(NSError *)error;

- (void)morePhotos;
- (void)morePhotos:(int)num;
- (void)moarPhotos:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data;
- (void)moarPhotos:(OAServiceTicket *)ticket didFailWithError:(NSError *)data;

- (void)getPhotoFavorites:(NSString *)photo_id delegate:(id)delegate didFinishSelector:(SEL)finishSelector didFailSelector:(SEL)failSelector;
- (void)getPhotoFavorites:(NSString *)photo_id page:(int)page delegate:(id)delegate didFinishSelector:(SEL)finishSelector didFailSelector:(SEL)failSelector;;
- (void)getPhotoComments:(NSString *)photo_id delegate:(id)delegate didFinishSelector:(SEL)finishSelector didFailSelector:(SEL)failSelector;

- (NSURL *)defaultUserIconURL;
- (NSArray *)extractComments:(NSData *)data;
- (NSArray *)extractFavorites:(NSData *)data;

- (NSDictionary *)extractJSONFromData:(NSData *)data withError:(NSError **) error;

// EMTLCacheHandler methods
- (void)fetchObjectForRequest:(EMTLCacheRequest *)request;
- (void)cancelRequest:(EMTLCacheRequest *)request;

// EMTLCachePostProcessor method
- (id)processObject:(id)object forRequest:(EMTLCacheRequest *)request;

@end
