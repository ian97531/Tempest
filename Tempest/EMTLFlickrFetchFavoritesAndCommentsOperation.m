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
        [favoriteArgs setObject:EMTLFlickrAPIKey 
                         forKey:EMTLFlickrAPIArgumentAPIKey];
        
        [favoriteArgs setObject:_photo.photoID
                         forKey:EMTLFlickrAPIArgumentPhotoID];
        
        [favoriteArgs setObject:EMTLFlickrAPIValueFavoriteItemsPerPage
                         forKey:EMTLFlickrAPIArgumentItemsPerPage];
        
        [favoriteArgs setObject:[[NSNumber numberWithInt:_favoritesCurrentPage + 1] stringValue]
                         forKey:EMTLFlickrAPIArgumentPageNumber];
        
        OAMutableURLRequest *favoriteRequest = [_photoSource oaurlRequestForMethod:EMTLFlickrAPIMethodPhotoFavorites arguments:favoriteArgs];
        
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
    
    [commentsArgs setObject:EMTLFlickrAPIKey 
                     forKey:EMTLFlickrAPIArgumentAPIKey];
    
    [commentsArgs setObject:_photo.photoID
                     forKey:EMTLFlickrAPIArgumentPhotoID];
    
    OAMutableURLRequest *commentRequest = [_photoSource oaurlRequestForMethod:EMTLFlickrAPIMethodPhotoComments arguments:commentsArgs];
    
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
        
        _favoritesPages = [[[favoritesDict objectForKey:EMTLFlickrAPIResponseFavoritesList] objectForKey:EMTLFlickrAPIResponseListPages] intValue];
        _favoritesCurrentPage = [[[favoritesDict objectForKey:EMTLFlickrAPIResponseFavoritesList] objectForKey:EMTLFlickrAPIResponseListPage] intValue];
        
        // Iterate through all of the favorites. We need to put the data into a format
        // that the generic EMTLPhoto class will understand.
        for (NSDictionary *favoriteDict in [[favoritesDict objectForKey:EMTLFlickrAPIResponseFavoritesList] objectForKey:EMTLFlickrAPIResponseFavoritesListItems]) {
            
            // Get the date of the favoriting
            [favoriteDict setValue:[NSDate dateWithTimeIntervalSince1970:[[favoriteDict objectForKey:EMTLFlickrAPIResponseFavoriteDate] doubleValue]]
                            forKey:EMTLFavoriteDate];
            
            // Setup the user
            NSString *userID = [favoriteDict objectForKey:EMTLFlickrAPIResponseFavoriteUserID];
            NSString *username = [favoriteDict objectForKey:EMTLFlickrAPIResponseFavoriteUsername];
            NSString *iconFarm = [favoriteDict objectForKey:EMTLFlickrAPIResponseUserIconFarm];
            NSString *iconServer = [favoriteDict objectForKey:EMTLFlickrAPIResponseUserIconServer];
            
            EMTLUser *user = [_photoSource userForUserID:userID];
            user.username = username;
            user.iconURL = [NSURL URLWithString:[NSString stringWithFormat:EMTLFlickrUserIconURLFormat, iconFarm, iconServer, userID]];

            [favoriteDict setValue:user forKey:EMTLFavoriteUser];
            
            
            // If the nsid is same as the calling user, then this photo has been favorited and we should mark it as such.
            if (user == _photoSource.user)
            {
                _photo.isFavorite = YES;
            }
                        
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
        
        for (NSDictionary *commentDict in [[commentsDict objectForKey:EMTLFlickrAPIResponseCommentsList] objectForKey:EMTLFlickrAPIResponseCommentsListItems]) {
            
            // Get the date of the comment
            [commentDict setValue:[NSDate dateWithTimeIntervalSince1970:[[commentDict objectForKey:EMTLFlickrAPIResponseCommentDate] doubleValue]]
                           forKey:EMTLCommentDate];
            
            // Get the comment content
            [commentDict setValue:[commentDict objectForKey:EMTLFlickrAPIResponseCommentContent]
                           forKey:EMTLCommentText];
            
            // Get the user
            NSString *userID = [commentDict objectForKey:EMTLFlickrAPIResponseCommentUserID];
            NSString *username = [commentDict objectForKey:EMTLFlickrAPIResponseCommentUsername];
            NSString *iconFarm = [commentDict objectForKey:EMTLFlickrAPIResponseUserIconFarm];
            NSString *iconServer = [commentDict objectForKey:EMTLFlickrAPIResponseUserIconServer];
            
            EMTLUser *user = [_photoSource userForUserID:userID];
            user.username = username;
            user.iconURL = [NSURL URLWithString:[NSString stringWithFormat:EMTLFlickrUserIconURLFormat, iconFarm, iconServer, userID]];
    
            [commentDict setValue:user forKey:EMTLCommentUser];
            
            // Save this comment to our internal list for this operation
            [comments addObject:commentDict];
            
        }
        return comments;
    }
}


@end
