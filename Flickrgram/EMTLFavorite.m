//
//  EMTLFavorite.m
//  Flickrgram
//
//  Created by Ian White on 4/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EMTLFavorite.h"

@implementation EMTLFavorite

@synthesize user_id;
@synthesize username;
@synthesize userIconURL;
@synthesize date;
@synthesize source;

- (id)initWithDict:(NSDictionary *)dict
{
    self = [super init];
    if(self) {
        
        
        
        for (NSString *key in dict) {
            if ([key isEqualToString:@"nsid"]) {
                user_id = [dict objectForKey:@"nsid"];
            }
            else if ([key isEqualToString:@"username"]) {
                username = [dict objectForKey:@"username"];
            }
            else if ([key isEqualToString:@"favorite_date"]) {
                date = [dict objectForKey:@"favorite_date"];
            }
            else if ([key isEqualToString:@"icon_url"]) {
                userIconURL = [dict objectForKey:@"icon_url"];
            }
        }
        
    }
    
    return self;
}


- (NSURL *)userIconURL
{
    if (userIconURL) {
        return userIconURL;
    }
    else {
        return [source defaultUserIconURL];
    }
}

@end
