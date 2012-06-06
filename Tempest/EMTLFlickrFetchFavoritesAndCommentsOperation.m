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
#import "EMTLLocation.h"
#import "EMTLUser.h"


@implementation EMTLFlickrFetchFavoritesAndCommentsOperation


- (id)initWithPhoto:(EMTLPhoto *)photo photoSource:(EMTLFlickrPhotoSource *)source
{
    self = [super init];
    if (self) {
        _photo = photo;
        _photoSource = source;
        _finished = NO;
        _executing = NO;

        _favoritesCurrentPage = 0;
        _favoritesPages = 1;
        
        _favorites = [NSMutableArray array];
        _comments = [NSMutableArray array];
        
    }
    
    return self;
}




- (void)start
{
    if (_finished) {
        return;
    }
    
    //NSLog(@"Requesting comments and favorites for photo: %@", _photo.photoID);
    
    [self willChangeValueForKey:@"isExecuting"];
    _executing = YES;
    [self didChangeValueForKey:@"isExecuting"];
    
    [self _startFavoritesRequest];
    [self _startCommentsRequest];
    
    _photo.comments = _comments;
    _photo.favorites = _favorites;

    [self willChangeValueForKey:@"isExecuting"];
    _executing = NO;
    [self didChangeValueForKey:@"isExecuting"];
    
    [self willChangeValueForKey:@"isFinished"];
    _finished = YES;
    [self didChangeValueForKey:@"isFinished"];
    
    //NSLog(@"finished requesting comments and favorites for photo: %@", _photo.photoID);
    
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



- (void) _startFavoritesRequest
{
    
    while (_favoritesCurrentPage < _favoritesPages) {
        //NSLog(@"Getting favorites page %i of %i for %@", _favoritesCurrentPage, _favoritesPages, _photo.photoID);
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
        
        NSURLResponse *response = nil;
        NSError *error = nil;
        NSData *favoritesData = [NSURLConnection sendSynchronousRequest:favoriteRequest returningResponse:&response error:&error];
        [_favorites addObjectsFromArray:[self _processFavorites:favoritesData]];
    }
    
    
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
    
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *commentsData = [NSURLConnection sendSynchronousRequest:commentRequest returningResponse:&response error:&error];
    [_comments addObjectsFromArray:[self _processComments:commentsData]];
    
}




- (NSArray *)_processFavorites:(NSData *)favoritesData
{
    NSDictionary *favoritesDict = [_photoSource dictionaryFromResponseData:favoritesData];

    if (!favoritesDict) {
        NSLog(@"There was an error interpreting the json response from the request for more photos from %@", _photoSource.serviceName);
        return [NSArray array];
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
            
            // Setup the user
            EMTLUser *user = [_photoSource userForUserID:[favoriteDict objectForKey:@"nsid"]];
            
            // If the nsid is same as the calling user, then this photo has been favorited and we should mark it as such.
            if (user == _photoSource.user)
            {
                NSLog(@"photo is favorite %@", _photo.photoID);
                _photo.isFavorite = YES;
            }
            
            if (!user.username)
            {
                user.username = [favoriteDict objectForKey:@"username"];
            }
            
            [favoriteDict setValue:user forKey:kFavoriteUser];
            
                        
            // Add the modified dict to the array of favorites.
            [favorites addObject:favoriteDict];
            
        }
        return favorites;
    }

}

- (NSArray *)_processComments:(NSData *)commentsData
{
    NSDictionary *commentsDict = [_photoSource dictionaryFromResponseData:commentsData];

    if(!commentsDict) {
        NSLog(@"There was an error interpreting the json response for comments from %@", _photoSource.serviceName);
        return [NSArray array];
    }

    else {
        NSMutableArray *comments = [NSMutableArray arrayWithCapacity:20];
        
        for (NSDictionary *commentDict in [[commentsDict objectForKey:@"comments"] objectForKey:@"comment"]) {
            
            // Get the date of the comment
            NSDate *comment_date = [NSDate dateWithTimeIntervalSince1970:[[commentDict objectForKey:@"datecreate"] doubleValue]];
            [commentDict setValue:comment_date forKey:kCommentDate];
            
            // Setup the user
            EMTLUser *user = [_photoSource userForUserID:[commentDict objectForKey:@"author"]];
            
            if (!user.username)
            {
                user.username = [commentDict objectForKey:@"authorname"];
            }
            
            [commentDict setValue:user forKey:kCommentUser];
            [commentDict setValue:[commentDict objectForKey:@"_content"] forKey:kCommentText];
            
            [comments addObject:commentDict];
        }
        return comments;
    }
}


@end
