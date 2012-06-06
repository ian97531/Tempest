//
//  EMTLUser.m
//  Tempest
//
//  Created by Ian White on 6/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EMTLUser.h"
#import "EMTLPhotoSource.h"

@implementation EMTLUser

@synthesize userID = _userID;
@synthesize username = _username;
@synthesize real_name = _real_name;
@synthesize location = _location;
@synthesize icon = _icon;
@synthesize date_retrieved = _date_retrieved;

@synthesize source = _source;

- (id)initWIthUserID:(NSString *)userID source:(EMTLPhotoSource *)source
{
    self = [super self];
    if (self)
    {
        _userID = userID;
        _source = source;
    }
    
    return self;
}


#pragma mark -
#pragma mark NSCoding Methods

- (id)initWithCoder:(NSCoder *)aDecoder
{
    
    self = [super init];
    if (self)
    {
        _userID = [aDecoder decodeObjectForKey:@"userID"];
        _username = [aDecoder decodeObjectForKey:@"username"];
        _real_name = [aDecoder decodeObjectForKey:@"real_name"];
        _location = [aDecoder decodeObjectForKey:@"location"];
        _icon = [aDecoder decodeObjectForKey:@"icon"];
        _date_retrieved = [aDecoder decodeObjectForKey:@"date_retrieved"];
    }
    
    return self;
}


- (void)encodeWithCoder:(NSCoder *)aCoder 
{
    [aCoder encodeObject:_userID forKey:@"userID"];
    [aCoder encodeObject:_username forKey:@"username"];
    [aCoder encodeObject:_real_name forKey:@"real_name"];
    [aCoder encodeObject:_location forKey:@"location"];
    [aCoder encodeObject:_icon forKey:@"icon"];
    [aCoder encodeObject:_date_retrieved forKey:@"date_retrieved"];
    
}

#pragma mark -
#pragma mark User Loading

- (void)loadUserWithDelegate:(id<EMTLUserDelegate>)delegate
{
    _delegate = delegate;
    
    [_source loadUser:self withUserID:_userID];

}


#pragma mark -
#pragma mark User Loading Callbacks

- (void)photoSourceWillRequestUser:(EMTLPhotoSource *)source
{
    [_delegate userWillLoad:self];
}

- (void)photoSourceDidLoadUser:(EMTLPhotoSource *)source
{
    [_delegate userDidLoad:self];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ (%@): %@", _source.serviceName, _userID, _username];
}

@end
