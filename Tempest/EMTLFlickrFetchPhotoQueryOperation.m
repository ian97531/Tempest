//
//  EMTLFlickrFetchPhotoListOperation.m
//  Tempest
//
//  Created by Ian White on 5/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EMTLFlickrFetchPhotoListOperation.h"
#import "EMTLFlickrPhotoSource.h"
#import "EMTLPhotoList.h"
#import "APISecrets.h"



@implementation EMTLFlickrFetchPhotoListOperation

@synthesize photoList = _photoList;
@synthesize photoSource = _photoSource;
@synthesize identifier = _identifier;

- (id)initWithPhotoList:(EMTLPhotoList *)photoList photoSource:(EMTLFlickrPhotoSource *)photoSource request:(NSURLRequest *)request query:(NSDictionary *)query;
{
    self = [super init];
    if (self)
    {
        _photoList = photoList;
        _photoSource = photoSource;
        _request = request;
        _query = query;
        _identifier = [query objectForKey:kFlickrQueryIdentifier];
        _executing = NO;
        _finished = NO;
        _incomingData = [NSMutableData data];
        _totalSize = 0;
    }
    
    return self;
    
}

- (void)connection:(NSURLConnection *)aConnection didReceiveResponse:(NSURLResponse *)aResponse
{
    _totalSize = (uint)aResponse.expectedContentLength;
}

- (void)connection:(NSURLConnection *)aConnection didFailWithError:(NSError *)error
{
    // Figure out something good to do here.
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_incomingData appendData:data];
    float percent = (float)data.length/(float)_totalSize;
    [_photoSource operation:self isFetchingDataWithProgress:percent forPhotoList:_photoList];
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [_photoSource operation:self fetchedData:_incomingData forPhotoList:_photoList withQuery:_query];
}

- (void)start
{
    _executing = YES;
    _finished = NO;
    _connection = [NSURLConnection connectionWithRequest:_request delegate:self];
    
}

- (void)cancel
{
    [_connection cancel];
    _executing = NO;
    _finished = YES;
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




- (NSDictionary *)_updateQueryArguments:(NSDictionary *)arguments
{
    return nil;
}


@end
