//
//  EMTLPhotoSource.h
//  Flickrgram
//
//  Created by Ian White on 4/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "EMTLConstants.h"
#import "OAConsumer.h"
#import "OAToken.h"
#import "OAServiceTicket.h"
#import "OADataFetcher.h"
#import "OAMutableURLRequest.h"

@class EMTLPhoto;
@class EMTLPhotoList;
@class EMTLPhotoSource;

extern NSString *const kPhotoUsername;
extern NSString *const kPhotoUserID;
extern NSString *const kPhotoTitle;
extern NSString *const kPhotoID;
extern NSString *const kPhotoImageURL;
extern NSString *const kPhotoImageAspectRatio;
extern NSString *const kPhotoDatePosted;
extern NSString *const kPhotoDateUpdated;
extern NSString *const kPhotoComments;
extern NSString *const kPhotoFavorites;

extern NSString *const kCommentText;
extern NSString *const kCommentDate;
extern NSString *const kCommentUsername;
extern NSString *const kCommentUserID;
extern NSString *const kCommentIconURL;

extern NSString *const kFavoriteDate;
extern NSString *const kFavoriteUsername;
extern NSString *const kFavoriteUserID;
extern NSString *const kFavoriteIconURL;

extern NSString *const kEMTLPhotoImage;
extern NSString *const kEMTLPhotoComments;
extern NSString *const kEMTLPhotoFavorites;


@protocol EMTLPhotoSourceAuthorizationDelegate
- (void)photoSource:(EMTLPhotoSource *)photoSource requiresAuthorizationAtURL:(NSURL *)url;
- (void)authorizationCompleteForPhotoSource:(EMTLPhotoSource *)photoSource;
- (void)authorizationFailedForPhotoSource:(EMTLPhotoSource *)photoSource authorizationError:(NSError *)error;
@end


@interface EMTLPhotoSource : NSObject
{
    @private
    __weak id<EMTLPhotoSourceAuthorizationDelegate> _authorizationDelegate;
    NSMutableDictionary *_photoLists;
}

@property (nonatomic, readonly) NSString *serviceName;
@property (nonatomic, readonly) NSSet *photoLists;

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

@end
