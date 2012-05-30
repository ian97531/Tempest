//
//  EMTLFlickrFetchPhotoListOperation.h
//  Tempest
//
//  Created by Ian White on 5/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EMTLFlickrPhotoSource;
@class EMTLPhotoQuery;

@interface EMTLFlickrFetchPhotoQueryOperation : NSOperation 
{
    EMTLPhotoQuery *_photoQuery;
    EMTLFlickrPhotoSource *_photoSource;
    NSDictionary *_query;
    BOOL _executing;
    BOOL _finished;
    
    NSOperationQueue *_commentsAndFavorites;
}

@property (nonatomic, strong, readonly) EMTLPhotoQuery *photoQuery;
@property (nonatomic, strong, readonly) EMTLFlickrPhotoSource *photoSource;
@property (nonatomic, strong, readonly) NSString *identifier;

- (id)initWithPhotoQuery:(EMTLPhotoQuery *)photoQuery photoSource:(EMTLFlickrPhotoSource *)photoSource;


- (void)start;
- (BOOL)isConcurrent;
- (BOOL)isExecuting;
- (BOOL)isFinished;

@end
