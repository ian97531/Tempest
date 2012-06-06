//
//  EMTLFlickrFetchLocationOperation.h
//  Tempest
//
//  Created by Ian White on 6/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EMTLDownloadOperation.h"

@class EMTLPhoto;
@class EMTLFlickrPhotoSource;

@interface EMTLFlickrFetchLocationOperation : EMTLDownloadOperation
{
    EMTLPhoto *_photo;
    EMTLFlickrPhotoSource *_photoSource;
}

- (id)initWithPhoto:(EMTLPhoto *)photo photoSource:(EMTLFlickrPhotoSource *)photoSource;

// NSURLConnectionDataDelegate methods
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;

- (void)start;

@end
