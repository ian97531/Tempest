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


@protocol EMTLPhotoSourceAuthorizationDelegate
- (void)photoSource:(EMTLPhotoSource *)photoSource requiresAuthorizationAtURL:(NSURL *)url;
- (void)authorizationCompleteForPhotoSource:(EMTLPhotoSource *)photoSource;
- (void)authorizationFailedForPhotoSource:(EMTLPhotoSource *)photoSource authorizationError:(NSError *)error;
@end

@protocol EMTLPhotoQueryDelegate
- (void)photoSource:(EMTLPhotoSource *)photoSource willUpdateQuery:(NSString *)queryID;
- (void)photosource:(EMTLPhotoSource *)photoSource didUpdateQuery:(NSString *)queryID;
- (void)photoSource:(EMTLPhotoSource *)photoSource willChangePhoto:(EMTLPhoto *)photo;
- (void)photoSource:(EMTLPhotoSource *)photoSource didChangePhoto:(EMTLPhoto *)photo;
@end

@protocol EMTLImageDelegate
- (void)photoSource:(EMTLPhotoSource *)photoSource willRequestImageForPhoto:(EMTLPhoto *)photo size:(EMTLImageSize)size;
- (void)photosource:(EMTLPhotoSource *)photoSource didRequestImageForPhoto:(EMTLPhoto *)photo size:(EMTLImageSize)size progress:(float)progress;
- (void)photoSource:(EMTLPhotoSource *)photoSource didLoadImageForPhoto:(EMTLPhoto *)photo size:(EMTLImageSize)size image:(UIImage *)image;

@end

@interface EMTLPhotoSource : NSObject
{
    @private
    __weak id<EMTLPhotoSourceAuthorizationDelegate> _authorizationDelegate;
    NSMutableDictionary *_photoQueries;
}

@property (nonatomic, readonly) NSString *serviceName;
@property (nonatomic, readonly) NSSet *queries;

@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) NSString *username;


// Authorization
@property (nonatomic, weak) id <EMTLPhotoSourceAuthorizationDelegate> authorizationDelegate;
- (void)authorize;
- (void)authorizedWithVerifier:(NSString *)verfier;

// Photo Query
- (NSString *)addPhotoQueryType:(EMTLPhotoQueryType)queryType withArguments:(NSDictionary *)queryArguments queryDelegate:(id<EMTLPhotoQueryDelegate>)queryDelegate;
- (NSArray *)photoListForQuery:(NSString *)queryID;
- (void)removeQuery:(NSString *)queryID;
- (void)reloadQuery:(NSString *)queryID;
- (void)updateQuery:(NSString *)queryID;

// Image Loading
- (UIImage *)loadImageForPhoto:(EMTLPhoto *)photo size:(EMTLImageSize)size imageDelegate:(id<EMTLImageDelegate>)imageDelegate;
- (void)cancelAllImagesForPhoto:(EMTLPhoto *)photo;
- (void)cancelLoadImageForPhoto:(EMTLPhoto *)photo size:(EMTLImageSize)size;

@end
