//
//  EMTLFlickrFetchUserOperation.h
//  Tempest
//
//  Created by Ian White on 6/4/12.
//  Copyright (c) 2012 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EMTLUser;
@class EMTLFlickrPhotoSource;

@interface EMTLFlickrFetchUserOperation : NSOperation
{
    @private
    BOOL _executing;
    BOOL _finished;
    EMTLUser *_user;
    EMTLFlickrPhotoSource *_photoSource;
}

- (id)initWithUser:(EMTLUser *)user photoSource:(EMTLFlickrPhotoSource *)photoSource;

- (void)start;
- (BOOL)isConcurrent;
- (BOOL)isExecuting;
- (BOOL)isFinished;


@end
