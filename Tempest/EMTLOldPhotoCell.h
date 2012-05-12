//
//  EMTLPhotoCell.h
//  Flickrgram
//
//  Created by Ian White on 4/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EMTLPhoto.h"
#import "EMTLCache.h"

@class EMTLProgressIndicatorViewController;


@interface EMTLOldPhotoCell : UITableViewCell <EMTLPhotoDelegate, EMTLCacheClient>
{
    EMTLCacheRequest *imageRequest;
    BOOL fadeContents;
}

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *cardImageView;
@property (nonatomic, strong) UIView *cardView;
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIView *backgroundGutter;
@property (nonatomic, strong) UILabel *ownerLabel;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UIButton *favoritesButton;
@property (nonatomic, strong) UIButton *commentsButton;

@property (nonatomic, strong) EMTLPhoto* photo;
@property (nonatomic, strong) EMTLProgressIndicatorViewController *indicator;

- (void)loadPhoto:(EMTLPhoto *)photo;
- (void)switchToFavoritesView;

// EMTLPhotoDelegate methods
- (void)setFavoritesString:(NSString *)favoritesString;
- (void)setCommentsString:(NSString *)commentsString;

+ (float)favoritesStringWidth;
+ (UIFont *)favoritesFont;
+ (float)commentsStringWidth;
+ (UIFont *)commentsFont;

// EMTLCacheClient methods
- (void)retrievedObject:(id)object ForRequest:(EMTLCacheRequest *)request;
- (void)fetchedBytes:(int)bytes ofTotal:(int)total forRequest:(EMTLCacheRequest *)request;
- (void)unableToRetrieveObjectForRequest:(EMTLCacheRequest *)request;

@end
