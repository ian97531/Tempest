//
//  EMTLPhotoList.h
//  Tempest
//
//  Created by Ian White on 5/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMTLPhotoSource.h"

@class EMTLPhotoList;

@protocol EMTLPhotoListDelegate <NSObject>

- (void)photoListWillUpdate:(EMTLPhotoList *)photoList;
- (void)photoListDidUpdate:(EMTLPhotoList *)photoList;
- (void)photoList:(EMTLPhotoList *)photoList isUpdatingWithProgress:(float)progress;

@end

@interface EMTLPhotoList : NSObject
{
    @private
    NSDictionary *_query;
    NSDictionary *_blankQuery;
    NSArray *_photos;
    id<EMTLPhotoSource> _source;
    __weak id<EMTLPhotoListDelegate> _delegate;
}

@property (nonatomic, strong, readonly) NSArray *photos;
@property (nonatomic, strong, readonly) NSDictionary *query;
@property (nonatomic, strong, readonly) id<EMTLPhotoSource> source;
@property (nonatomic, weak) id<EMTLPhotoListDelegate> delegate;


- (id)initWithPhotoSource:(id<EMTLPhotoSource>)source query:(NSDictionary *)query cachedPhotos:(NSArray *)photos;
- (void)photoSource:(id<EMTLPhotoSource>)source fetchedPhotos:(NSArray *)photos updatedQuery:(NSDictionary *)query;
- (void)photoSourceWillFetchPhotos:(id<EMTLPhotoSource>)source;
- (void)photoSource:(id<EMTLPhotoSource>)source isFetchingPhotosWithProgress:(float)progress;
- (void)morePhotos;
- (void)reloadPhotos;


@end
