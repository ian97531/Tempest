//
//  EMTLFlickrFetchImageOperation.m
//  Tempest
//
//  Created by Ian White on 5/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EMTLFlickrFetchImageOperation.h"
#import "EMTLFlickrPhotoSource.h"
#import "EMTLBackgroundConnection.h"
#import "EMTLPhoto.h"

@implementation EMTLFlickrFetchImageOperation

- (id)initWithPhoto:(EMTLPhoto *)photo size:(EMTLImageSize)size photoSource:(EMTLFlickrPhotoSource *)photoSource
{
    self = [super init];
    if (self) 
    {
        _photo = photo;
        _photoSource = photoSource;
        _size = size;
    }
    
    return self;
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [super connection:connection didReceiveData:data];
    
    float percent = (float)_incomingData.length/(float)_totalSize;
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        [_photoSource operation:self didRequestImageForPhoto:_photo withSize:_size progress:percent];
    });
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
    [super connectionDidFinishLoading:connection];
    
    UIImage *image = [UIImage imageWithData:_incomingData];
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width, image.size.height));
    [image drawAtPoint:CGPointZero];
    UIGraphicsEndImageContext();

    dispatch_sync(dispatch_get_main_queue(), ^{
        [_photoSource operation:self didLoadImage:image forPhoto:_photo withSize:_size];
    });
    

}


- (void)start
{
    dispatch_sync(dispatch_get_main_queue(), ^{
        [_photoSource operation:self willRequestImageForPhoto:_photo withSize:_size];
    });
    
    NSURLRequest *request = [NSURLRequest requestWithURL:_photo.imageURL cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:10.0];
    [self startRequest:request];
    
}


@end
