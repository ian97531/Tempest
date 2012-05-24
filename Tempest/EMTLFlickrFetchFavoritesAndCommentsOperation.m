//
//  EMTLFetchFavoritesAndCommentsOperation.m
//  Tempest
//
//  Created by Ian White on 5/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EMTLFlickrFetchFavoritesAndCommentsOperation.h"
#import "EMTLPhoto.h"
#import "EMTLFlickrPhotoSource.h"


@implementation EMTLFlickrFetchFavoritesAndCommentsOperation


- (id)initWithPhoto:(EMTLPhoto *)photo photoSource:(EMTLFlickrPhotoSource *)source
{
    self = [super init];
    if (self) {
        _photo = photo;
        _photoSource = source;
        _finished = NO;
        _executing = NO;
        _commentData = [NSMutableData data];
        _favoriteData = [NSMutableData data];
        _favoritesCurrentPage = 0;
    }
    
    return self;
}

- (void)connection:(NSURLConnection *)aConnection didReceiveResponse:(NSURLResponse *)aResponse
{
    if (aConnection == _favoriteConnection) 
    {
        _favoriteSize = (uint)aResponse.expectedContentLength;
    }
    else if (aConnection == _commentConnection)
    {
        _commentSize = (uint)aResponse.expectedContentLength;
    }
}

- (void)connection:(NSURLConnection *)aConnection didFailWithError:(NSError *)error
{
    // Do something good here.
    _executing = NO;
    _finished = YES;
}

