//
//  EMTLConstants.h
//  Tempest
//
//  Created by Blake Seely on 5/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum EMTLPhotoQueryType {
    EMTLPhotoQueryTimeline = 1,
    EMTLPhotoQueryFavorites,
    EMTLPhotoQueryUserPhotos,
    EMTLPhotoQueryPopularPhotos,
    EMTLPhotoQueryTypeUndefined, // Add new types above this
} EMTLPhotoQueryType;


typedef enum EMTLImageSize {
    EMTLImageSizeSmallSquare = 10,
    EMTLImageSizeMediumSquare = 20,
    EMTLImageSizeSmallAspect = 30,
    EMTLImageSizeMediumAspect = 40,
    EMTLImageSizeLargeAspect = 50,
    EMTLImageSizeLargestAvailable = 60,
    EMTLImageSizeUndefined, // Add new types above this
} EMTLImageSize;


typedef enum EMTLLocationType {
    EMTLLocationNeighbourhood = 1,
    EMTLLocationLocality,
    EMTLLocationCountry,
    EMTLLocationUndefined, // Add new types above this
} EMTLLocationType;


typedef enum EMTLPhotoLicenseType {
    EMTLPhotoLicenseAttributionNonCommercialShareALike = 1,
    EMTLPhotoLicenseAttributionNonCommercial,
    EMTLPhotoLicenseAttributionNonCommercialNoDerivatives,
    EMTLPhotoLicenseAttributionLicense,
    EMTLPhotoLicenseAttributionShareALike,
    EMTLPhotoLicenseAttributionNoDerivatives,
    EMTLPhotoLicenseNoRestriction,
    EMTLPhotoLicenseUndefined, // Add new types above this
} EMTLPhotoLicenseType;

extern double const kSecondsInThreeMonths;

extern NSString *const EMTLPhotoObject;

extern NSString *const EMTLPhotoUser;
extern NSString *const EMTLPhotoUserID;
extern NSString *const EMTLPhotoTitle;
extern NSString *const EMTLPhotoID;
extern NSString *const EMTLPhotoImageURL;
extern NSString *const EMTLPhotoImageAspectRatio;
extern NSString *const EMTLPhotoDatePosted;
extern NSString *const EMTLPhotoDateUpdated;
extern NSString *const EMTLPhotoDateTaken;
extern NSString *const EMTLPhotoComments;
extern NSString *const EMTLPhotoFavorites;
extern NSString *const EMTLPhotoIsFavorite;
extern NSString *const EMTLPhotoLocation;
extern NSString *const EMTLPhotoDescription;
extern NSString *const EMTLPhotoWebPageURL;
extern NSString *const EMTLPhotoTags;
extern NSString *const EMTLPhotoLicense;

extern NSString *const EMTLCommentText;
extern NSString *const EMTLCommentDate;
extern NSString *const EMTLCommentUser;

extern NSString *const EMTLFavoriteDate;
extern NSString *const EMTLFavoriteUser;

extern NSString *const EMTLImageCacheFilesDatesDict;
extern NSString *const EMTLUserCacheDict;

extern int const EMTLImageCacheCapacity;
extern int const EMTLImageCacheLeeway;


@interface EMTLConstants : NSObject

@end
