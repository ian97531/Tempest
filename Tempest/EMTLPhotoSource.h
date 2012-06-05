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
#import "EMTLUser.h"

extern NSString *const kPhotoObject;

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
extern NSString *const kPhotoIsFavorite;
extern NSString *const kPhotoLocation;

extern NSString *const kCommentText;
extern NSString *const kCommentDate;
extern NSString *const kCommentUser;

extern NSString *const kFavoriteDate;
extern NSString *const kFavoriteUser;

extern int const kImageCacheCapacity;
extern NSString *const kImageCacheFilesDatesDict;
extern NSString *const kUserCacheDict;

@protocol EMTLImageDelegate;
@class EMTLPhotoSource;
@class EMTLPhotoQuery;
@class EMTLPhoto;
@class EMTLPhotoAssets;
@class EMTLUser;

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
    NSCache *_imageCache;
    
    NSString *_photoListCacheDir;
    NSMutableDictionary *_photoListCacheDates;
    
    NSString *_imageCacheDir;
    NSMutableArray *_imageCacheSortedRefs;
    dispatch_queue_t _imageCacheQueue;
    NSString *_imageCacheIndexPath;
    
    NSDictionary *_userCache;
    NSString *_userCacheDir;
    
    @protected
    
    NSString *_serviceName;
    EMTLUser *_user;
    
}

@property (nonatomic, readonly) NSString *serviceName;
@property (nonatomic, readonly) EMTLUser *user;


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

// Setting Photo Status
- (void)setFavoriteStatus:(BOOL)isFavorite forPhoto:(EMTLPhoto *)photo;

// Users
- (EMTLUser *)userForUserID:(NSString *)userID;
- (void)loadUser:(EMTLUser *)user withUserID:(NSString *)userID;

@end

