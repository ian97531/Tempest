//
//  EMTLPhoto.m
//  Tempest
//
//  Created by Ian White on 5/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EMTLPhoto.h"
#import "EMTLPhotoSource.h"

@interface EMTLPhoto ()

- (NSArray *)_generateFavoriteUsersArray:(NSArray *)faves;
- (NSString *)_humanDateStringFromDate:(NSDate *)date;

@end


@implementation EMTLPhoto

@synthesize uniqueID;
@synthesize imageURL;
@synthesize webPageURL;
@synthesize title;
@synthesize photoDescription;
@synthesize user;
@synthesize dateUpdated;
@synthesize datePosted;
@synthesize dateTaken;
@synthesize photoID;
@synthesize tags;
@synthesize license;
@synthesize aspectRatio;
@synthesize isFavorite;
@synthesize datePostedString;
@synthesize source = _source;
@synthesize comments;
@synthesize favorites = _favorites;
@synthesize location;
@synthesize imageProgress = _imageProgress;
@synthesize favoritesUsers = _favoritesUsers;

+ (id)photoWithSource:(EMTLPhotoSource *)source dict:(NSDictionary *)dict
{
    return [[EMTLPhoto alloc] initWithSource:source dict:dict];
}

- (id)initWithSource:(EMTLPhotoSource *)source dict:(NSDictionary *)dict;
{
    self = [super init];
    if(self) {
        _source = source;
        
        for (NSString *key in dict) {
            if ([key isEqualToString:EMTLPhotoUser]) {
                user = [dict objectForKey:EMTLPhotoUser];
            }
            else if ([key isEqualToString:EMTLPhotoTitle]) {
                title = [dict objectForKey:EMTLPhotoTitle];
            }
            else if ([key isEqualToString:EMTLPhotoID]) {
                photoID = [dict objectForKey:EMTLPhotoID];
            }
            else if ([key isEqualToString:EMTLPhotoImageURL]) {
                imageURL = [dict objectForKey:EMTLPhotoImageURL];
            }
            else if ([key isEqualToString:EMTLPhotoDatePosted]) {
                datePosted = [dict objectForKey:EMTLPhotoDatePosted];
            }
            else if ([key isEqualToString:EMTLPhotoImageAspectRatio]) {
                aspectRatio = [dict objectForKey:EMTLPhotoImageAspectRatio];
            }
            else if ([key isEqualToString:EMTLPhotoDateUpdated]) {
                dateUpdated = [dict objectForKey:EMTLPhotoDateUpdated];
            }
            else if ([key isEqualToString:EMTLPhotoDateTaken]) {
                dateTaken = [dict objectForKey:EMTLPhotoDateTaken];
            }
            else if ([key isEqualToString:EMTLPhotoDescription]) {
                photoDescription = [dict objectForKey:EMTLPhotoDescription];
            }
            else if ([key isEqualToString:EMTLPhotoWebPageURL]) {
                webPageURL = [dict objectForKey:EMTLPhotoWebPageURL];
            }
            else if ([key isEqualToString:EMTLPhotoTags]) {
                tags = [dict objectForKey:EMTLPhotoTags];
            }
            else if ([key isEqualToString:EMTLPhotoLicense]) {
                license = [[dict objectForKey:EMTLPhotoLicense] intValue];
            }
        }
        
        if (!tags) tags = [NSArray array];
        
        comments = [NSArray array];
        _favorites = [NSArray array];
        location = nil;
        _imageProgress = 0;
        isFavorite = NO;
        _favoritesUsers = [NSArray array];
        _updateUsers = NO;
        
        
    }
    
    return self;
    
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        user = [aDecoder decodeObjectForKey:EMTLPhotoUser];
        title = [aDecoder decodeObjectForKey:EMTLPhotoTitle];
        photoID = [aDecoder decodeObjectForKey:EMTLPhotoID];
        imageURL = [aDecoder decodeObjectForKey:EMTLPhotoImageURL];
        webPageURL = [aDecoder decodeObjectForKey:EMTLPhotoWebPageURL];
        datePosted = [aDecoder decodeObjectForKey:EMTLPhotoDatePosted];
        aspectRatio = [aDecoder decodeObjectForKey:EMTLPhotoImageAspectRatio];
        dateUpdated = [aDecoder decodeObjectForKey:EMTLPhotoDateUpdated];
        isFavorite = [aDecoder decodeBoolForKey:EMTLPhotoIsFavorite];
        location = [aDecoder decodeObjectForKey:EMTLPhotoLocation];
        photoDescription = [aDecoder decodeObjectForKey:EMTLPhotoDescription];
        dateTaken = [aDecoder decodeObjectForKey:EMTLPhotoDateTaken];
        tags = [aDecoder decodeObjectForKey:EMTLPhotoTags];
        license = [aDecoder decodeIntForKey:EMTLPhotoLicense];
        
        comments = [aDecoder decodeObjectForKey:EMTLPhotoComments];
        _favorites = [aDecoder decodeObjectForKey:EMTLPhotoFavorites];
        
        _imageProgress = 0;
        
        _updateUsers = YES;
        
        
    }
    return self;

}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    
    [aCoder encodeObject:user forKey:EMTLPhotoUser];
    [aCoder encodeObject:title forKey:EMTLPhotoTitle];
    [aCoder encodeObject:photoID forKey:EMTLPhotoID];
    [aCoder encodeObject:imageURL forKey:EMTLPhotoImageURL];
    [aCoder encodeObject:webPageURL forKey:EMTLPhotoWebPageURL];
    [aCoder encodeObject:datePosted forKey:EMTLPhotoDatePosted];
    [aCoder encodeObject:aspectRatio forKey:EMTLPhotoImageAspectRatio];
    [aCoder encodeObject:dateUpdated forKey:EMTLPhotoDateUpdated];
    [aCoder encodeBool:isFavorite forKey:EMTLPhotoIsFavorite];
    [aCoder encodeObject:location forKey:EMTLPhotoLocation];
    [aCoder encodeObject:photoDescription forKey:EMTLPhotoDescription];
    [aCoder encodeObject:dateTaken forKey:EMTLPhotoDateTaken];
    [aCoder encodeObject:tags forKey:EMTLPhotoTags];
    [aCoder encodeInt:license forKey:EMTLPhotoLicense];
    
    [aCoder encodeObject:comments forKey:EMTLPhotoComments];
    [aCoder encodeObject:_favorites forKey:EMTLPhotoFavorites];
    
}

