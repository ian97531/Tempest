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
    
    UIImage *image = [UIImage imageWithData:_incomingData];
        
    CGImageRef cgImageRef = image.CGImage;
    // System only supports RGB, set explicitly and prevent context error
    // if the downloaded image is not the supported format
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context = CGBitmapContextCreate(NULL,
                                                 CGImageGetWidth(cgImageRef),
                                                 CGImageGetHeight(cgImageRef),
                                                 8,
                                                 // width * 4 will be enough because are in ARGB format, don't read from the image
                                                 CGImageGetWidth(cgImageRef) * 4,
                                                 colorSpace,
                                                 // kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Little 
                                                 // makes system don't need to do extra conversion when displayed.
                                                 kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Little); 
    CGColorSpaceRelease(colorSpace);
    
    if (context) {
        CGRect rect = (CGRect){CGPointZero, CGImageGetWidth(cgImageRef), CGImageGetHeight(cgImageRef)};
        CGContextDrawImage(context, rect, cgImageRef);
        CGImageRef decompressedImageRef = CGBitmapContextCreateImage(context);
        CGContextRelease(context);
        
        UIImage *decompressedImage = [[UIImage alloc] initWithCGImage:decompressedImageRef];
        CGImageRelease(decompressedImageRef);
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            [_photoSource operation:self didLoadImage:decompressedImage forPhoto:_photo withSize:_size];
        });
    }
    else {
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            [_photoSource operation:self didLoadImage:image forPhoto:_photo withSize:_size];
        });
        
    }
    
    [super connectionDidFinishLoading:connection];

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
