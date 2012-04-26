//
//  EMTLPhoto.h
//  Flickrgram
//
//  Created by Ian White on 4/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMTLPhotoSource.h"
#import "EMTLCache.h"

@protocol EMTLPhotoDelegate <NSObject>

+ (float)favoritesStringWidth;
+ (UIFont *)favoritesFont;
+ (float)commentsStringWidth;
+ (UIFont *)commentsFont;

- (void)setFavoritesString:(NSString *)favoritesString;
- (void)setCommentsString:(NSString *)commentsString;


@end


@interface EMTLPhoto : NSObject <NSURLConnectionDataDelegate, EMTLCacheClient>

{
    EMTLCacheRequest *favoritesRequest;
    EMTLCacheRequest *commentsRequest;
    NSString *favoritesDomain;
    NSString *commentsDomain;

}

@property (nonatomic, strong, readonly) NSURL *imageURL;
@property (nonatomic, strong, readonly) NSString *title;
@property (nonatomic, strong, readonly) NSString *userID;
@property (nonatomic, strong, readonly) NSString *username;
@property (nonatomic, strong, readonly) NSDate *datePosted;
@property (nonatomic, strong, readonly) NSDate *dateUpdated;
@property (nonatomic, strong, readonly) NSString *photoID;
@property (nonatomic, strong, readonly) NSNumber *aspectRatio;
@property (nonatomic, strong, readonly) NSString *imageDomain;
@property (nonatomic, strong, readonly) NSArray *favorites;
@property (nonatomic, strong, readonly) NSArray *comments;
@property (nonatomic, strong, readonly) NSString *favoritesShortString;
@property (nonatomic, strong, readonly) NSString *datePostedString;
@property (nonatomic, readonly) BOOL isFavorite;

@property (nonatomic, assign) id <EMTLPhotoDelegate> container;
@property (nonatomic, assign) id <PhotoSource> source;


- (id)initWithDict:(NSDictionary *)dict;

- (void)preloadData;
- (void)loadData;
- (void)cancel;
- (BOOL)isReady;

- (NSString *)datePostedString;
- (NSString *)favoritesShortString;
- (NSString *)commentsShortString;

// EMTLCacheClient methods
- (void)retrievedObject:(id)object ForRequest:(EMTLCacheRequest *)request;
- (void)fetchedBytes:(int)bytes ofTotal:(int)total forRequest:(EMTLCacheRequest *)request;
- (void)unableToRetrieveObjectForRequest:(EMTLCacheRequest *)request;



@end