- (void)setSource:(EMTLPhotoSource *)source
{
    _source = source;
    
    // If we've unarchived this photo object, we need to replace all of the users associated
    // with it with users from the central store.
    if (_updateUsers) {
        
        EMTLUser *newOwner = [source userForUserID:user.userID];
        [newOwner copyExistingUser:user];
        user = newOwner;
        
        NSMutableArray *newComments = [NSMutableArray arrayWithCapacity:comments.count];
        NSMutableArray *newFaves = [NSMutableArray arrayWithCapacity:_favorites.count];
        
        for (NSDictionary *comment in comments) {
            EMTLUser *oldUser = [comment objectForKey:EMTLCommentUser];
            EMTLUser *newUser = [source userForUserID:oldUser.userID];
            [newUser copyExistingUser:oldUser];
            
            NSDictionary *newComment = [NSDictionary dictionaryWithObjectsAndKeys:  
                                        [comment objectForKey:EMTLCommentDate], EMTLCommentDate,
                                        [comment objectForKey:EMTLCommentText], EMTLCommentText,
                                        newUser, EMTLCommentUser,
                                        nil];
            
            [newComments addObject:newComment];
        }
        
        comments = newComments;
        
        for (NSDictionary *favorite in _favorites) {
            EMTLUser *oldUser = [favorite objectForKey:EMTLFavoriteUser];
            EMTLUser *newUser = [source userForUserID:oldUser.userID];
            [newUser copyExistingUser:oldUser];
            
            NSDictionary *newFave = [NSDictionary dictionaryWithObjectsAndKeys:  
                                        [favorite objectForKey:EMTLFavoriteDate], EMTLFavoriteDate,
                                        newUser, EMTLFavoriteUser,
                                        nil];
            
            [newFaves addObject:newFave];
        }
        
        _favorites = newFaves;
        _favoritesUsers = [self _generateFavoriteUsersArray:_favorites];
        
        _updateUsers = NO;
        
    }    
    
}


- (UIImage *)loadImageWithSize:(EMTLImageSize)size delegate:(id<EMTLImageDelegate>)delegate
{
    _delegate = delegate;
    return [_source imageForPhoto:self size:size];
}

- (void)cancelImageWithSize:(EMTLImageSize)size
{
    [_source cancelImageForPhoto:self size:size];
}

