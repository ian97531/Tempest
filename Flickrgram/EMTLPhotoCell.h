//
//  EMTLPhotoCell.h
//  Flickrgram
//
//  Created by Ian White on 4/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EMTLPhoto;
@class EMTLProgressIndicatorViewController;

@interface EMTLPhotoCell : UITableViewCell

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIView *cardView;
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIView *backgroundGutter;
@property (nonatomic, strong) UILabel *ownerLabel;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UILabel *commentsLabel;
@property (nonatomic, strong) UILabel *favoritesLabel;

@property (nonatomic) BOOL isFavorite;
@property (nonatomic) int numFavorites;
@property (nonatomic) int numComments;
@property (nonatomic, strong) EMTLPhoto* photo;
@property (nonatomic, strong) EMTLProgressIndicatorViewController *indicator;

- (void)setImage:(UIImage *)image animated:(BOOL)animated;
- (void)setImageHeight:(int)height;
- (void)setFavorites:(NSArray *)favorites animated:(BOOL)animated;
- (void)setComments:(NSArray *)comments animated:(BOOL)animated;

@end
