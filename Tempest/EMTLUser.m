//
//  EMTLUser.m
//  Tempest
//
//  Created by Ian White on 6/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EMTLUser.h"

@implementation EMTLUser

@synthesize userID;
@synthesize username;
@synthesize real_name;
@synthesize location;
@synthesize icon;
@synthesize iconURL;

@synthesize numberOfPhotos;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    
    self = [super init];
    if (self)
    {
        userID = [aDecoder decodeObjectForKey:@"userID"];
        username = [aDecoder decodeObjectForKey:@"username"];
        real_name = [aDecoder decodeObjectForKey:@"real_name"];
        location = [aDecoder decodeObjectForKey:@"location"];
        icon = [aDecoder decodeObjectForKey:@"icon"];
        iconURL = [aDecoder decodeObjectForKey:@"iconURL"];
        numberOfPhotos = [aDecoder decodeIntForKey:@"numberOfPhotos"];
    }
    
    return self;
}


- (void)encodeWithCoder:(NSCoder *)aCoder 
{
    [aCoder encodeObject:userID forKey:@"userID"];
    [aCoder encodeObject:username forKey:@"username"];
    [aCoder encodeObject:real_name forKey:@"real_name"];
    [aCoder encodeObject:location forKey:@"location"];
    [aCoder encodeObject:icon forKey:@"icon"];
    [aCoder encodeObject:iconURL forKey:@"iconURL"];
    [aCoder encodeInt:numberOfPhotos forKey:@"numberOfPhotos"];
    
}


- (UIImage *)loadImageWithSize:(EMTLImageSize)size delegate:(id<EMTLUserIconDelegate>)delegate
{
    _delegate = delegate;
    return nil;
}

@end
