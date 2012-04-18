//
//  EMTLPhoto.m
//  Flickrgram
//
//  Created by Ian White on 4/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EMTLPhoto.h"

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

- (id)initWithDict:(NSDictionary *)dict
{
    self = [super init];
    if(self) {
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
        }
        
    }
    
    return self;
    
}

- (void)loadImage
{
    if(!image) {
        imageData = [NSMutableData data];
        NSURLRequest *request = [NSURLRequest requestWithURL:smallURL cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:30];
        NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
        [connection start];
    }
}


- (void)loadPhotoIntoImage:(UIImageView *)imageView
{
    
    container = imageView;
    if (!image) { 
        [self loadImage];
    }
    else {
        container.image = image;
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)theConnection
{
    image = [UIImage imageWithData:imageData];
    if(container) {
        container.image = image;
    }
    
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [imageData appendData:data];
}






@end
