//
//  EMTLPhoto.h
//  Tempest
//
//  Created by Ian White on 5/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
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

@class EMTLPhotoAssets;
@class EMTLOperation;
@class EMTLPhoto;


@protocol EMTLPhotoDelegate <NSObject>

- (void)photo:(EMTLPhoto *)photo willRequestAssets:(EMTLPhotoAssets *)assets withImageSize:(EMTLImageSize)size;
- (void)photo:(EMTLPhoto *)photo didRequestAssets:(EMTLPhotoAssets *)assets withImageSize:(EMTLImageSize)size progress:(float)progress;
- (void)photo:(EMTLPhoto *)photo didLoadAssets:(EMTLPhotoAssets *)assets withImageSize:(EMTLImageSize)size;

@end


@interface EMTLPhoto : NSObject <NSDiscardableContent>

{
@private
    NSMutableArray *_assetOperations;
    EMTLPhotoAssets *_assets;
    __weak id<EMTLPhotoDelegate> _delegate;
}

@property (nonatomic, strong, readonly) NSURL *imageURL;
@property (nonatomic, strong, readonly) NSString *title;
@property (nonatomic, strong, readonly) NSString *userID;
@property (nonatomic, strong, readonly) NSString *username;
@property (nonatomic, strong, readonly) NSDate *datePosted;
@property (nonatomic, strong, readonly) NSDate *dateUpdated;
@property (nonatomic, strong, readonly) NSString *photoID;
@property (nonatomic, strong, readonly) NSNumber *aspectRatio;
@property (nonatomic, strong, readonly) NSString *imageDomain;
@property (nonatomic, strong, readonly) NSString *favoritesShortString;
@property (nonatomic, strong, readonly) NSString *datePostedString;
@property (nonatomic, readonly) BOOL isFavorite;

@property (nonatomic, assign) id<EMTLPhotoSource> source;


+ (id)photoWithDict:(NSDictionary *)dict;
- (id)initWithDict:(NSDictionary *)dict;

- (EMTLPhotoAssets *)loadAssetsForPhoto:(EMTLPhoto *)photo imageSize:(EMTLImageSize)size assetDelegate:(id<EMTLPhotoDelegate>)assetDelegate;
- (void)cancelAllAssetsForPhoto:(EMTLPhoto *)photo;
- (void)cancelLoadAssetsForPhoto:(EMTLPhoto *)photo imageSize:(EMTLImageSize)size;

- (NSString *)datePostedString;


@end


@end
