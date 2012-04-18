//
//  EMTLFlickr.h
//  Flickrgram
//
//  Created by Ian White on 4/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMTLPhotoSource.h"

@interface EMTLFlickr : NSObject <PhotoSource>

{
    int currentPhoto;
    OAConsumer *consumer;
    OAToken *requestToken;
    OAToken *accessToken;
}

@property (nonatomic, assign) id <Authorizable> delegate;
@property (nonatomic, assign) id <PhotoConsumer> photoDelegate;
@property (readonly, nonatomic, strong) NSString *key;
@property (readonly, nonatomic) NSURL *authorizationURL;

@property (readonly, strong) NSString *user_id;
@property (readonly, strong) NSString *username;
@property (readonly, strong) NSMutableArray *photos;

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

- (NSDictionary *)extractJSON:(NSData *)data fromTicket:(OAServiceTicket *)ticket withError:(NSError **) error;


@end
