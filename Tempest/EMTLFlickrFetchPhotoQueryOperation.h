//
//  EMTLFlickrFetchPhotoListOperation.h
//  Tempest
//
//  Created by Ian White on 5/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EMTLFlickrPhotoSource;
@class EMTLPhotoQuery;

@interface EMTLFlickrFetchPhotoQueryOperation : NSOperation <NSURLConnectionDataDelegate>
{
    EMTLPhotoQuery *_photoQuery;
    EMTLFlickrPhotoSource *_photoSource;
    NSURLConnection *_connection;
    NSMutableData *_incomingData;
    NSDictionary *_query;
    uint _totalSize;
    BOOL _executing;
    BOOL _finished;
    
    NSOperationQueue *_commentsAndFavorites;
}

@property (nonatomic, strong, readonly) EMTLPhotoQuery *photoQuery;
@property (nonatomic, strong, readonly) EMTLFlickrPhotoSource *photoSource;
@property (nonatomic, strong, readonly) NSString *identifier;

- (id)initWithPhotoQuery:(EMTLPhotoQuery *)photoQuery photoSource:(EMTLFlickrPhotoSource *)photoSource;

- (void)connection:(NSURLConnection *)aConnection didReceiveResponse:(NSURLResponse *)aResponse;
- (void)connection:(NSURLConnection *)aConnection didFailWithError:(NSError *)error;
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;

- (void)start;
- (BOOL)isConcurrent;
- (BOOL)isExecuting;
- (BOOL)isFinished;

@end
