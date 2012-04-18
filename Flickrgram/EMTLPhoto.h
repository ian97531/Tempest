//
//  EMTLPhoto.h
//  Flickrgram
//
//  Created by Ian White on 4/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMTLPhotoSource.h"

@interface EMTLPhoto : NSObject <NSURLConnectionDataDelegate>

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
@property (nonatomic, strong) UIImageView *container;
@property (strong, readonly) id <PhotoSource> source;
@property (nonatomic, strong) NSMutableData *imageData;

- (id)initWithDict:(NSDictionary *)dict;
- (void)loadPhotoIntoImage:(UIImageView *)imageView;

// NSURLConnectionDelegate method
- (void)connectionDidFinishDownloading:(NSURLConnection *)connection destinationURL:(NSURL *)destinationURL;
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;


@end
