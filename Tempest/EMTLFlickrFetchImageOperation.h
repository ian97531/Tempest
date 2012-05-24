//
//  EMTLFlickrFetchImageOperation.h
//  Tempest
//
//  Created by Ian White on 5/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMTLConstants.h"

@protocol EMTLImageDelegate;
@class EMTLPhoto;
@class EMTLPhotoSource;

@interface EMTLFlickrFetchImageOperation : NSOperation
{
    EMTLPhoto *_photo;
    EMTLPhotoSource *_photoSource;
    id<EMTLImageDelegate> _delegate;
    EMTLImageSize _size;
    NSURLConnection *_connection;
    NSMutableData *_incomingData;
    uint _totalSize;
    BOOL _executing;
    BOOL _finished;
}

- (id)initWithPhoto:(EMTLPhoto *)photo size:(EMTLImageSize)size photoSource:(EMTLPhotoSource *)photoSource delegate:(id<EMTLImageDelegate>)delegate;

- (void)connection:(NSURLConnection *)aConnection didReceiveResponse:(NSURLResponse *)aResponse;
- (void)connection:(NSURLConnection *)aConnection didFailWithError:(NSError *)error;
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;

- (void)start;
- (BOOL)isConcurrent;
- (BOOL)isExecuting;
- (BOOL)isFinished;


@end
