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
@synthesize urlToImage;

- (id)initWithDate:(NSDate *)date url:(NSURL *)url
{
    self = [super self];
    if (self)
    {
        datePosted = date;
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
        urlToImage = [aDecoder decodeObjectForKey:@"urlToImage"];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:datePosted forKey:@"datePosted"];
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

@end
