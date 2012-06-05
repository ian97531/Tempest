//
//  EMTLDownloadOperation.h
//  Tempest
//
//  Created by Ian White on 6/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EMTLBackgroundConnection;

@interface EMTLDownloadOperation : NSOperation <NSURLConnectionDataDelegate>
{    
    EMTLBackgroundConnection *_connection;
    NSMutableData *_incomingData;
    uint _totalSize;
    BOOL _executing;
    BOOL _finished;
}

- (id)init;

// NSURLConnectionDataDelegate methods
- (void)connection:(NSURLConnection *)aConnection didReceiveResponse:(NSURLResponse *)aResponse;
- (void)connection:(NSURLConnection *)aConnection didFailWithError:(NSError *)error;
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;

- (void)startRequest:(NSURLRequest *)request;
- (BOOL)isConcurrent;
- (BOOL)isExecuting;
- (BOOL)isFinished;

@end
