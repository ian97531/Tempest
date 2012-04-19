//
//  EMTLPhotoCell.h
//  Flickrgram
//
//  Created by Ian White on 4/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EMTLPhoto;

@interface EMTLPhotoCell : UITableViewCell

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *ownerLabel;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic) BOOL isFavorite;
@property (nonatomic) int numFavorites;
@property (nonatomic) int numComments;
@property (nonatomic, strong) EMTLPhoto* photo;

- (void)setImage:(UIImage *)image animated:(BOOL)animated;


@end
