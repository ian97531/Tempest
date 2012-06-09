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
#import "EMTLLocation.h"


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

@interface EMTLPhotoSource : NSObject <NSCacheDelegate>
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
- (EMTLPhotoQuery *)favoritePhotosForUser:(EMTLUser *)user;
- (EMTLPhotoQuery *)photosForUser:(EMTLUser *)user;
- (EMTLPhotoQuery *)photosForLocation:(EMTLLocation *)location;
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

- (void)cache:(NSCache *)cache willEvictObject:(id)obj;

@end

