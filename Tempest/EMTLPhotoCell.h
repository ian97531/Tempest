//
//  EMTLPhotoCell.h
//  Flickrgram
//
//  Created by Ian White on 4/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EMTLProgressIndicatorViewController;


@interface EMTLPhotoCell : UITableViewCell
{
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
@property (nonatomic, strong) UIProgressView *progressBar;


- (void)setFavoritesString:(NSString *)favoritesString;
- (void)setCommentsString:(NSString *)commentsString;
- (void)setImage:(UIImage *)image animated:(BOOL)animated;



@end
