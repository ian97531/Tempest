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

#import "UIImage+IWDecompressJPEG.h"

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
    
    [userArgs setObject:EMTLFlickrAPIKey 
                 forKey:EMTLFlickrAPIArgumentAPIKey];
    
    [userArgs setObject:_user.userID
                 forKey:EMTLFlickrAPIArgumentUserID];
    
    
    OAMutableURLRequest *userRequest = [_photoSource oaurlRequestForMethod:EMTLFlickrAPIMethodUserInfo arguments:userArgs];
    
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
        NSDictionary *userDetails = [userDict objectForKey:EMTLFlickrAPIResponseUser];
        
        _user.username = [userDetails objectForKey:EMTLFlickrAPIResponseUserUsername];
        _user.real_name = [userDetails objectForKey:EMTLFlickrAPIResponseUserRealname];
        _user.location = [[userDetails objectForKey:EMTLFlickrAPIResponseUserLocation] 
                          objectForKey:EMTLFlickrAPIResponseContent];
        
        NSString *iconFarm = [userDetails objectForKey:EMTLFlickrAPIResponseUserIconFarm];
        NSString *iconServer = [userDetails objectForKey:EMTLFlickrAPIResponseUserIconServer];
        
        if(iconFarm && iconServer)
        {
            _user.iconURL = [NSURL URLWithString:[NSString stringWithFormat:EMTLFlickrUserIconURLFormat, iconFarm, iconServer, _user.userID]];
        }
        else 
        {
            _user.iconURL = [NSURL URLWithString:EMTLFlickrDefaultIconURLString];
        }
        
        
        // Grab the icon
        NSURLResponse *response;
        NSError *error;
        NSURLRequest *iconRequest = [NSURLRequest requestWithURL:_user.iconURL cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:10.0];
        NSData *iconData = [NSURLConnection sendSynchronousRequest:iconRequest returningResponse:&response error:&error];
        
        if(!error) {
            _user.icon = [UIImage decompressImageWithData:iconData];
        }
        else {
            NSLog(@"Could not load the icon for user %@", _user.username);
        }
        
        NSLog(@"Got user");

    }

}


@end
