//
//  EMTLPhotoSource.h
//  Flickrgram
//
//  Created by Ian White on 4/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OAConsumer.h"
#import "OAToken.h"
#import "OAServiceTicket.h"
#import "OADataFetcher.h"
#import "OAMutableURLRequest.h"

@class EMTLPhoto;
@protocol PhotoSource;

@protocol Authorizable <NSObject>

- (void)photoSource:(id <PhotoSource>)photoSource requiresAuthorizationAtURL:(NSURL *)url;
- (void)authorizationCompleteForPhotoSource:(id <PhotoSource>)photoSource;
- (void)authorizationErrorForPhotoSource:(id <PhotoSource>)photoSource;

@end

@protocol PhotoConsumer <NSObject>

- (void)photoSource:(id <PhotoSource>)photoSource retreivedMorePhotos:(NSArray *)photoArray;
- (void)photoSource:(id <PhotoSource>)photoSource encounteredAnError:(NSError *)error;

@end


static NSString *const kPhotoUsername = @"user_name";
static NSString *const kPhotoUserID = @"user_id";
static NSString *const kPhotoTitle = @"photo_title";
static NSString *const kPhotoID = @"photo_id";
static NSString *const kPhotoImageURL = @"image_url";
static NSString *const kPhotoImageAspectRatio = @"aspect_ratio";
static NSString *const kPhotoDatePosted = @"date_posted";
static NSString *const kPhotoDateUpdated = @"date_updated";

static NSString *const kCacheCommentsDomain = @"comments_domain";
static NSString *const kCacheFavoritesDomain = @"favorites_domain";
static NSString *const kCacheImageDomain = @"image_domain";

static NSString *const kCommentText = @"comment_text";
static NSString *const kCommentDate = @"comment_date";
static NSString *const kCommentUsername = @"user_name";
static NSString *const kCommentUserID = @"user_id";
static NSString *const kCommentIconURL = @"icon_url";

static NSString *const kFavoriteDate = @"favorite_date";
static NSString *const kFavoriteUsername = @"user_name";
static NSString *const kFavoriteUserID = @"user_id";
static NSString *const kFavoriteIconURL = @"icon_url";

    
@protocol PhotoSource <NSObject>

@property (nonatomic, assign) id <Authorizable> delegate;
@property (nonatomic, assign) id <PhotoConsumer> photoDelegate;
@property (readonly, nonatomic, strong) NSString *key;

@property (readonly, strong) NSString *user_id;
@property (readonly, strong) NSString *username;

- (void)authorize;
- (void)authorizedWithVerifier:(NSString *)verfier;
- (void)morePhotos;


@end
