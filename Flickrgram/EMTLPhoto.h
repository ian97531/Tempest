//
//  EMTLPhoto.h
//  Flickrgram
//
//  Created by Ian White on 4/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMTLPhotoSource.h"

@class EMTLPhotoCell;

@interface EMTLPhoto : NSObject <NSURLConnectionDataDelegate>

{
    BOOL loading;
    long long expectingBytes;
    float currentPercent;
}

@property (strong, readonly) NSURL *URL;
@property (strong, readonly) NSURL *smallURL;
@property (strong, readonly) NSString *title;
@property (strong, readonly) NSString *user_id;
@property (strong, readonly) NSString *username;
@property (strong, readonly) NSString *description;
@property (strong, readonly) NSDate *dateTaken;
@property (strong, readonly) NSDate *datePosted;
@property (strong, readonly) NSString *photo_id;
@property (strong, readonly) UIImage *image;
@property (strong, readonly) NSNumber *aspect_ratio;
@property (nonatomic, strong) EMTLPhotoCell *container;
@property (nonatomic, strong) id <PhotoSource> source;
@property (nonatomic, strong) NSMutableData *imageData;
@property (nonatomic, strong) NSURLConnection *connection;

- (id)initWithDict:(NSDictionary *)dict;
- (void)loadImage;
- (void)loadPhotoIntoCell:(EMTLPhotoCell *)cell;
- (void)removeFromCell:(EMTLPhotoCell *)cell;
- (NSString *)datePostedString;
- (NSString *)dateTakenString;
- (int)width;
- (int)height;


// NSURLConnectionDelegate method
- (void)connectionDidFinishDownloading:(NSURLConnection *)connection destinationURL:(NSURL *)destinationURL;
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;


@end
