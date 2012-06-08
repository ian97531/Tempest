//
//  EMTLPhotoCell.h
//  Flickrgram
//
//  Created by Ian White on 4/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EMTLProgressIndicatorViewController;
@class EMTLMagicUserList;

@interface EMTLPhotoCell : UITableViewCell
{
    BOOL fadeContents;
    BOOL _favoriteIndicatorOn;
    BOOL _frontFacingForward;
    NSString *_photoID;
}

@property (nonatomic, strong) UIView *cardView;
@property (nonatomic) BOOL favoriteIndicatorTurnedOn;
@property (nonatomic, strong) NSString *photoID;
@property (nonatomic) BOOL frontFacingForward;
@property (nonatomic, strong) UITapGestureRecognizer *flipGesture;

@property (nonatomic, strong) UIView *frontView;
@property (nonatomic, strong) UIImageView *cardImageView;
@property (nonatomic, strong) UILabel *ownerLabel;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UIView *backgroundGutter;
@property (nonatomic, strong) UIProgressView *progressBar;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) EMTLMagicUserList *favoriteUsers;
@property (nonatomic, strong) UIButton *commentsButton;
@property (nonatomic, strong) UIImageView *favoriteIndicator;
@property (nonatomic, strong) UITapGestureRecognizer *favoriteTapGesture;

@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *dateTakenLabel;
@property (nonatomic, strong) UILabel *locationLabel;
@property (nonatomic, strong) UILabel *descriptionLabel;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

- (void)setCommentsString:(NSString *)commentsString;
- (void)setImage:(UIImage *)image;
- (void)setProgress:(float)progress;
- (void)setFavoriteIndicatorTurnedOn:(BOOL)favoriteState;
- (BOOL)favoriteIndicatorTurnedOn;

- (void)logPhotoID;

@end
