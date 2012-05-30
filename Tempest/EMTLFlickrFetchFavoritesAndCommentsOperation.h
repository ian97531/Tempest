//
//  EMTLFetchFavoritesAndCommentsOperation.h
//  Tempest
//
//  Created by Ian White on 5/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EMTLPhoto;
@class EMTLFlickrPhotoSource;

@interface EMTLFlickrFetchFavoritesAndCommentsOperation : NSOperation
{
    @private
    int _favoritesPages;
    int _favoritesCurrentPage;
    NSMutableArray *_favorites;
    NSMutableArray *_comments;

    BOOL _executing;
    BOOL _finished;
    EMTLPhoto *_photo;
    EMTLFlickrPhotoSource *_photoSource;
}

- (id)initWithPhoto:(EMTLPhoto *)photo photoSource:(EMTLFlickrPhotoSource *)source;

- (void)start;
- (BOOL)isConcurrent;
- (BOOL)isExecuting;
- (BOOL)isFinished;

@end
