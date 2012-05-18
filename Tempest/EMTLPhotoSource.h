//
//  EMTLPhotoSource.h
//  Tempest
//
//  Created by Ian White on 5/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OAConsumer.h"
#import "OAToken.h"
#import "OAServiceTicket.h"
#import "OADataFetcher.h"
#import "OAMutableURLRequest.h"
#import "EMTLPhoto.h"

@protocol EMTLPhotoSource;
@class EMTLPhotoList;
@class EMTLPhoto;
@class EMTLPhotoAssets;

@protocol EMTLPhotoSourceAuthorizationDelegate
- (void)photoSource:(id<EMTLPhotoSource>)photoSource requiresAuthorizationAtURL:(NSURL *)url;
- (void)authorizationCompleteForPhotoSource:(id<EMTLPhotoSource>)photoSource;
- (void)authorizationFailedForPhotoSource:(id<EMTLPhotoSource>)photoSource authorizationError:(NSError *)error;
@end

@protocol EMTLPhotoSource <NSObject>

@property (nonatomic, readonly) NSString *serviceName;
@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) NSString *username;


// Authorization
@property (nonatomic, weak) id <EMTLPhotoSourceAuthorizationDelegate> authorizationDelegate;
- (void)authorize;
- (void)authorizedWithVerifier:(NSString *)verfier;

// Photo List Loading
- (EMTLPhotoList *)currentPhotos;
- (EMTLPhotoList *)popularPhotos;
- (EMTLPhotoList *)favoritePhotosForUser:(NSString *)user_id;
- (EMTLPhotoList *)photosForUser:(NSString *)user_id;
- (void)fetchPhotosForPhotoList:(EMTLPhotoList *)photoList;

// Photo Asset Loading
- (EMTLPhotoAssets *)assetsForPhoto:(EMTLPhoto *)photo;

@end

