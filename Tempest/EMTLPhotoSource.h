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



@protocol EMTLAccountManager <NSObject>

- (void)photoSource:(EMTLPhotoSource *)photoSource requiresAuthorizationAtURL:(NSURL *)url;
- (void)authorizationCompleteForPhotoSource:(EMTLPhotoSource *)photoSource;
- (void)authorizationError:(NSError *)error forPhotoSource:(EMTLPhotoSource *)photoSource;

@end

@protocol EMTLPhotoConsumer <NSObject>

- (void)photoSourceMayChangePhotoList:(EMTLPhotoSource *)photoSource;
- (void)photoSourceMayAddPhotosToPhotoList:(EMTLPhotoSource *)photoSource;
- (void)photoSource:(EMTLPhotoSource *)photoSource didChangePhotoList:(NSDictionary *)changes;
- (void)photoSource:(EMTLPhotoSource *)photoSource didChangePhotosAtIndexPaths:(NSArray *)indexPaths;
- (void)photoSourceDoneChangingPhotoList:(EMTLPhotoSource *)photoSource;

@end

    
@interface EMTLPhotoSource : NSObject
{
    NSOperationQueue *operationQueue;
    NSCache *imageCache;
    NSString *diskCachePath;
    NSArray *diskCachePhotos;
}

@property (nonatomic, assign) id <EMTLAccountManager> accountManager;
@property (nonatomic, assign) id <EMTLPhotoConsumer> delegate;

@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSArray *photoList;

- (void)authorize;
- (void)authorizedWithVerifier:(NSString *)verfier;

- (void)updateNewestPhotos;
- (void)retrieveOlderPhotos;

- (NSString *)serviceName;



@end
