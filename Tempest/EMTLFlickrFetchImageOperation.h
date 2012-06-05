//
//  EMTLFlickrFetchImageOperation.h
//  Tempest
//
//  Created by Ian White on 5/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMTLConstants.h"
#import "EMTLDownloadOperation.h"

@protocol EMTLImageDelegate;
@class EMTLPhoto;
@class EMTLFlickrPhotoSource;

@interface EMTLFlickrFetchImageOperation : EMTLDownloadOperation
{
    EMTLPhoto *_photo;
    EMTLFlickrPhotoSource *_photoSource;
    EMTLImageSize _size;
}

- (id)initWithPhoto:(EMTLPhoto *)photo size:(EMTLImageSize)size photoSource:(EMTLFlickrPhotoSource *)photoSource;

// NSURLConnectionDataDelegate methods
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;


- (void)start;


@end
