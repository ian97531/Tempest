//
//  EMTLPhoto.h
//  Flickrgram
//
//  Created by Ian White on 4/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMTLPhotoSource.h"

@protocol EMTLPhotoDelegate <NSObject>

- (void)setImage:(UIImage *)image;
- (void)setFavoritesString:(NSString *)favoritesString;
- (void)setCommentsString:(NSString *)commentsString;
- (void)setFavorites:(NSArray *)favorites;
- (void)setComments:(NSArray *)comments;
- (void)setProgressValue:(float)value;
+ (float)favoritesStringWidth;
+ (UIFont *)favoritesFont;
+ (float)commentsStringWidth;
+ (UIFont *)commentsFont;

@end


@interface EMTLPhoto : NSObject <NSURLConnectionDataDelegate>

{
    BOOL loadingImage;
    BOOL loadingFavorites;
    BOOL loadingComments;
    BOOL loadRequested;
    long long expectingBytes;
}

@property (strong, readonly) NSURL *image_URL;
@property (strong, readonly) NSString *title;
@property (strong, readonly) NSString *user_id;
@property (strong, readonly) NSString *username;
@property (strong, readonly) NSString *description;
@property (strong, readonly) NSDate *datePosted;
@property (strong, readonly) NSDate *dateUpdated;
@property (strong, readonly) NSString *photo_id;
@property (strong, readonly) UIImage *image;
@property (strong, readonly) NSNumber *aspect_ratio;
@property (nonatomic) BOOL isFavorite;
@property (nonatomic, strong) NSMutableArray *favorites;
@property (nonatomic, strong) NSMutableArray *comments;
@property (nonatomic, assign) id <EMTLPhotoDelegate> container;
@property (nonatomic, assign) id <PhotoSource> source;
@property (nonatomic, strong) NSMutableData *imageData;
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSString *favoritesShortString;
@property (nonatomic, strong) NSString *datePostedString;
@property (nonatomic) float currentPercent;

- (id)initWithDict:(NSDictionary *)dict;

- (void)loadData;
- (void)cancel;
- (BOOL)isReady;

- (NSString *)datePostedString;
- (NSString *)favoritesShortString;
- (NSString *)commentsShortString;


- (void)getPhotoFavorites:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data;
- (void)getPhotoFavorites:(OAServiceTicket *)ticket didFailWithError:(NSError *)error;

- (void)getPhotoComments:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data;
- (void)getPhotoComments:(OAServiceTicket *)ticket didFailWithError:(NSError *)error;


// NSURLConnectionDelegate method
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;


@end
