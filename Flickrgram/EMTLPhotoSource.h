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

    
@protocol PhotoSource <NSObject>

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
