//
//  EMTLFetchFavoritesAndCommentsOperation.h
//  Tempest
//
//  Created by Ian White on 5/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EMTLPhoto;
@class EMTLFlickrPhotoSource;

@interface EMTLFlickrFetchFavoritesAndCommentsOperation : NSOperation <NSURLConnectionDataDelegate>
{
    @private
    NSURLConnection *_favoriteConnection;
    NSMutableData *_favoriteData;
    uint _favoriteSize;
    BOOL _favoritesComplete;
    int _favoritesPages;
    int _favoritesCurrentPage;
    
    NSURLConnection *_commentConnection;
    NSMutableData *_commentData;
    uint _commentSize;
    BOOL _commentsComplete;
    
    BOOL _executing;
    BOOL _finished;
    EMTLPhoto *_photo;
    EMTLFlickrPhotoSource *_photoSource;
}

- (id)initWithPhoto:(EMTLPhoto *)photo photoSource:(EMTLFlickrPhotoSource *)source;

- (void)connection:(NSURLConnection *)aConnection didReceiveResponse:(NSURLResponse *)aResponse;
- (void)connection:(NSURLConnection *)aConnection didFailWithError:(NSError *)error;
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;

- (void)start;
- (BOOL)isConcurrent;
- (BOOL)isExecuting;
- (BOOL)isFinished;

@end
