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
    EMTLPhotoQueryPhotoAssets,
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


@interface EMTLConstants : NSObject

@end
