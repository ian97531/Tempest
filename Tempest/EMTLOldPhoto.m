//
//  EMTLPhoto.m
//  Flickrgram
//
//  Created by Ian White on 4/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EMTLPhoto.h"
#import "EMTLOldPhotoCell.h"
#import "EMTLProgressIndicatorViewController.h"

@implementation EMTLPhoto

@synthesize imageURL;
@synthesize title;
@synthesize userID;
@synthesize username;
@synthesize dateUpdated;
@synthesize datePosted;
@synthesize photoID;
@synthesize aspectRatio;
@synthesize isFavorite;
@synthesize comments;
@synthesize favorites;
@synthesize favoritesShortString;
@synthesize datePostedString;
@synthesize imageDomain;

@synthesize container;
@synthesize source;

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
            else if ([key isEqualToString:kPhotoComments]) {
                comments = [dict objectForKey:kPhotoComments];
            }
            else if ([key isEqualToString:kPhotoFavorites]) {
                favorites = [dict objectForKey:kPhotoComments];
            }

        }
        
        
        
        
        
    }
    
    return self;
    
}

- (void)preloadData
{
    
    
    if (!favorites && !favoritesRequest) {
        [favoritesRequest fetch];
    }
    
    if (!comments && !commentsRequest) {
        [commentsRequest fetch];
    }
}

- (void)loadData
{
    
    if (!favorites && !favoritesRequest) {
        favoritesRequest = [EMTLCacheRequest requestWithDomain:favoritesDomain key:photoID type:EMTLKeyedObject];
        favoritesRequest.target = self;
        [favoritesRequest fetch];
    }
    
    if (!comments && !commentsRequest) {
        commentsRequest = [EMTLCacheRequest requestWithDomain:commentsDomain key:photoID type:EMTLKeyedObject];
        commentsRequest.target = self;
        [commentsRequest fetch];
    }
    
    if (!datePostedString) {
        [self datePostedString];
    }
}


- (void)cancel
{

    if(commentsRequest) {
        [commentsRequest cancel];
        commentsRequest = nil;
    }
    
    if (favoritesRequest) {
        [favoritesRequest cancel];
        favoritesRequest = nil;
    }
    
}


- (BOOL)isReady
{
    return (comments && favorites);
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




- (NSString *)favoritesShortString
{
    if (favoritesShortString) {
        return favoritesShortString;
    }
    else {
        favoritesShortString = nil;
        if (favorites.count) {
            
            int availableWidth = [EMTLOldPhotoCell favoritesStringWidth] - 5;
            UIFont *theFont = [EMTLOldPhotoCell favoritesFont];
            int totalLikes = favorites.count;
                    
            NSString *prefix = @"Liked by ";
            NSString *suffix = [NSString stringWithFormat:@" and %i others", totalLikes];
            
            int sizeUsedWithoutSuffix = [prefix sizeWithFont:theFont].width;
            int sizeUsedWithSuffix = sizeUsedWithoutSuffix + [suffix sizeWithFont:theFont].width;
            
            int i = 0;
            NSMutableArray *namesWithSuffix = [NSMutableArray arrayWithCapacity:4];
            NSMutableArray *namesWithoutSuffix = [NSMutableArray arrayWithCapacity:5];
            
            if([photoID isEqualToString:@"6899018088"] ) {
                NSLog(@"found it");
            }
            
            // First we need to see what we can fit on the line.
            while (i < favorites.count) {
                NSString *nameString;
                
                // Construct the string that would be added.
                if (i == 0) {
                    nameString = [[favorites objectAtIndex:0] objectForKey:kFavoriteUsername];
                }
                else {
                    nameString = [NSString stringWithFormat:@", %@", [[favorites objectAtIndex:i] objectForKey:kFavoriteUsername]];
                }
                
                // Size the string that would be added.
                int nameSize = [nameString sizeWithFont:theFont].width;
                
                // Add this size to both versions of the final string
                sizeUsedWithoutSuffix += nameSize;
                sizeUsedWithSuffix += nameSize;
                
                // If the name fits for either of the versions, record it.
                if (sizeUsedWithSuffix < availableWidth) {
                    [namesWithSuffix addObject:nameString];
                }
                
                if (sizeUsedWithoutSuffix < availableWidth) {
                    [namesWithoutSuffix addObject:nameString];
                }
                
                // If both are too big, break out. Otherwise, keep going.
                if (sizeUsedWithoutSuffix >= availableWidth && sizeUsedWithSuffix >= availableWidth) {
                    break;
                }
                else {
                    i++;
                }
                 
            }
                        
            // If we used all of the names we don't need the suffix.
            if (i == favorites.count) {
                NSString *nameString = [namesWithoutSuffix objectAtIndex:0];
               
                for (int j = 1; i < namesWithoutSuffix.count; i++) {
                    nameString = [NSString stringWithFormat:@"%@%@", nameString, [namesWithoutSuffix objectAtIndex:j]];
                }
                
                favoritesShortString = [NSString stringWithFormat:@"%@%@", prefix, nameString];
            }
            
            // If we weren't able to use all of the names, we need to add the suffix " and x others"
            else if (i > 0) {
                
                NSString *nameString = [namesWithSuffix objectAtIndex:0];
                int j;
                for (j = 1; j < namesWithSuffix.count; j++) {
                    nameString = [NSString stringWithFormat:@"%@%@", nameString, [namesWithSuffix objectAtIndex:j]];
                }
                
                // If more than one name made it in, we want a comma at the end.
                if (j > 1) {
                    nameString = [NSString stringWithFormat:@"%@,", nameString];
                }
                
                // How many were left unnamed?
                int remainder = favorites.count - namesWithSuffix.count;
                
                // If it was one, we need "other" to be singular, otherwise plural.
                if (remainder == 1) {
                    favoritesShortString = [NSString stringWithFormat:@"%@%@ and %i other", prefix, nameString, remainder];
                }
                else {
                    favoritesShortString = [NSString stringWithFormat:@"%@%@ and %i others", prefix, nameString, remainder];
                }
                
            }
            else {
                if (favorites.count == 1) {
                    favoritesShortString = @"1 like";
                }
                else {
                    favoritesShortString = [NSString stringWithFormat:@"%i likes", favorites.count];
                }
                
            }
                    
        
        }
        else {
            favoritesShortString = @"0 likes";
        }
            
        return favoritesShortString;
    }
}



- (NSString *)commentsShortString
{
    if (comments.count == 1) {
        return @"1 comment";
    }
    else {
        return [NSString stringWithFormat:@"%i comments", comments.count];
    }
    
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

#pragma mark - EMTLCacheClient methods
- (void)retrievedObject:(id)object ForRequest:(EMTLCacheRequest *)request
{
    if (request.domain == commentsDomain) {
        comments = (NSArray *)object;
        [container setCommentsString:[self commentsShortString]];
    }
    else if(request.domain == favoritesDomain) {
        favorites = (NSArray *)object;
        [container setFavoritesString:[self favoritesShortString]];
    }
    
}

- (void)fetchedBytes:(int)bytes ofTotal:(int)total forRequest:(EMTLCacheRequest *)request
{
    //NSLog(@"got %i bytes for %@ in domain %@", bytes, photoID, request.domain);
}

- (void)unableToRetrieveObjectForRequest:(EMTLCacheRequest *)request
{
    //NSLog(@"Photo: %@ was unable to get %@ from the cache", photoID, request.domain);
}












@end