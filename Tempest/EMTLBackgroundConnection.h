//
//  EMTLBackgroundConnection.h
//  Berzerk
//
//  Created by Ian White on 6/4/12.
//  Copyright (c) 2012 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EMTLBackgroundConnection : NSURLConnection
{
    NSRunLoop *_runLoop;
}

+ (EMTLBackgroundConnection *)connectionWithRequest:(NSURLRequest *)request delegate:(id)delegate;
- (id)initWithRequest:(NSURLRequest *)request delegate:(id <NSURLConnectionDelegate>)delegate;
- (id)initWithRequest:(NSURLRequest *)request delegate:(id)delegate startImmediately:(BOOL)startImmediately;


- (void)start;

@end
