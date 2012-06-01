//
//  EMTLPhotoList.h
//  Tempest
//
//  Created by Ian White on 5/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMTLPhotoSource.h"

@class EMTLPhotoQuery;

@protocol EMTLPhotoQueryDelegate <NSObject>

- (void)photoQueryWillUpdate:(EMTLPhotoQuery *)query;
- (void)photoQueryDidUpdate:(EMTLPhotoQuery *)query;
- (void)photoQueryIsUpdating:(EMTLPhotoQuery *)query progress:(float)progress;
- (void)photoQueryFinishedUpdating:(EMTLPhotoQuery *)query;

@end

@interface EMTLPhotoQuery : NSObject
{
    
    @private
    NSString *_photoQueryID;
    EMTLPhotoQueryType _queryType;
    NSDictionary *_queryArguments;
    NSDictionary *_blankQueryArguments;
    __weak id<EMTLPhotoQueryDelegate> _delegate;
    EMTLPhotoSource * _source;
    BOOL _reloading;
    int _totalPhotos;
    int _numPhotosExpected;
    int _numPhotosReceived;
    
    @protected
    NSMutableArray *_photoList; // BSEELY: Not actually sure this has to be mutable. 
}

@property (nonatomic, readonly, copy) NSArray *photoList;
@property (nonatomic, strong, readonly) EMTLPhotoSource * source;
@property (nonatomic, readonly) int totalPhotos;

@property (nonatomic, readonly) NSString *photoQueryID;
@property (nonatomic, readonly) EMTLPhotoQueryType queryType;
@property (nonatomic, strong) NSDictionary *queryArguments;
@property (nonatomic, strong) NSDictionary *blankQueryArguments;
@property (nonatomic, weak) id<EMTLPhotoQueryDelegate> delegate;

- (id)initWithQueryID:(NSString *)queryID queryType:(EMTLPhotoQueryType)queryType arguments:(NSDictionary *)arguments source:(EMTLPhotoSource *)source cachedPhotos:(NSArray *)photos;
- (void)photoSource:(EMTLPhotoSource *)source fetchedPhotos:(NSArray *)photos totalPhotos:(int)total;
- (void)photoSource:(EMTLPhotoSource *)source finishedFetchingPhotosWithUpdatedArguments:(NSDictionary *)arguments;
- (void)photoSourceWillFetchPhotos:(EMTLPhotoSource *)source;
- (void)photoSource:(EMTLPhotoSource *)source isFetchingPhotosWithProgress:(float)progress;
- (void)morePhotos;
- (void)reloadPhotos;


@end
