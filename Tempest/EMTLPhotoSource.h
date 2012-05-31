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
#import "APISecrets.h"
#import "EMTLConstants.h"


extern NSString *const kPhotoUsername;
extern NSString *const kPhotoUserID;
extern NSString *const kPhotoTitle;
extern NSString *const kPhotoID;
extern NSString *const kPhotoImageURL;
extern NSString *const kPhotoImageAspectRatio;
extern NSString *const kPhotoDatePosted;
extern NSString *const kPhotoDateUpdated;

extern NSString *const kCommentText;
extern NSString *const kCommentDate;
extern NSString *const kCommentUsername;
extern NSString *const kCommentUserID;
extern NSString *const kCommentIconURL;

extern NSString *const kFavoriteDate;
extern NSString *const kFavoriteUsername;
extern NSString *const kFavoriteUserID;
extern NSString *const kFavoriteIconURL;

@protocol EMTLImageDelegate;
@class EMTLPhotoSource;
@class EMTLPhotoQuery;
@class EMTLPhoto;
@class EMTLPhotoAssets;

@protocol EMTLPhotoSourceAuthorizationDelegate
- (void)photoSource:(EMTLPhotoSource *)photoSource requiresAuthorizationAtURL:(NSURL *)url;
- (void)authorizationCompleteForPhotoSource:(EMTLPhotoSource *)photoSource;
- (void)authorizationFailedForPhotoSource:(EMTLPhotoSource *)photoSource authorizationError:(NSError *)error;
@end

@interface EMTLPhotoSource : NSObject
{
    @private
    __weak id<EMTLPhotoSourceAuthorizationDelegate> _authorizationDelegate;
    NSMutableDictionary *_photoQueries;
    
    
    @protected
    NSMutableDictionary *_imageCache;
    NSString *_serviceName;
    NSString *_username;
    NSString *_userID;
    
}

@property (nonatomic, readonly) NSString *serviceName;
@property (nonatomic, readonly) NSString *userID;
@property (nonatomic, readonly) NSString *username;


// Authorization
@property (nonatomic, weak) id <EMTLPhotoSourceAuthorizationDelegate> authorizationDelegate;
- (void)authorize;
- (void)authorizedWithVerifier:(NSString *)verfier;

// Photo Queries 
- (EMTLPhotoQuery *)currentPhotos;
- (EMTLPhotoQuery *)popularPhotos;
- (EMTLPhotoQuery *)favoritePhotosForUser:(NSString *)user_id;
- (EMTLPhotoQuery *)photosForUser:(NSString *)user_id;
- (EMTLPhotoQuery *)addPhotoQueryType:(EMTLPhotoQueryType)queryType withArguments:(NSDictionary *)queryArguments;
- (void)updateQuery:(EMTLPhotoQuery *)query;
- (void)cancelQuery:(EMTLPhotoQuery *)query;

// Photo Image Loading
- (UIImage *)imageForPhoto:(EMTLPhoto *)photo size:(EMTLImageSize)size;
- (void)cancelImageForPhoto:(EMTLPhoto *)photo size:(EMTLImageSize)size;

@end

