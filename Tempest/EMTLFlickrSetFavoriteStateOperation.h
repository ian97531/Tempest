//
//  EMTLFlickrSetFavoriteStateOperation.h
//  Tempest
//
//  Created by Ian White on 6/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EMTLFlickrPhotoSource;
@class EMTLPhoto;

@interface EMTLFlickrSetFavoriteStateOperation : NSOperation
{
@private
    BOOL _isFavorite;
    BOOL _executing;
    BOOL _finished;
    EMTLPhoto *_photo;
    EMTLFlickrPhotoSource *_photoSource;
}

- (id)initWithPhoto:(EMTLPhoto *)photo newFavoriteState:(BOOL)isFavorite photoSource:(EMTLFlickrPhotoSource *)photoSource;

- (void)start;
- (BOOL)isConcurrent;
- (BOOL)isExecuting;
- (BOOL)isFinished;

@end
