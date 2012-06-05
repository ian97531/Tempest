//
//  EMTLDownloadOperation.m
//  Tempest
//
//  Created by Ian White on 6/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EMTLDownloadOperation.h"
#import "EMTLBackgroundConnection.h"

@implementation EMTLDownloadOperation

- (id)init
{
    self = [super init];
    if (self)
    {
        _incomingData = [NSMutableData data];
        _totalSize = 0;
        
        _executing = NO;
        _finished = NO;
    }
    return self;
}

#pragma mark -
#pragma mark NSURLConnectionDataDelegate Methods

- (void)connection:(NSURLConnection *)aConnection didReceiveResponse:(NSURLResponse *)aResponse
{
    _totalSize = (uint)aResponse.expectedContentLength;
}


- (void)connection:(NSURLConnection *)aConnection didFailWithError:(NSError *)error
{
    
    [self willChangeValueForKey:@"isExecuting"];
    _executing = NO;
    [self didChangeValueForKey:@"isExecuting"];
    
    [self willChangeValueForKey:@"isFinished"];
    _finished = YES;
    [self didChangeValueForKey:@"isFinished"];
    
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_incomingData appendData:data];
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self willChangeValueForKey:@"isExecuting"];
    _executing = NO;
    [self didChangeValueForKey:@"isExecuting"];
    
    [self willChangeValueForKey:@"isFinished"];
    _finished = YES;
    [self didChangeValueForKey:@"isFinished"];
}


#pragma mark -
#pragma mark NSOperation Subclass Methods

- (void)startRequest:(NSURLRequest *)request;
{
    if (_finished) {
        return;
    }
    
    [self willChangeValueForKey:@"isExecuting"];
    _executing = YES;
    [self didChangeValueForKey:@"isExecuting"];
        
    _connection = [EMTLBackgroundConnection connectionWithRequest:request delegate:self];
    [_connection start];
    
}



- (void)cancel
{
    
    [_connection cancel];
    
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


@end
