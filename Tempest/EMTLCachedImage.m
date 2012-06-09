//
//  EMTLCachedImage.m
//  Tempest
//
//  Created by Ian White on 5/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EMTLCachedImage.h"

@implementation EMTLCachedImage

@synthesize datePosted;
@synthesize dateCached;
@synthesize urlToImage;

- (id)initWithDate:(NSDate *)date url:(NSURL *)url
{
    self = [super self];
    if (self)
    {
        datePosted = date;
        dateCached = [NSDate date];
        urlToImage = url;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super self];
    if (self)
    {
        datePosted = [aDecoder decodeObjectForKey:@"datePosted"];
        dateCached = [aDecoder decodeObjectForKey:@"dateCached"];
        urlToImage = [aDecoder decodeObjectForKey:@"urlToImage"];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:datePosted forKey:@"datePosted"];
    [aCoder encodeObject:dateCached forKey:@"dateCached"];
    [aCoder encodeObject:urlToImage forKey:@"urlToImage"];
}

- (NSString *)filename
{
    return [[urlToImage pathComponents] lastObject];
}

- (NSString *)path
{
    return urlToImage.path;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"Image File: %@\nDate Cached: %@\nDate Posted: %@", urlToImage.path, dateCached, datePosted];
}

@end
