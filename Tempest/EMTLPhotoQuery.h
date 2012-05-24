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

- (void)photoSource:(EMTLPhotoSource *)source willUpdatePhotoQuery:(EMTLPhotoQuery *)photoQuery;
- (void)photoSource:(EMTLPhotoSource *)source didUpdatePhotoQuery:(EMTLPhotoQuery *)photoQuery;
- (void)photoSource:(EMTLPhotoSource *)source isUpdatingPhotoQuery:(EMTLPhotoQuery *)photoQuery progress:(float)progress;

@end

@interface EMTLPhotoQuery : NSObject
{
    
    @private
    NSString *_photoQueryID;
    EMTLPhotoQueryType _queryType;
    NSDictionary *_queryArguments;
    __weak id<EMTLPhotoQueryDelegate> _delegate;
    EMTLPhotoSource * _source;
    
    @protected
    NSMutableArray *_photoList; // BSEELY: Not actually sure this has to be mutable. 
}

@property (nonatomic, readonly, copy) NSArray *photoList;
@property (nonatomic, strong, readonly) EMTLPhotoSource * source;

@property (nonatomic, readonly) NSString *photoQueryID;
@property (nonatomic, readonly) EMTLPhotoQueryType queryType;
@property (nonatomic, strong) NSDictionary *queryArguments;
@property (nonatomic, weak) id<EMTLPhotoQueryDelegate> delegate;

- (id)initWithQueryID:(NSString *)queryID queryType:(EMTLPhotoQueryType)queryType arguments:(NSDictionary *)arguments source:(EMTLPhotoSource *)source;
- (void)photoSource:(EMTLPhotoSource *)source fetchedPhotos:(NSArray *)photos updatedQuery:(NSDictionary *)query;
- (void)photoSourceWillFetchPhotos:(EMTLPhotoSource *)source;
- (void)photoSource:(EMTLPhotoSource *)source isFetchingPhotosWithProgress:(float)progress;
- (void)morePhotos;
- (void)reloadPhotos;


@end
