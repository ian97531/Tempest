//
//  EMTLPhoto.m
//  Tempest
//
//  Created by Ian White on 5/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EMTLPhoto.h"
#import "EMTLPhotoSource.h"

@implementation EMTLPhoto

@synthesize uniqueID;
@synthesize imageURL;
@synthesize title;
@synthesize description;
@synthesize user;
@synthesize dateUpdated;
@synthesize datePosted;
@synthesize photoID;
@synthesize aspectRatio;
@synthesize isFavorite;
@synthesize datePostedString;
@synthesize source = _source;
@synthesize comments;
@synthesize favorites;
@synthesize location;
@synthesize imageProgress = _imageProgress;

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
            if ([key isEqualToString:kPhotoUserID]) {
                user = [_source userForUserID:[dict objectForKey:kPhotoUserID]];
            }
            else if ([key isEqualToString:kPhotoTitle]) {
                title = [dict objectForKey:kPhotoTitle];
            }
            else if ([key isEqualToString:kPhotoID]) {
                photoID = [dict objectForKey:kPhotoID];
            }
            else if ([key isEqualToString:kPhotoImageURL]) {
                imageURL = [dict objectForKey:kPhotoImageURL];
            }
            else if ([key isEqualToString:kPhotoDatePosted]) {
                datePosted = [dict objectForKey:kPhotoDatePosted];
            }
            else if ([key isEqualToString:kPhotoImageAspectRatio]) {
                aspectRatio = [dict objectForKey:kPhotoImageAspectRatio];
            }
            else if ([key isEqualToString:kPhotoDateUpdated]) {
                dateUpdated = [dict objectForKey:kPhotoDateUpdated];
            }
        }
        
        NSString *username = [dict objectForKey:kPhotoUsername];
        if (username) {
            user.username = username;
        }
        
        comments = [NSArray array];
        favorites = [NSArray array];
        location = nil;
        _imageProgress = 0;
        isFavorite = NO;
        
        
    }
    
    return self;
    
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        user = [aDecoder decodeObjectForKey:kPhotoUserID];
        title = [aDecoder decodeObjectForKey:kPhotoTitle];
        photoID = [aDecoder decodeObjectForKey:kPhotoID];
        imageURL = [aDecoder decodeObjectForKey:kPhotoImageURL];
        datePosted = [aDecoder decodeObjectForKey:kPhotoDatePosted];
        aspectRatio = [aDecoder decodeObjectForKey:kPhotoImageAspectRatio];
        dateUpdated = [aDecoder decodeObjectForKey:kPhotoDateUpdated];
        isFavorite = [aDecoder decodeBoolForKey:kPhotoIsFavorite];
        location = [aDecoder decodeObjectForKey:kPhotoLocation];
        
        comments = [aDecoder decodeObjectForKey:kPhotoComments];
        favorites = [aDecoder decodeObjectForKey:kPhotoFavorites];
        
        _imageProgress = 0;
        
    }
    return self;

}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    
    [aCoder encodeObject:user forKey:kPhotoUserID];
    [aCoder encodeObject:title forKey:kPhotoTitle];
    [aCoder encodeObject:photoID forKey:kPhotoID];
    [aCoder encodeObject:imageURL forKey:kPhotoImageURL];
    [aCoder encodeObject:datePosted forKey:kPhotoDatePosted];
    [aCoder encodeObject:aspectRatio forKey:kPhotoImageAspectRatio];
    [aCoder encodeObject:dateUpdated forKey:kPhotoDateUpdated];
    [aCoder encodeBool:isFavorite forKey:kPhotoIsFavorite];
    [aCoder encodeObject:location forKey:kPhotoLocation];
    
    [aCoder encodeObject:comments forKey:kPhotoComments];
    [aCoder encodeObject:favorites forKey:kPhotoFavorites];
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
        
        [myFavorite setValue:[NSDate date] forKey:kFavoriteDate];
        [myFavorite setValue:_source.user forKey:kFavoriteUser];
        
        favorites = [favorites arrayByAddingObject:myFavorite];
    }
    
    // If we've unfavorited this picture, we need to remove ourselves from the array.
    else
    {
        NSDictionary *toDelete;
        for (NSDictionary *favorite in favorites) {
            if (_source.user == [favorite objectForKey:kFavoriteUser])
            {
                toDelete = favorite;
                break;
            }
        }
        
        if (toDelete)
        {
            
            NSMutableArray *newFavorites = [favorites mutableCopy];
            [newFavorites removeObject:toDelete];
            
            favorites = [NSArray arrayWithArray:newFavorites];
        }
    }
    
    
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
    
    if (datePostedString) {
        return datePostedString;
    }
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *nowComponents = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:now];
    NSDateComponents *dateComponents = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:datePosted];
    
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
                return @"Today";
            }
            else if (nowDay == dateDay + 1) {
                return @"Yesterday";
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
    
    datePostedString = [dateFormat stringFromDate:self.datePosted];
    
    return datePostedString;
    
}

@end
