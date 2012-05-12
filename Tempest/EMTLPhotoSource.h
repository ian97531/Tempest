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

@class EMTLPhoto;
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


// Authorization Callbacks
@protocol EMTLAuthorizationDelegate
- (void)photoSource:(EMTLPhotoSource *)photoSource requiresAuthorizationAtURL:(NSURL *)url;
- (void)authorizationCompleteForPhotoSource:(EMTLPhotoSource *)photoSource;
- (void)authorizationFailedForPhotoSource:(EMTLPhotoSource *)photoSource authorizationError:(NSError *)error;
@end

// Photo queries
typedef enum EMTLPhotoQueryType {
    EMTLPhotoQueryTimeline,
    EMTLPhotoQueryFavorites,
    EMTLPhotoQueryUserPhotos,
    EMTLPhotoQueryPopularPhotos,
} EMTLPhotoQueryType;

@protocol EMTLPhotoQueryDelegate
- (void)photoSource:(EMTLPhotoSource *)photoSource willUpdateQuery:(NSString *)queryID;
- (void)photosource:(EMTLPhotoSource *)photoSource didUpdateQuery:(NSString *)queryID;
- (void)photoSource:(EMTLPhotoSource *)photoSource willChangePhoto:(EMTLPhoto *)photo;
- (void)photoSource:(EMTLPhotoSource *)photoSource didChangePhoto:(EMTLPhoto *)photo;
@end

// Image loading
typedef enum EMTLImageSize {
    EMTLImageSizeSmallSquare = 10,
    EMTLImageSizeMediumSquare = 20,
    EMTLImageSizeSmallAspect = 30,
    EMTLImageSizeMediumAspect = 40,
    EMTLImageSizeLargeAspect = 50,
    EMTLImageSizeLargestAvailable = 60,
} EMTLImageSize;

@protocol EMTLImageDelegate
- (void)photoSource:(EMTLPhotoSource *)photoSource willRequestImageForPhoto:(EMTLPhoto *)photo size:(EMTLImageSize)size;
- (void)photosource:(EMTLPhotoSource *)photoSource didRequestImageForPhoto:(EMTLPhoto *)photo size:(EMTLImageSize)size progress:(float)progress;
- (void)photoSource:(EMTLPhotoSource *)photoSource didLoadImageForPhoto:(EMTLPhoto *)photo size:(EMTLImageSize)size image:(UIImage *)image;

@end


@interface EMTLPhotoSource : NSObject
{
    NSOperationQueue *operationQueue;
    NSCache *imageCache;
    NSString *diskCachePath;
    NSArray *diskCachePhotos;
}

@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) NSString *username;

// Photo Query
- (NSString *)addPhotoQueryType:(EMTLPhotoQueryType)queryType withArguments:(NSDictionary *)queryArguments queryDelegate:(id<EMTLPhotoQueryDelegate>)queryDelegate;
- (NSArray *)photoListForQuery:(NSString *)queryID;
- (void)removeQuery:(NSString *)queryID;
- (void)reloadQuery:(NSString *)queryID;
- (void)updateQuery:(NSString *)queryID;

// Authorization
@property (nonatomic, assign) id <EMTLAuthorizationDelegate> accountManager;
- (void)authorize;
- (void)authorizedWithVerifier:(NSString *)verfier;

// Image Loading
- (UIImage *)loadImageForPhoto:(EMTLPhoto *)photo size:(EMTLImageSize)size imageDelegate:(id<EMTLImageDelegate>)imageDelegate;
- (void)cancelAllImagesForPhoto:(EMTLPhoto *)photo;
- (void)cancelLoadImageForPhoto:(EMTLPhoto *)photo size:(EMTLImageSize)size;

@end