- (void)connection:(NSURLConnection *)aConnection didReceiveData:(NSData *)data
{
    if (aConnection == _favoriteConnection) 
    {
        [_favoriteData appendData:data];
    }
    else if (aConnection == _commentConnection)
    {
        [_commentData appendData:data];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)aConnection
{
    if (aConnection == _favoriteConnection) 
    {
        _photo.favorites = [_photo.favorites arrayByAddingObjectsFromArray:[self _processFavorites]];
        
        if (_favoritesCurrentPage < _favoritesPages)
        {
            [self _startFavoritesRequest];
        }
        else 
        {
            _favoritesComplete = YES;
        }
        
    }
    else if (aConnection == _commentConnection)
    {
        _photo.comments = [_photo.comments arrayByAddingObjectsFromArray:[self _processComments]];
        _commentsComplete = YES;
    }
    
    if (_favoritesComplete && _commentsComplete) 
    {
        _executing = NO;
        _finished = YES;
    }

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
    
    [self _startFavoritesRequest];
    [self _startCommentsRequest];
    
}

- (void)cancel
{
    if (_favoriteConnection) 
    {
        [_favoriteConnection cancel];
    }
    
    if (_commentConnection)
    {
        [_commentConnection cancel];
    }
    
    _executing = NO;
    _finished = YES;
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



- (void) _startFavoritesRequest
{
    // Fetch the favorites
    NSMutableDictionary *favoriteArgs = [NSMutableDictionary dictionaryWithCapacity:4];
    [favoriteArgs setObject:kFlickrAPIKey 
                     forKey:kFlickrAPIArgumentAPIKey];
    
    [favoriteArgs setObject:_photo.photoID
                     forKey:kFlickrAPIArgumentPhotoID];
    
    [favoriteArgs setObject:@"50"
                     forKey:kFlickrAPIArgumentItemsPerPage];
    
    [favoriteArgs setObject:[[NSNumber numberWithInt:_favoritesCurrentPage + 1] stringValue]
                     forKey:kFlickrAPIArgumentPageNumber];
    
    OAMutableURLRequest *favoriteRequest = [_photoSource oaurlRequestForMethod:kFlickrAPIMethodPhotoFavorites arguments:favoriteArgs];
    
    _favoriteConnection = [NSURLConnection connectionWithRequest:favoriteRequest delegate:self];
    [_favoriteConnection start];
}



-(void) _startCommentsRequest
{
    // Fetch the comments
    NSMutableDictionary *commentsArgs = [NSMutableDictionary dictionaryWithCapacity:4];
    
    [commentsArgs setObject:kFlickrAPIKey 
                     forKey:kFlickrAPIArgumentAPIKey];
    
    [commentsArgs setObject:_photo.photoID
                     forKey:kFlickrAPIArgumentPhotoID];
    
    OAMutableURLRequest *commentRequest = [_photoSource oaurlRequestForMethod:kFlickrAPIMethodPhotoComments arguments:commentsArgs];
    
    _commentConnection = [NSURLConnection connectionWithRequest:commentRequest delegate:self];
    [_commentConnection start];
    
}

- (NSArray *)_processFavorites
{
    NSDictionary *favoritesDict = [_photoSource dictionaryFromResponseData:_favoriteData];

    if (!favoritesDict) {
        NSLog(@"There was an error interpreting the json response from the request for more photos from %@", _photoSource.serviceName);
        return nil;
    }
    else {
        
        NSMutableArray *favorites = [NSMutableArray arrayWithCapacity:20];
        
        _favoritesPages = [[[favoritesDict objectForKey:@"photo"] objectForKey:@"pages"] intValue];
        _favoritesCurrentPage = [[[favoritesDict objectForKey:@"photo"] objectForKey:@"page"] intValue];
        
        // Iterate through all of the favorites. We need to put the data into a format
        // that the generic EMTLPhoto class will understand.
        for (NSDictionary *favoriteDict in [[favoritesDict objectForKey:@"photo"] objectForKey:@"person"]) {
            
            // Get the date of the favoriting
            NSDate *favorite_date = [NSDate dateWithTimeIntervalSince1970:[[favoriteDict objectForKey:@"favedate"] doubleValue]];
            [favoriteDict setValue:favorite_date forKey:kFavoriteDate];
            
            // Construct the icon URL
            int iconfarm = [[favoriteDict objectForKey:@"iconfarm"] intValue];
            int iconserver = [[favoriteDict objectForKey:@"iconserver"] intValue];
            NSString *nsid = [favoriteDict objectForKey:@"nsid"];
            
            // If the iconfarm and iconserver were supplied, then we can construct the icon URL,
            // otherwise, we'll use flickr's generic icon url.
            NSURL *userIconURL;
            if (iconfarm && iconserver) {
                userIconURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://farm%i.staticflickr.com/%i/buddyicons/%@.jpg", iconfarm, iconserver, nsid]];
            }
            else {
                userIconURL = [NSURL URLWithString:kFlickrDefaultIconURLString];
            }
            
            [favoriteDict setValue:userIconURL forKey:kFavoriteIconURL];
            [favoriteDict setValue:nsid forKey:kFavoriteUserID];
            [favoriteDict setValue:[favoriteDict objectForKey:@"username"] forKey:kFavoriteUsername];
            
            // Add the modified dict to the array of favorites.
            [favorites addObject:favoriteDict];
            
        }
        return favorites;
    }

}

- (NSArray *)_processComments
{
    NSDictionary *commentsDict = [_photoSource dictionaryFromResponseData:_commentData];

    if(!commentsDict) {
        NSLog(@"There was an error interpreting the json response for comments from %@", _photoSource.serviceName);
        return nil;
    }

    else {
        NSMutableArray *comments = [NSMutableArray arrayWithCapacity:20];
        
        for (NSDictionary *commentDict in [[commentsDict objectForKey:@"comments"] objectForKey:@"comment"]) {
            
            // Get the date of the comment
            NSDate *comment_date = [NSDate dateWithTimeIntervalSince1970:[[commentDict objectForKey:@"datecreate"] doubleValue]];
            [commentDict setValue:comment_date forKey:kCommentDate];
            
            // Get the icon URL for the user who left the comment
            int iconfarm = [[commentDict objectForKey:@"iconfarm"] intValue];
            int iconserver = [[commentDict objectForKey:@"iconserver"] intValue];
            NSString *nsid = [commentDict objectForKey:@"author"];
            
            NSURL *userIconURL;
            if (iconfarm && iconserver) {
                userIconURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://farm%i.staticflickr.com/%i/buddyicons/%@.jpg", iconfarm, iconserver, nsid]];
            }
            else {
                userIconURL = [NSURL URLWithString:kFlickrDefaultIconURLString];
            }
            [commentDict setValue:userIconURL forKey:kCommentIconURL];
            [commentDict setValue:[commentDict objectForKey:@"_content"] forKey:kCommentText];
            [commentDict setValue:nsid forKey:kCommentUserID];
            [commentDict setValue:[commentDict objectForKey:@"authorname"] forKey:kCommentUsername];
            
            
            [comments addObject:commentDict];
        }
        return comments;
    }


}


@end
