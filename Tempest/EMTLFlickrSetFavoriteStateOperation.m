//
//  EMTLFlickrSetFavoriteStateOperation.m
//  Tempest
//
//  Created by Ian White on 6/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EMTLFlickrSetFavoriteStateOperation.h"
#import "EMTLPhoto.h"
#import "EMTLFlickrPhotoSource.h"

@implementation EMTLFlickrSetFavoriteStateOperation

- (id)initWithPhoto:(EMTLPhoto *)photo newFavoriteState:(BOOL)isFavorite photoSource:(EMTLFlickrPhotoSource *)photoSource
{
    self = [super init];
    if (self) {
        _photo = photo;
        _photoSource = photoSource;
        _isFavorite = isFavorite;
    }
    
    return self;
    
    
}


- (void)start
{
    if (_finished) {
        return;
    }
    
    [self willChangeValueForKey:@"isExecuting"];
    _executing = YES;
    [self didChangeValueForKey:@"isExecuting"];

    NSMutableDictionary *favoritesArgs = [NSMutableDictionary dictionaryWithCapacity:4];
    
    [favoritesArgs setObject:kFlickrAPIKey 
                     forKey:kFlickrAPIArgumentAPIKey];
    
    [favoritesArgs setObject:_photo.photoID
                     forKey:kFlickrAPIArgumentPhotoID];
    
    NSString *favoritesMethod = _isFavorite ? kFlickrAPIMethodAddFavorite : kFlickrAPIMethodRemoveFavorite;
    OAMutableURLRequest *favoritesRequest = [_photoSource oaurlRequestForMethod:favoritesMethod arguments:favoritesArgs];
    //[favoritesRequest setHTTPMethod:@"POST"];
    //[favoritesRequest prepare];
    
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *favoritesData = [NSURLConnection sendSynchronousRequest:favoritesRequest returningResponse:&response error:&error];
    BOOL success = [self _processFavoritesResponse:favoritesData];
    
    // Let the photo source know if it worked.
    dispatch_sync(dispatch_get_main_queue(), ^{
        if (success) 
        {
            [_photoSource operation:self successfullySetFavoriteStateForPhoto:_photo];
        }
        else
        {
            [_photoSource operation:self failedToSetFavoriteStateForPhoto:_photo];
        }
        
    });


    [self willChangeValueForKey:@"isExecuting"];
    _executing = NO;
    [self didChangeValueForKey:@"isExecuting"];

    [self willChangeValueForKey:@"isFinished"];
    _finished = YES;
    [self didChangeValueForKey:@"isFinished"];


}

- (void)cancel
{
    
    [self willChangeValueForKey:@"isExecuting"];
    _executing = NO;
    [self didChangeValueForKey:@"isExecuting"];
    
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


- (BOOL)_processFavoritesResponse:(NSData *)favoritesResponse
{
    NSDictionary *favoritesDict = [_photoSource dictionaryFromResponseData:favoritesResponse];
    
    if (!favoritesDict) {
        NSLog(@"There was an error interpreting the json response from the request for more photos from %@", _photoSource.serviceName);
        return NO;
    }
    else {
        BOOL success = [[favoritesDict objectForKey:@"stat"] isEqualToString:@"ok"];
        return success;
    }
}


@end
