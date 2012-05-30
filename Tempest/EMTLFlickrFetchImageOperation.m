//
//  EMTLFlickrFetchImageOperation.m
//  Tempest
//
//  Created by Ian White on 5/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EMTLFlickrFetchImageOperation.h"
#import "EMTLFlickrPhotoSource.h"
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
        
        _incomingData = [NSMutableData data];
        
        _executing = NO;
        _finished = NO;
        _totalSize = 0;
        
    }
    
    return self;
}

- (void)connection:(NSURLConnection *)aConnection didReceiveResponse:(NSURLResponse *)aResponse
{
     _totalSize = (uint)aResponse.expectedContentLength;
}

- (void)connection:(NSURLConnection *)aConnection didFailWithError:(NSError *)error
{
    // Figure out something good to do here.
    _executing = NO;
    _finished = YES;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_incomingData appendData:data];
    float percent = (float)_incomingData.length/(float)_totalSize;
    [_photoSource operation:self didRequestImageForPhoto:_photo withSize:_size progress:percent];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
    UIImage *image = [UIImage imageWithData:_incomingData];
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width, image.size.height));
    [image drawAtPoint:CGPointZero];
    UIGraphicsEndImageContext();

    [_photoSource operation:self didLoadImage:image forPhoto:_photo withSize:_size];
    
    
    [self willChangeValueForKey:@"isExecuting"];
    _executing = NO;
    [self didChangeValueForKey:@"isExecuting"];
    _executing = NO;
    
    [self willChangeValueForKey:@"isFinished"];
    _finished = YES;
    [self didChangeValueForKey:@"isFinished"];
}


- (void)start
{
    if (_finished) {
        return;
    }
    
    // Ensure that this operation starts on the main thread
    if (![NSThread isMainThread])
    {
        [self performSelectorOnMainThread:@selector(start)
                               withObject:nil waitUntilDone:NO];
        return;
    }
    
    [self willChangeValueForKey:@"isExecuting"];
    _executing = YES;
    [self didChangeValueForKey:@"isExecuting"];
    
    
    [_photoSource operation:self willRequestImageForPhoto:_photo withSize:_size];
    NSURLRequest *request = [NSURLRequest requestWithURL:_photo.imageURL cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:10.0];
    _connection = [NSURLConnection connectionWithRequest:request delegate:self];
    [_connection start];
    
}

- (void)cancel
{

    [_connection cancel];
    
    [self willChangeValueForKey:@"isExecuting"];
    _executing = NO;
    [self didChangeValueForKey:@"isExecuting"];
    _executing = NO;
    
    [self willChangeValueForKey:@"isFinished"];
    _finished = YES;
    [self didChangeValueForKey:@"isFinished"];
}

- (BOOL)isConcurrent
{
    return YES;
}

- (BOOL)isExecuting
{
    return _executing;
}

- (BOOL)isFinished
{
    return _finished;
}

@end
