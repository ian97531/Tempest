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
@synthesize userID;
@synthesize username;
@synthesize dateUpdated;
@synthesize datePosted;
@synthesize photoID;
@synthesize aspectRatio;
@synthesize isFavorite;
@synthesize datePostedString;
@synthesize source;
@synthesize comments;
@synthesize favorites;
@synthesize imageProgress = _imageProgress;

+ (id)photoWithDict:(NSDictionary *)dict
{
    return [[EMTLPhoto alloc] initWithDict:dict];
}

- (id)initWithDict:(NSDictionary *)dict
{
    self = [super init];
    if(self) {
        
        for (NSString *key in dict) {
            if ([key isEqualToString:kPhotoUserID]) {
                userID = [dict objectForKey:kPhotoUserID];
            }
            else if ([key isEqualToString:kPhotoUsername]) {
                username = [dict objectForKey:kPhotoUsername];
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
        
        comments = [NSArray array];
        favorites = [NSArray array];
        _imageProgress = 0;
        
        
    }
    
    return self;
    
}


- (UIImage *)loadImageWithSize:(EMTLImageSize)size delegate:(id<EMTLImageDelegate>)delegate
{
    _delegate = delegate;
    return [source imageForPhoto:self size:size];
}

- (void)cancelImageWithSize:(EMTLImageSize)size
{
    [source cancelImageForPhoto:self size:size];
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
    return [NSString stringWithFormat:@"%@-%@", source.serviceName, photoID];
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
