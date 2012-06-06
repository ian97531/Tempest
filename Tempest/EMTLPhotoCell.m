//
//  EMTLPhotoCell.m
//  Flickrgram
//
//  Created by Ian White on 4/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EMTLPhotoCell.h"
#import "EMTLPhoto.h"
#import "EMTLMagicUserList.h"

#import <QuartzCore/QuartzCore.h>

@implementation EMTLPhotoCell

@synthesize imageView;
@synthesize cardImageView;
@synthesize cardView;
@synthesize backgroundView;
@synthesize backgroundGutter;
@synthesize ownerLabel;
@synthesize dateLabel;
@synthesize progressBar;
@synthesize favoriteIndicator;
@synthesize favoriteTapGesture;

@synthesize favoriteUsers;
@synthesize commentsButton;

@synthesize photoID = _photoID;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.contentView.frame = CGRectMake(0, 0, 320, 425);
        
        // Setup photo card
        cardView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 415)];
        cardView.backgroundColor = [UIColor clearColor];
        cardView.autoresizesSubviews = YES;
        [cardView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
        
        
        UIImage *cardImage = [[UIImage imageNamed:@"PolaroidTextured4.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(38, 0, 70, 0)];
        cardImageView = [[UIImageView alloc] initWithImage:cardImage];
        cardImageView.frame = self.cardView.frame;
        [cardImageView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
        [cardView addSubview:cardImageView];
               
        
        backgroundGutter = [[UIView alloc] initWithFrame:CGRectMake(13, 36, 294, 300)];
        backgroundGutter.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
        backgroundGutter.layer.cornerRadius = 2;
        backgroundGutter.layer.masksToBounds = YES;
        backgroundGutter.layer.borderColor = [UIColor colorWithWhite:0.8 alpha:1].CGColor;
        backgroundGutter.layer.borderWidth = 1;
        [backgroundGutter setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
        [cardView addSubview:backgroundGutter];
        
        
        progressBar = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
        progressBar.frame = CGRectMake(0, 0, 180, progressBar.frame.size.height);
        progressBar.center = backgroundGutter.center;
        progressBar.trackTintColor = [UIColor colorWithWhite:0.7 alpha:1];
        [progressBar setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin];
        [cardView addSubview:progressBar];
        
        
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(14, 37, 292, 298)];
        imageView.layer.masksToBounds = YES;
        imageView.opaque = NO;
        imageView.layer.cornerRadius = 2;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.layer.opacity = 0;
        imageView.userInteractionEnabled = YES;
        [imageView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
        [cardView addSubview:imageView];
        
        UITapGestureRecognizer *imageTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(logPhotoID)];
        [imageView addGestureRecognizer:imageTap];
        
        
        dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 13, 170, 20)];
        dateLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:15];
        dateLabel.textColor = [UIColor colorWithWhite:0.3 alpha:1];
        dateLabel.backgroundColor = [UIColor clearColor];
        [dateLabel setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
        [cardView addSubview:dateLabel];
        
        
        ownerLabel = [[UILabel alloc] initWithFrame:CGRectMake(185, 14, 120, 20)];
        ownerLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12];
        ownerLabel.textColor = [UIColor colorWithWhite:0.4 alpha:1];
        ownerLabel.textAlignment = UITextAlignmentRight;
        ownerLabel.layer.masksToBounds = YES;
        ownerLabel.backgroundColor = [UIColor clearColor];
        [dateLabel setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
        [cardView addSubview:ownerLabel];
        
        
        favoriteUsers = [[EMTLMagicUserList alloc] initWithFrame:CGRectMake(52, 350, 250, 20) emtpyString:@"0 Likes"];
        favoriteUsers.prefix = @"Liked by";
        favoriteUsers.numericSuffix = @"likes";
        favoriteUsers.font = [UIFont fontWithName:@"MarkerSD" size:14];
        favoriteUsers.textColor = [UIColor colorWithWhite:0.4 alpha:1];
        [favoriteUsers setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth];
        [cardView addSubview:favoriteUsers];
        
        
        favoriteIndicator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"FavoriteButton_Off.png"]];
        favoriteIndicator.frame = CGRectMake(8, 340, 45, 35);
        favoriteIndicator.userInteractionEnabled = YES;
        [favoriteIndicator setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin];
        [cardView addSubview:favoriteIndicator];
        
        favoriteTapGesture = [[UITapGestureRecognizer alloc] init];
        [favoriteIndicator addGestureRecognizer:favoriteTapGesture];
        
        
        commentsButton = [UIButton buttonWithType:UIButtonTypeCustom];
        commentsButton.frame = CGRectMake(52, 378, 288, 16);
        commentsButton.titleLabel.font = [UIFont fontWithName:@"MarkerSD" size:14];
        [commentsButton setTitleColor:[UIColor colorWithWhite:0.4 alpha:1] forState:UIControlStateNormal];
        [commentsButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [commentsButton setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth];
        [cardView addSubview:commentsButton];
        
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        
        [self.contentView addSubview:cardView];
        
    }
    return self;
}

- (void)logPhotoID
{
    NSLog(@"Photo ID is: %@", _photoID);
}



- (void)prepareForReuse
{

    //imageView.layer.opacity = 0;
    //progressBar.layer.opacity = 1;
    //[favoritesButton setTitle:@"" forState:UIControlStateNormal];
    //[commentsButton setTitle:@"" forState:UIControlStateNormal];

}



- (void)switchToFavoritesView
{


    [UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.6];
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight
						   forView:cardView
							 cache:YES];
    
    [backgroundGutter removeFromSuperview];
    [imageView removeFromSuperview];
    [dateLabel removeFromSuperview];
    [ownerLabel removeFromSuperview];
    //[indicator.view removeFromSuperview];
    [favoriteUsers removeFromSuperview];
    [commentsButton removeFromSuperview];
    

	[UIView commitAnimations];
}



- (void)setImage:(UIImage *)image
{
    // Skip if the image is already set.
    if (image == imageView.image) {
        return;
    }
    
    // Check the state of the image view to see if we need to animate.
    BOOL animate = !imageView.image;
    [imageView setImage:image];
    progressBar.progress = 0;
    
    if(!animate) {
        [UIView animateWithDuration:0.3 animations:^(void) {
            imageView.layer.opacity = 1;
            progressBar.layer.opacity = 0;
        }];
    }
    else {
        imageView.layer.opacity = 1;
        progressBar.layer.opacity = 0;
    }
    
    
}

- (void)setProgress:(float)progress
{
    imageView.alpha = 0;
    progressBar.alpha = 1;
    progressBar.progress = progress;
    NSLog(@"setting progress");
}


- (void)setCommentsString:(NSString *)commentsString
{
    [commentsButton setTitle:commentsString forState:UIControlStateNormal];
    
}



- (void)setFavoriteIndicatorTurnedOn:(BOOL)favoriteState
{
    _favoriteIndicatorOn = favoriteState;
    
    if (_favoriteIndicatorOn) {
        favoriteIndicator.image = [UIImage imageNamed:@"FavoriteButton_On.png"];
    }
    else {
        favoriteIndicator.image = [UIImage imageNamed:@"FavoriteButton_Off.png"];
    }
}

- (BOOL)favoriteIndicatorTurnedOn
{
    return _favoriteIndicatorOn;
}


@end
