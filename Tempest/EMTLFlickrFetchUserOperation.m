//
//  EMTLFlickrFetchUserOperation.m
//  Tempest
//
//  Created by Ian White on 6/4/12.
//  Copyright (c) 2012 Apple Inc. All rights reserved.
//

#import "EMTLFlickrFetchUserOperation.h"
#import "EMTLFlickrPhotoSource.h"
#import "EMTLUser.h"

@implementation EMTLFlickrFetchUserOperation

- (id)initWithPhoto:(EMTLUser *)user photoSource:(EMTLFlickrPhotoSource *)photoSource
{
    self = [super init];
    if (self) {
        _user = user;
        _photoSource = photoSource;
    }
    
    return self;
    
    
}


- (void)start
{
    if (_finished) {
        return;
    }
    
    [self willChangeValueForKey:@"isExecuting"];
    _executing = YES;
    [self didChangeValueForKey:@"isExecuting"];
    
    NSMutableDictionary *userArgs = [NSMutableDictionary dictionaryWithCapacity:4];
    
    [userArgs setObject:kFlickrAPIKey 
                 forKey:kFlickrAPIArgumentAPIKey];
    
    [userArgs setObject:_user.userID
                 forKey:kFlickrAPIArgumentUserID];
    
    
    OAMutableURLRequest *userRequest = [_photoSource oaurlRequestForMethod:kFlickrAPIMethodUserInfo arguments:userArgs];
    
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *userData = [NSURLConnection sendSynchronousRequest:userRequest returningResponse:&response error:&error];
    
    [self _processUserResponse:userData];
    
    [self willChangeValueForKey:@"isExecuting"];
    _executing = NO;
    [self didChangeValueForKey:@"isExecuting"];
    
    [self willChangeValueForKey:@"isFinished"];
    _finished = YES;
    [self didChangeValueForKey:@"isFinished"];
    
    
}

- (void)cancel
{
    
    [self willChangeValueForKey:@"isExecuting"];
    _executing = NO;
    [self didChangeValueForKey:@"isExecuting"];
    
    [self willChangeValueForKey:@"isFinished"];
    _finished = YES;
    [self didChangeValueForKey:@"isFinished"];
}

- (BOOL)isConcurrent
{
    return YES;
}

- (BOOL)isExecuting
{
    return _executing;
}

- (BOOL)isFinished
{
    return _finished;
}


- (void)_processUserResponse:(NSData *)userData
{
    NSDictionary *userDict = [_photoSource dictionaryFromResponseData:userData];
    
    if(!userDict) {
        NSLog(@"There was an error interpreting the json response for user from %@", _user.userID);
    }
    
    else {
        NSDictionary *userDetails = [userDict objectForKey:@"person"];
        
        _user.username = [userDetails objectForKey:@"username"];
        _user.real_name = [userDetails objectForKey:@"realname"];
        _user.location = [[userDetails objectForKey:@"location"] objectForKey:@"_content"];
        
        NSString *iconFarm = [userDetails objectForKey:@"iconfarm"];
        NSString *iconServer = [userDetails objectForKey:@"iconserver"];
        NSURL *iconURL;
        if (![iconFarm isEqualToString:@"0"] && ![iconServer isEqualToString:@"0"]) {
            NSString *iconURL = [NSString stringWithFormat:@"http://farm%@.staticflickr.com/%@buddyicons/%@.jpg", iconFarm, iconServer, _user.userID];
            iconURL = [NSURL URLWithString:iconURL];
        }
        else {
            iconURL = [NSURL URLWithString:kFlickrDefaultIconURLString];
        }
        
        // Grab the icon
        NSURLResponse *response;
        NSError *error;
        NSURLRequest *iconRequest = [NSURLRequest requestWithURL:iconURL cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:10.0];
        NSData *iconData = [NSURLConnection sendSynchronousRequest:iconRequest returningResponse:&response error:&error];
        
        if(!error) {
            _user.icon = [UIImage imageWithData:iconData];
            UIGraphicsBeginImageContext(CGSizeMake(_user.icon.size.width, _user.icon.size.height));
            [_user.icon drawAtPoint:CGPointZero];
            UIGraphicsEndImageContext();
        }
        else {
            NSLog(@"Could not load the icon for user %@", _user.username);
        }
        
        NSLog(@"Got user");

    }

}


@end
