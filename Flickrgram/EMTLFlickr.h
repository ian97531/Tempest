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
    OAToken *token;
}

@property (nonatomic, assign) id <Authorizable> delegate;
@property (readonly, nonatomic, strong) NSString *key;

- (void)authorize;
- (void)authorizedWithVerifier:(NSString *)verfier;

- (void)requestTokenTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data;
- (void)requestTokenTicket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error;
- (void)accessTokenTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data;
- (void)accessTokenTicket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error;

- (NSArray *)getMorePhotos;
- (NSArray *)getMorePhotos:(int)num;


@end
