//
//  EMTLPhoto.h
//  Flickrgram
//
//  Created by Ian White on 4/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMTLPhotoSource.h"
#import "EMTLPhotoCell.h"

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
@property (nonatomic, strong) EMTLPhotoCell *container;
@property (nonatomic, strong) id <PhotoSource> source;
@property (nonatomic, strong) NSMutableData *imageData;

- (id)initWithDict:(NSDictionary *)dict;
- (void)loadPhotoIntoCell:(EMTLPhotoCell *)cell;
- (NSString *)datePostedString;
- (NSString *)dateTakenString;

// NSURLConnectionDelegate method
- (void)connectionDidFinishDownloading:(NSURLConnection *)connection destinationURL:(NSURL *)destinationURL;
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;


@end
