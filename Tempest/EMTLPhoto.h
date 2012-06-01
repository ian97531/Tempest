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


@protocol EMTLImageDelegate <NSObject>

- (void)photo:(EMTLPhoto *)photo willRequestImageWithSize:(EMTLImageSize)size;
- (void)photo:(EMTLPhoto *)photo didRequestImageWithSize:(EMTLImageSize)size progress:(float)progress;
- (void)photo:(EMTLPhoto *)photo didLoadImage:(UIImage *)image withSize:(EMTLImageSize)size;

@end


@interface EMTLPhoto : NSObject <NSCoding>

{
@private
    __weak id<EMTLImageDelegate> _delegate;
    float _imageProgress;
}

@property (nonatomic, strong, readonly) NSString *uniqueID;
@property (nonatomic, strong, readonly) NSURL *imageURL;
@property (nonatomic, strong, readonly) NSString *title;
@property (nonatomic, strong, readonly) NSString *description;
@property (nonatomic, strong, readonly) NSString *userID;
@property (nonatomic, strong, readonly) NSString *username;
@property (nonatomic, strong, readonly) NSDate *datePosted;
@property (nonatomic, strong, readonly) NSDate *dateUpdated;
@property (nonatomic, strong, readonly) NSString *photoID;
@property (nonatomic, strong, readonly) NSNumber *aspectRatio;
@property (nonatomic, strong, readonly) NSString *datePostedString;
@property (nonatomic, strong) NSArray *favorites;
@property (nonatomic, strong) NSArray *comments;
@property (nonatomic, strong) EMTLLocation *location;
@property (nonatomic, readonly) BOOL isFavorite;
@property (nonatomic) float imageProgress;


@property (nonatomic, assign) EMTLPhotoSource *source;


+ (id)photoWithDict:(NSDictionary *)dict;
- (id)initWithDict:(NSDictionary *)dict;

// NSCoding Methods
- (id)initWithCoder:(NSCoder *)aDecoder;
- (void)encodeWithCoder:(NSCoder *)aCoder;

- (UIImage *)loadImageWithSize:(EMTLImageSize)size delegate:(id<EMTLImageDelegate>)delegate;
- (void)cancelImageWithSize:(EMTLImageSize)size;
- (NSString *)datePostedString;

// Callbacks for Image loading
- (void)photoSource:(EMTLPhotoSource *)source willRequestImageWithSize:(EMTLImageSize)size;
- (void)photoSource:(EMTLPhotoSource *)source didRequestImageWithSize:(EMTLImageSize)size progress:(float)progress;
- (void)photoSource:(EMTLPhotoSource *)source didLoadImage:(UIImage *)image withSize:(EMTLImageSize)size;




@end

