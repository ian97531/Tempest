//
//  EMTLFlickrFetchPhotoListOperation.h
//  Tempest
//
//  Created by Ian White on 5/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EMTLFlickrPhotoSource;
@class EMTLPhotoList;

@interface EMTLFlickrFetchPhotoListOperation : NSOperation <NSURLConnectionDataDelegate>
{
    EMTLPhotoList *_photoList;
    EMTLFlickrPhotoSource *_photoSource;
    NSString *_identifier;
    NSURLConnection *_connection;
    NSURLRequest *_request;
    NSMutableData *_incomingData;
    uint _totalSize;
    NSDictionary *_query;
    BOOL _executing;
    BOOL _finished;
}

@property (nonatomic, strong, readonly) EMTLPhotoList *photoList;
@property (nonatomic, strong, readonly) EMTLFlickrPhotoSource *photoSource;
@property (nonatomic, strong, readonly) NSString *identifier;

- (id)initWithPhotoList:(EMTLPhotoList *)photoList photoSource:(EMTLFlickrPhotoSource *)photoSource request:(NSURLRequest *)request query:(NSDictionary *)query;

- (void)connection:(NSURLConnection *)aConnection didReceiveResponse:(NSURLResponse *)aResponse;
- (void)connection:(NSURLConnection *)aConnection didFailWithError:(NSError *)error;
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;

- (void)start;
- (BOOL)isConcurrent;
- (BOOL)isExecuting;
- (BOOL)isFinished;

@end
