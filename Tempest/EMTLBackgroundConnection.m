//
//  EMTLBackgroundConnection.m
//  Berzerk
//
//  Created by Ian White on 6/4/12.
//  Copyright (c) 2012 Apple Inc. All rights reserved.
//

#import "EMTLBackgroundConnection.h"

@implementation EMTLBackgroundConnection



+ (EMTLBackgroundConnection *)connectionWithRequest:(NSURLRequest *)request delegate:(id)delegate
{
    return [[EMTLBackgroundConnection alloc] initWithRequest:request delegate:delegate];
}


- (id)initWithRequest:(NSURLRequest *)request delegate:(id <NSURLConnectionDelegate>)delegate
{
    self = [super initWithRequest:request delegate:delegate];
    if (self)
    {
        [self _setupRunLoop];
    }
    return self;
}

- (id)initWithRequest:(NSURLRequest *)request delegate:(id)delegate startImmediately:(BOOL)startImmediately
{
    self = [super initWithRequest:request delegate:delegate startImmediately:startImmediately];
    if (self)
    {
        [self _setupRunLoop];
    }
    return self;
}


- (void)start
{
    // Make sure the runloop is running when we start the connection.
    [super start];
    [_runLoop run];
}


- (void)_setupRunLoop
{
    // Open a port on the current runloop and schedule this connection in thtat runloop.
    NSPort* port = [NSPort port];
    _runLoop = [NSRunLoop currentRunLoop];
    [_runLoop addPort:port forMode:NSDefaultRunLoopMode];
    [self scheduleInRunLoop:_runLoop forMode:NSDefaultRunLoopMode];
}


@end
