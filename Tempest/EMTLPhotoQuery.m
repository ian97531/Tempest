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
@synthesize blankQueryArguments = _blankQueryArguments;
@synthesize photoList = _photoList;
@synthesize source = _source;
@synthesize totalPhotos = _totalPhotos;

- (id)initWithQueryID:(NSString *)queryID queryType:(EMTLPhotoQueryType)queryType arguments:(NSDictionary *)arguments source:(EMTLPhotoSource *)source cachedPhotos:(NSArray *)photos
{
    self = [super init];
    if (self != nil)
    {
        NSLog(@"query type: %@", queryID);
        _photoQueryID = [queryID copy];
        _queryType = queryType;
        _queryArguments = [arguments copy];
        _blankQueryArguments = [arguments copy];
        _source = source;
        _reloading = NO;
        _totalPhotos = 0;
        _numPhotosExpected = 0;
        _numPhotosReceived = 0;
        
        if (photos) {
            NSLog(@"Got cached photos in the photo query");
            _photoList = [NSMutableArray arrayWithArray:photos];
            
        }
        else {
            _photoList = [NSMutableArray array];
        }
        
    }
    
    return self;
}

- (void)photoSource:(EMTLPhotoSource *)source fetchedPhotos:(NSArray *)photos totalPhotos:(int)total;
{
    if (_reloading) {
        // If we're reloading, we want to dump the existing array of photos.
        _photoList = [NSMutableArray array];
        _reloading = NO;
    }
    
    _numPhotosExpected = total;
    _numPhotosReceived += photos.count;
    
    // We should be gracefully merging the new photos in here.
    [_photoList addObjectsFromArray:photos];
    
    [_delegate photoQueryDidUpdate:self];
}

-(void)photoSource:(EMTLPhotoSource *)source finishedFetchingPhotosWithUpdatedArguments:(NSDictionary *)arguments
{
    NSLog(@"New Query: %@", [arguments description]);

    _queryArguments = arguments;
    _numPhotosExpected = 0;
    _numPhotosReceived = 0;
    [_delegate photoQueryFinishedUpdating:self];
}

- (void)photoSourceWillFetchPhotos:(EMTLPhotoSource *)source
{
    [_delegate photoQueryWillUpdate:self];
}

- (void)photoSource:(EMTLPhotoSource *)source isFetchingPhotosWithProgress:(float)progress
{
    [_delegate photoQueryIsUpdating:self progress:progress];
}

- (void)morePhotos
{
    [_source updateQuery:self];
}

- (void)reloadPhotos
{
    _reloading = YES;
    [_source cancelQuery:self];
    _numPhotosExpected = 0;
    _numPhotosReceived = 0;
    _queryArguments = [_blankQueryArguments copy];
    
    [_source updateQuery:self];
}

- (NSArray *)photoList
{
    NSArray *photoList = [_photoList copy];
    return photoList;
}

- (int)totalPhotos
{
    return _photoList.count + (_numPhotosExpected - _numPhotosReceived);
}

@end