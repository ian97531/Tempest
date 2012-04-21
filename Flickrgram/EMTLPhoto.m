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

@synthesize URL;
@synthesize smallURL;
@synthesize title;
@synthesize user_id;
@synthesize username;
@synthesize description;
@synthesize dateTaken;
@synthesize datePosted;
@synthesize photo_id;
@synthesize image;
@synthesize container;
@synthesize source;
@synthesize imageData;
@synthesize connection;
@synthesize aspect_ratio;
@synthesize numComments;
@synthesize numFavorites;
@synthesize isFavorite;
@synthesize comments;
@synthesize favorites;


- (id)initWithDict:(NSDictionary *)dict
{
    self = [super init];
    if(self) {
        
        loading = NO;
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
            else if ([key isEqualToString:@"description"]) {
                description = [dict objectForKey:@"description"];
            }
            else if ([key isEqualToString:@"id"]) {
                photo_id = [dict objectForKey:@"id"];
            }
            else if ([key isEqualToString:@"url"]) {
                URL = [dict objectForKey:@"url"];
            }
            else if ([key isEqualToString:@"small_url"]) {
                smallURL = [dict objectForKey:@"small_url"];
            }
            else if ([key isEqualToString:@"date_taken"]) {
                dateTaken = [dict objectForKey:@"date_taken"];
            }
            else if ([key isEqualToString:@"date_posted"]) {
                datePosted = [dict objectForKey:@"date_posted"];
            }
            else if ([key isEqualToString:@"aspect_ratio"]) {
                aspect_ratio = [dict objectForKey:@"aspect_ratio"];
            }
            
        }
        
    }
    
    return self;
    
}

- (void)loadImage
{
    if(!image && !loading) {
        loading = YES;
        imageData = [NSMutableData data];
        NSURLRequest *request = [NSURLRequest requestWithURL:smallURL cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:30];
        connection = [NSURLConnection connectionWithRequest:request delegate:self];
        [connection start];
    }

}

- (int)width
{
    if (container) {
        return (int)container.frame.size.width;
    }
    else {
        return 0;
    }
}

- (int)height
{
    if (container) {
        return (int)(container.frame.size.width / self.aspect_ratio.floatValue);
    }
    else {
        return 0;
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


- (void)loadPhotoIntoCell:(EMTLPhotoCell *)cell
{
    
    container = cell;
    cell.photo = self;
    cell.indicator.value = currentPercent;
    if (!image && !loading) { 
        [self loadImage];
    }
    
    
    if (!favorites) {
        [source getPhotoFavorites:photo_id 
                         delegate:self 
                didFinishSelector:@selector(getPhotoFavorites:didFinishWithData:) 
                  didFailSelector:@selector(getPhotoFavorites:didFailWithError:)];
    }
        
    if (!comments) {
        [source getPhotoComments:photo_id 
                        delegate:self 
               didFinishSelector:@selector(getPhotoComments:didFinishWithData:) 
                 didFailSelector:@selector(getPhotoComments:didFailWithError:)];
    }
    
    [self setupImageAnimated:NO];
    
}


- (void)setupImageAnimated:(BOOL)animated
{
    if (image && numComments && numFavorites) {
        [container setImage:image animated:animated];
        container.favoritesLabel.text = [NSString stringWithFormat:@"%i likes", [numFavorites intValue]];
        container.commentsLabel.text = [NSString stringWithFormat:@"%i comments", [numComments intValue]];
    }
    
}

- (void)removeFromCell:(EMTLPhotoCell *)cell 
{
    container = nil;
    if(connection) {
        [connection cancel];
        loading = NO;
        if(!image) {
            imageData = nil;
        }
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)theConnection
{
    image = [UIImage imageWithData:imageData];
    loading = NO;
    connection = nil;
    imageData = nil;
    if(container) {
        container.indicator.value = 100;
        [self setupImageAnimated:YES];
    }
    
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    expectingBytes = response.expectedContentLength;
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [imageData appendData:data];
    
    currentPercent = (((float)imageData.length)/(float)expectingBytes) * 100;
    container.indicator.value = currentPercent;
    
}

- (void)connection:(NSURLConnection *)theConnection didFailWithError:(NSError *)error
{
    NSLog(@"Failed to download %@", photo_id);
    //NSLog(error.localizedDescription);
    loading = NO;
    connection = nil;
    imageData = nil;
}

- (NSString *)dateTakenString 
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *nowComponents = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:now];
    NSDateComponents *dateComponents = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:dateTaken];
    
    int nowYear = [nowComponents year];
        
    int dateYear = [dateComponents year];
        
    if (nowYear == dateYear)
    {
        [dateFormat setDateFormat:@"MMM. d"];
    }
    else {
        [dateFormat setDateFormat:@"MMM. d, y"];
    }
    
    return [dateFormat stringFromDate:self.dateTaken];

}

- (NSString *)datePostedString 
{
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
    
    if(nowYear == dateYear && nowMonth == dateMonth) {
        
        
        
    }
    
    
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
    
    return [dateFormat stringFromDate:self.datePosted];
    
}



- (void)getPhotoFavorites:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data
{
    NSError *error;
    NSLog(@"Got favorites");
    NSDictionary *favoritesDict = [source extractJSON:data fromTicket:ticket withError:&error];
    numFavorites = [NSNumber numberWithInt:[[[favoritesDict objectForKey:@"photo"] objectForKey:@"total"] intValue]];
    [self setupImageAnimated:YES];
    
}

- (void)getPhotoFavorites:(OAServiceTicket *)ticket didFailWithError:(NSError *)error
{
    NSLog(@"Failed to get favorites.");
}

- (void)getPhotoComments:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data
{
    NSError *error;
    NSLog(@"Got comments");
    NSDictionary *commentsDict = [source extractJSON:data fromTicket:ticket withError:&error];
    numComments = [NSNumber numberWithInt:[[[commentsDict objectForKey:@"comments"] objectForKey:@"comment"] count]];
    [self setupImageAnimated:YES];
    
}

- (void)getPhotoComments:(OAServiceTicket *)ticket didFailWithError:(NSError *)error
{
    NSLog(@"Failed to get favorites.");
}






@end
