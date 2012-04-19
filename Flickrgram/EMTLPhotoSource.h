//
//  EMTLPhotoSource.h
//  Flickrgram
//
//  Created by Ian White on 4/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OAConsumer.h"
#import "OAToken.h"
#import "OAServiceTicket.h"
#import "OADataFetcher.h"
#import "OAMutableURLRequest.h"

@protocol PhotoSource;

@protocol Authorizable <NSObject>

- (void)photoSource:(id <PhotoSource>)photoSource authorizationError:(NSError *)error;
- (void)photoSource:(id <PhotoSource>)photoSource requiresAuthorizationAtURL:(NSURL *)url;
- (void)authorizationCompleteForSource:(id <PhotoSource>)photoSource;

@end

@protocol PhotoConsumer <NSObject>

- (void)photoSource:(id <PhotoSource>)photoSource addedPhotosToArray:(NSArray *)photoArray atIndex:(int)index;
- (void)photoSource:(id <PhotoSource>)photoSource encounteredAnError:(NSError *)error;

@end

    
@protocol PhotoSource <NSObject>

@property (nonatomic, assign) id <Authorizable> delegate;
@property (nonatomic, assign) id <PhotoConsumer> photoDelegate;
@property (readonly, nonatomic, strong) NSString *key;
@property (readonly, nonatomic) NSURL *authorizationURL;

@property (readonly, strong) NSString *user_id;
@property (readonly, strong) NSString *username;
@property (readonly, strong) NSMutableArray *photos;
@property (readonly) BOOL expired;

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

- (void)morePhotos;
- (void)morePhotos:(int)num;



@end
