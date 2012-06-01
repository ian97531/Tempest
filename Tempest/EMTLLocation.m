//
//  EMTLLocation.m
//  Tempest
//
//  Created by Ian White on 6/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EMTLLocation.h"

@implementation EMTLLocation

@synthesize name;
@synthesize type;
@synthesize woe_id;
@synthesize latitude;
@synthesize longitude;


- (id)init
{
    self = [super init];
    if (self)
    {
        name = @"";
        type = EMTLLocationUndefined;
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        name = [aDecoder decodeObjectForKey:@"name"];
        type = [aDecoder decodeIntForKey:@"type"];
        woe_id = [aDecoder decodeObjectForKey:@"woe_id"];
        latitude = [aDecoder decodeFloatForKey:@"latitude"];
        longitude = [aDecoder decodeFloatForKey:@"longitude"];
    }
    return self;
    
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:name forKey:@"name"];
    [aCoder encodeInt:type forKey:@"type"];
    [aCoder encodeObject:woe_id forKey:@"woe_id"];
    [aCoder encodeFloat:latitude forKey:@"latitude"];
    [aCoder encodeFloat:longitude forKey:@"longitude"];
}


@end
