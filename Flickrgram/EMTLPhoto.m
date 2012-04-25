//
//  EMTLPhoto.m
//  Flickrgram
//
//  Created by Ian White on 4/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EMTLPhoto.h"
#import "EMTLPhotoCell.h"
#import "EMTLProgressIndicatorViewController.h"

@implementation EMTLPhoto

@synthesize image_URL;
@synthesize title;
@synthesize user_id;
@synthesize username;
@synthesize description;
@synthesize dateUpdated;
@synthesize datePosted;
@synthesize photo_id;
@synthesize image;
@synthesize container;
@synthesize source;
@synthesize imageData;
@synthesize connection;
@synthesize aspect_ratio;
@synthesize isFavorite;
@synthesize comments;
@synthesize favorites;
@synthesize favoritesShortString;
@synthesize datePostedString;
@synthesize currentPercent;

- (id)initWithDict:(NSDictionary *)dict
{
    self = [super init];
    if(self) {
        
        loadingImage = NO;
        loadingFavorites = NO;
        loadingComments = NO;
        loadRequested = YES;
        expectingBytes = 0;
        currentPercent = 0;

        
        for (NSString *key in dict) {
            if ([key isEqualToString:@"owner"]) {
                user_id = [dict objectForKey:@"owner"];
            }
            else if ([key isEqualToString:@"ownername"]) {
                username = [dict objectForKey:@"ownername"];
            }
            else if ([key isEqualToString:@"title"]) {
                title = [dict objectForKey:@"title"];
            }
            else if ([key isEqualToString:@"id"]) {
                photo_id = [dict objectForKey:@"id"];
            }
            else if ([key isEqualToString:@"url"]) {
                image_URL = [dict objectForKey:@"url"];
            }
            else if ([key isEqualToString:@"date_posted"]) {
                datePosted = [dict objectForKey:@"date_posted"];
            }
            else if ([key isEqualToString:@"aspect_ratio"]) {
                aspect_ratio = [dict objectForKey:@"aspect_ratio"];
            }
            else if ([key isEqualToString:@"date_updated"]) {
                dateUpdated = [dict objectForKey:@"date_updated"];
            }
            
        }
        
    }
    
    return self;
    
}

- (void)loadData
{
    if(!image && !loadingImage) {
        loadingImage = YES;
        imageData = [NSMutableData data];
        NSURLRequest *request = [NSURLRequest requestWithURL:image_URL cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:30];
        connection = [NSURLConnection connectionWithRequest:request delegate:self];
        [connection start];
        
    }
    
    if (!favorites && !loadingFavorites) {
        loadingFavorites = YES;
        [source getPhotoFavorites:photo_id 
                         delegate:self 
                didFinishSelector:@selector(getPhotoFavorites:didFinishWithData:) 
                  didFailSelector:@selector(getPhotoFavorites:didFailWithError:)];
    }
    
    if (!comments && !loadingComments) {
        loadingComments = YES;
        [source getPhotoComments:photo_id 
                        delegate:self 
               didFinishSelector:@selector(getPhotoComments:didFinishWithData:) 
                 didFailSelector:@selector(getPhotoComments:didFailWithError:)];
    }
    
    if (!datePostedString) {
        [self datePostedString];
    }
}

- (BOOL)isReady
{
    if (image && comments && favorites) {
        return YES;
    }
    
    return NO;
}

- (void)cancel
{
    if(connection) {
        [connection cancel];
        loadingImage = NO;
        loadingComments = NO;
        loadingFavorites = NO;
        if(!image) {
            imageData = nil;
        }
    }
}



- (NSNumber *)aspect_ratio
{
    if(aspect_ratio) {
        return aspect_ratio;
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
            
            int availableWidth = [EMTLPhotoCell favoritesStringWidth] - 5;
            UIFont *theFont = [EMTLPhotoCell favoritesFont];
            int totalLikes = favorites.count;
                    
            NSString *prefix = @"Liked by ";
            NSString *suffix = [NSString stringWithFormat:@" and %i others", totalLikes];
            
            int sizeUsedWithoutSuffix = [prefix sizeWithFont:theFont].width;
            int sizeUsedWithSuffix = sizeUsedWithoutSuffix + [suffix sizeWithFont:theFont].width;
            
            int i = 0;
            NSMutableArray *namesWithSuffix = [NSMutableArray arrayWithCapacity:4];
            NSMutableArray *namesWithoutSuffix = [NSMutableArray arrayWithCapacity:5];
            
            if([photo_id isEqualToString:@"6899018088"] ) {
                NSLog(@"found it");
            }
            
            // First we need to see what we can fit on the line.
            while (i < favorites.count) {
                NSString *nameString;
                
                // Construct the string that would be added.
                if (i == 0) {
                    nameString = [[favorites objectAtIndex:0] username];
                }
                else {
                    nameString = [NSString stringWithFormat:@", %@", [[favorites objectAtIndex:i] username]];
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



- (void)connectionDidFinishLoading:(NSURLConnection *)theConnection
{
    image = [UIImage imageWithData:imageData];
    loadingImage = NO;
    connection = nil;
    imageData = nil;
    if(container) {
        [container setProgressValue:100];
        [container setImage:image];
    }
    
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    expectingBytes = response.expectedContentLength;
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [imageData appendData:data];
    
    currentPercent += (((float)data.length)/(float)expectingBytes) * 80;
    [container setProgressValue:currentPercent];
    
}

- (void)connection:(NSURLConnection *)theConnection didFailWithError:(NSError *)error
{
    NSLog(@"Failed to download %@", photo_id);
    //NSLog(error.localizedDescription);
    loadingImage = NO;
    connection = nil;
    imageData = nil;
}





- (void)getPhotoFavorites:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    
    dispatch_async(queue, ^{
        if(ticket.didSucceed) {
            favorites = [[source extractFavorites:data forPhoto:self] mutableCopy];
            currentPercent += 10;
            [self favoritesShortString];
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                [container setProgressValue:currentPercent];
                [container setFavoritesString:favoritesShortString];
                [container setFavorites:favorites];
                //NSLog(@"got favorites for %@", photo_id);
            });
            
            
        }
        else {
            NSLog(@"There was an error getting favorites.");
        }
        loadingFavorites = NO;
            
        
    });
    
    
    
    
}

- (void)getPhotoFavorites:(OAServiceTicket *)ticket didFailWithError:(NSError *)error
{
    NSLog(@"Failed to get favorites.");
    loadingFavorites = NO;
}

- (void)getPhotoComments:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    
    dispatch_async(queue, ^{
        if (ticket.didSucceed) {
            comments = [[source extractComments:data] mutableCopy];
            currentPercent += 10;
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                [container setProgressValue:currentPercent];
                [container setCommentsString:[self commentsShortString]];
                [container setComments:comments];
                //NSLog(@"got comments for %@", photo_id);
            });
            
            
        }
        else {
            NSLog(@"There was an error getting comments.");
        }
        
        loadingComments = NO;
            
        
    });
    
    
    //[self setupImageAnimated:YES];
    
}

- (void)getPhotoComments:(OAServiceTicket *)ticket didFailWithError:(NSError *)error
{
    NSLog(@"Failed to get favorites.");
    loadingComments = NO;
}






@end
