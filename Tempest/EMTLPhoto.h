//
//  EMTLPhoto.h
//  Tempest
//
//  Created by Ian White on 5/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMTLConstants.h"

@class EMTLPhotoSource;
@class EMTLPhoto;
@class EMTLLocation;
@class EMTLUser;


@protocol EMTLImageDelegate <NSObject>

- (void)photo:(EMTLPhoto *)photo willRequestImageWithSize:(EMTLImageSize)size;
- (void)photo:(EMTLPhoto *)photo didRequestImageWithSize:(EMTLImageSize)size progress:(float)progress;
- (void)photo:(EMTLPhoto *)photo didLoadImage:(UIImage *)image withSize:(EMTLImageSize)size;

@end

@protocol EMTLLocationDelegate <NSObject>

- (void)photoWillRequestLocation:(EMTLPhoto *)photo;
- (void)photoDidLoadLocation:(EMTLPhoto *)photo;

@end


@interface EMTLPhoto : NSObject <NSCoding>

{
@private
    __weak id<EMTLImageDelegate> _delegate;
    __weak id<EMTLLocationDelegate> _locationDelegate;
    float _imageProgress;
    EMTLPhotoSource *_source;
    NSArray *_favoritesUsers;
    NSArray *_favorites;
    
    BOOL _updateUsers;
}

@property (nonatomic, strong, readonly) NSString *uniqueID;
@property (nonatomic, strong, readonly) NSURL *imageURL;
@property (nonatomic, strong, readonly) NSURL *webPageURL;
@property (nonatomic, strong, readonly) NSString *title;
@property (nonatomic, strong, readonly) NSString *photoDescription;
@property (nonatomic, strong, readonly) EMTLUser *user;
@property (nonatomic, strong, readonly) NSDate *datePosted;
@property (nonatomic, strong, readonly) NSDate *dateUpdated;
@property (nonatomic, strong, readonly) NSDate *dateTaken;
@property (nonatomic, strong, readonly) NSString *photoID;
@property (nonatomic, strong, readonly) NSNumber *aspectRatio;
@property (nonatomic, strong, readonly) NSString *datePostedString;
@property (nonatomic, strong, readonly) NSArray *tags;
@property (nonatomic, readonly) EMTLPhotoLicenseType license;
@property (nonatomic, strong) NSArray *favorites;
@property (nonatomic, readonly) NSArray *favoritesUsers;
@property (nonatomic, strong) NSArray *comments;
@property (nonatomic, strong) EMTLLocation *location;
@property (nonatomic) BOOL isFavorite;
@property (nonatomic) float imageProgress;

@property (nonatomic, strong) EMTLPhotoSource *source;


+ (id)photoWithSource:(EMTLPhotoSource *)source dict:(NSDictionary *)dict;
- (id)initWithSource:(EMTLPhotoSource *)source dict:(NSDictionary *)dict;
- (NSString *)datePostedString;
- (NSString *)dateTakenString;

// NSCoding Methods
- (id)initWithCoder:(NSCoder *)aDecoder;
- (void)encodeWithCoder:(NSCoder *)aCoder;

// Image Loading methods
- (UIImage *)loadImageWithSize:(EMTLImageSize)size delegate:(id<EMTLImageDelegate>)delegate;
- (void)cancelImageWithSize:(EMTLImageSize)size;
- (void)loadImageLocationWithDelegate:(id<EMTLLocationDelegate>)delegate;

// Set the favorite status
- (void)setFavorite:(BOOL)isFavorite;

// Callbacks for Image loading
- (void)photoSource:(EMTLPhotoSource *)source willRequestImageWithSize:(EMTLImageSize)size;
- (void)photoSource:(EMTLPhotoSource *)source didRequestImageWithSize:(EMTLImageSize)size progress:(float)progress;
- (void)photoSource:(EMTLPhotoSource *)source didLoadImage:(UIImage *)image withSize:(EMTLImageSize)size;

- (void)photoSourceDidLoadLocation:(EMTLPhotoSource *)source;
- (void)photoSourceWillLoadLocation:(EMTLPhotoSource *)source;


@end

