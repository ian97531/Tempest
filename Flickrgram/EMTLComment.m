//
//  EMTLComment.m
//  Flickrgram
//
//  Created by Ian White on 4/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EMTLComment.h"

@implementation EMTLComment

@synthesize comment_id;
@synthesize user_id;
@synthesize username;
@synthesize userIconURL;
@synthesize comment;
@synthesize date;
@synthesize source;

- (id)initWithDict:(NSDictionary *)dict
{
    self = [super init];
    if(self) {
        
        for (NSString *key in dict) {
            if ([key isEqualToString:@"author"]) {
                user_id = [dict objectForKey:@"author"];
            }
            else if ([key isEqualToString:@"authorname"]) {
                username = [dict objectForKey:@"authorname"];
            }
            else if ([key isEqualToString:@"comment"]) {
                comment = [dict objectForKey:@"comment"];
            }
            else if ([key isEqualToString:@"id"]) {
                comment_id = [dict objectForKey:@"id"];
            }
            else if ([key isEqualToString:@"comment_date"]) {
                date = [dict objectForKey:@"comment_date"];
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
