//
//  EMTLPhoto.m
//  Flickrgram
//
//  Created by Ian White on 4/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EMTLPhoto.h"
#import "EMTLPhotoCell.h"

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

- (id)initWithDict:(NSDictionary *)dict
{
    self = [super init];
    if(self) {
        
        loading = NO;
        
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


- (void)loadPhotoIntoCell:(EMTLPhotoCell *)cell
{
    
    container = cell;
    cell.photo = self;
    if (!image && !loading) { 
        [self loadImage];
    }
    else {
        [container setImage:image animated:NO];
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
        [container setImage:image animated:YES];
    }
    
}




- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [imageData appendData:data];
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
    
    int dateYear = [dateComponents year];
    
    if (nowYear == dateYear)
    {
        [dateFormat setDateFormat:@"MMM d"];
    }
    else {
        [dateFormat setDateFormat:@"MMM d, y"];
    }
    
    return [dateFormat stringFromDate:self.datePosted];
    
}






@end
