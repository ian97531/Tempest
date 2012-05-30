//
//  EMTLPhotoList.m
//  Tempest
//
//  Created by Ian White on 5/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EMTLPhotoQuery.h"

@implementation EMTLPhotoQuery

@synthesize photoQueryID = _photoQueryID;
@synthesize queryType = _queryType;
@synthesize delegate = _delegate;
@synthesize queryArguments = _queryArguments;
@synthesize photoList = _photoList;
@synthesize source = _source;

- (id)initWithQueryID:(NSString *)queryID queryType:(EMTLPhotoQueryType)queryType arguments:(NSDictionary *)arguments source:(EMTLPhotoSource *)source;
{
    self = [super init];
    if (self != nil)
    {
        NSLog(@"query type: %i", queryType);
        _photoQueryID = [queryID copy];
        _queryType = queryType;
        _queryArguments = [arguments copy];
        _blankQueryArguments = [arguments copy];
        _source = source;
        _photoList = [NSMutableArray array];
    }
    
    return self;
}

- (void)photoSource:(EMTLPhotoSource *)source fetchedPhotos:(NSArray *)photos updatedQuery:(NSDictionary *)query;
{
    _queryArguments = query;
    
    // We should be gracefully merging the new photos in here.
    [_photoList addObjectsFromArray:photos];
    
    [_delegate photoSource:source didUpdatePhotoQuery:self];
    
}

- (void)photoSourceWillFetchPhotos:(EMTLPhotoSource *)source
{
    [_delegate photoSource:source willUpdatePhotoQuery:self];
}

- (void)photoSource:(EMTLPhotoSource *)source isFetchingPhotosWithProgress:(float)progress
{
    [_delegate photoSource:source isUpdatingPhotoQuery:self progress:progress];
}

- (void)morePhotos
{
    [_source updateQuery:self];
}

- (void)reloadPhotos
{
    _queryArguments = [_blankQueryArguments copy];
    _photoList = [NSArray array];
    [_source updateQuery:self];
}

- (NSArray *)photoList
{
    NSArray *photoList = [_photoList copy];
    return photoList;
}

@end
