//
//  EMTLPhotoList.m
//  Tempest
//
//  Created by Ian White on 5/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EMTLPhotoList.h"

@implementation EMTLPhotoList

@synthesize photos = _photos;
@synthesize source = _source;
@synthesize query = _query;
@synthesize delegate = _delegate;

- (id)initWithPhotoSource:(id<EMTLPhotoSource>)source query:(NSDictionary *)query cachedPhotos:(NSArray *)photos
{
    NSAssert(source, @"You must provide a photo source when instantiating an EMTLPhotoSource");
    NSAssert(query, @"You must provide a query dictionary when instantiating an EMTLPhotoList");
    
    self = [super init];
    if (self) 
    {
        _source = source;
        _blankQuery = query;
        _query = [_blankQuery copy];
        _photos = photos;
        
        if (!photos) {
            _photos = [NSArray array];
        }
        
    }
    
    return self;
}

- (void)photoSource:(id<EMTLPhotoSource>)source fetchedPhotos:(NSArray *)photos updatedQuery:(NSDictionary *)query;
{
    _query = query;
    
    // We should be gracefully merging the new photos in here.
    _photos = photos;
    
    [_delegate photoListDidUpdate:self];
    
}

- (void)photoSourceWillFetchPhotos:(id<EMTLPhotoSource>)source
{
    [_delegate photoListDidUpdate:self];
}

- (void)photoSource:(id<EMTLPhotoSource>)source isFetchingPhotosWithProgress:(float)progress
{
    [_delegate photoList:self isUpdatingWithProgress:progress];
}

- (void)morePhotos
{
    [_source fetchPhotosForPhotoList:self];
}

- (void)reloadPhotos
{
    _photos = [NSArray array];
    _query = [_blankQuery copy];
    [_source fetchPhotosForPhotoList:self];
}

@end