- (void)setFavorite:(BOOL)isFavoritePhoto
{
    if (isFavoritePhoto != isFavorite) {
        [_source setFavoriteStatus:(BOOL)isFavoritePhoto forPhoto:self];
        isFavorite = isFavoritePhoto;
    }
    
    // If we've added ourselves, we need to update the favorites array.
    if (isFavorite) {
        NSMutableDictionary *myFavorite = [NSMutableDictionary dictionaryWithCapacity:2];
        
        [myFavorite setValue:[NSDate date] forKey:EMTLFavoriteDate];
        [myFavorite setValue:_source.user forKey:EMTLFavoriteUser];
        
        _favorites = [_favorites arrayByAddingObject:myFavorite];
    }
    
    // If we've unfavorited this picture, we need to remove ourselves from the array.
    else
    {
        NSDictionary *toDelete;
        for (NSDictionary *favorite in _favorites) {
            if (_source.user == [favorite objectForKey:EMTLFavoriteUser])
            {
                toDelete = favorite;
                break;
            }
        }
        
        if (toDelete)
        {
            
            NSMutableArray *newFavorites = [_favorites mutableCopy];
            [newFavorites removeObject:toDelete];
            
            _favorites = [NSArray arrayWithArray:newFavorites];
        }
    }
    
    _favoritesUsers = [self _generateFavoriteUsersArray:_favorites];
    
    
}

- (void)setFavorites:(NSArray *)favorites
{
    
    _favoritesUsers = [self _generateFavoriteUsersArray:favorites];
    _favorites = favorites;
}

- (NSArray *)_generateFavoriteUsersArray:(NSArray *)faves
{
    // Sort the list of favorites by date, newest first.
    NSArray *sortedFaves = [faves sortedArrayUsingComparator:^(NSDictionary *id1, NSDictionary *id2){
        return [(NSDate *)[id2 objectForKey:EMTLFavoriteDate] compare:(NSDate *)[id1 objectForKey:EMTLFavoriteDate]];
    }];
    
    NSMutableArray *users = [NSMutableArray arrayWithCapacity:sortedFaves.count];
    
    // Put the users into an array
    for (NSDictionary *favoriteItem in sortedFaves) {
        [users addObject:[favoriteItem objectForKey:EMTLFavoriteUser]]; 
    }
    
    return users;
}


- (void)photoSource:(EMTLPhotoSource *)source willRequestImageWithSize:(EMTLImageSize)size
{
    [_delegate photo:self willRequestImageWithSize:size];
}

- (void)photoSource:(EMTLPhotoSource *)source didRequestImageWithSize:(EMTLImageSize)size progress:(float)progress
{
    _imageProgress = progress;
    [_delegate photo:self didRequestImageWithSize:size progress:progress];
}

- (void)photoSource:(EMTLPhotoSource *)source didLoadImage:(UIImage *)image withSize:(EMTLImageSize)size
{
    [_delegate photo:self didLoadImage:image withSize:size];
    _delegate = nil;
}


- (NSNumber *)aspectRatio
{
    if(aspectRatio) {
        return aspectRatio;
    }
    else {
        return [NSNumber numberWithInt:1];
    }
}

- (NSString *)uniqueID
{
    return [NSString stringWithFormat:@"%@-%@", _source.serviceName, photoID];
}


- (NSString *)datePostedString
{
    return [self _humanDateStringFromDate:datePosted];
}

- (NSString *)dateTakenString
{
    return [self _humanDateStringFromDate:dateTaken];
}


- (NSString *)_humanDateStringFromDate:(NSDate *)date 
{
//    
//    if (datePostedString) {
//        return datePostedString;
//    }
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *nowComponents = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:now];
    NSDateComponents *dateComponents = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:date];
    
    int nowYear = [nowComponents year];
    int nowMonth = [nowComponents month];
    int nowDay = [nowComponents day];
    
    int dateYear = [dateComponents year];
    int dateMonth = [dateComponents month];
    int dateDay = [dateComponents day];
    
    if (nowYear == dateYear)
    {
        
        if (nowMonth == dateMonth) {
            
            if (nowDay == dateDay) {
                return NSLocalizedString(@"Today", @"");
            }
            else if (nowDay == dateDay + 1) {
                return NSLocalizedString(@"Yesterday", @"");;
            }
            else if (nowDay - dateDay < 6) {
                [dateFormat setDateFormat:@"EEEE"];
            }
            else {
                [dateFormat setDateFormat:@"MMMM d"];
            }
            
        }
        else {
            [dateFormat setDateFormat:@"MMMM d"];
        }
        
    }
    else {
        [dateFormat setDateFormat:@"MMM d, y"];
    }
    
    //datePostedString = ;
    
    return [dateFormat stringFromDate:self.datePosted];
    
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"\nPhoto ID:%@\nPhoto Title: %@\nPhoto Date:%@\nTaken By: %@", photoID, title, datePosted, [user description]];
}

@end
