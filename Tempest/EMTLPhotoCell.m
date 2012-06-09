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

@synthesize cardView;
@synthesize photoID = _photoID;
@synthesize frontFacingForward = _frontFacingForward;
@synthesize flipGesture;

@synthesize frontView;
@synthesize cardImageView;
@synthesize ownerLabel;
@synthesize dateLabel;
@synthesize backgroundGutter;
@synthesize progressBar;
@synthesize imageView;
@synthesize favoriteIndicator;
@synthesize favoriteTapGesture;
@synthesize favoriteUsers;
@synthesize commentsButton;

@synthesize backView;
@synthesize titleLabel;
@synthesize dateTakenLabel;
@synthesize locationLabel;
@synthesize descriptionLabel;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.contentView.frame = CGRectMake(0, 0, 320, 450);
        
        // Setup photo card
        cardView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 415)];
        cardView.backgroundColor = [UIColor clearColor];
        cardView.autoresizesSubviews = YES;
        [cardView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
        
        flipGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(flipCard)];
        flipGesture.numberOfTapsRequired = 2;
        flipGesture.delaysTouchesBegan = YES;
        [cardView addGestureRecognizer:flipGesture];
        
        
        UIImage *cardImage = [[UIImage imageNamed:@"PolaroidTextured4.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(38, 0, 70, 0)];
        cardImageView = [[UIImageView alloc] initWithImage:cardImage];
        cardImageView.frame = cardView.frame;
        [cardImageView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
        [cardView addSubview:cardImageView];
        
        
        frontView = [[UIView alloc] initWithFrame:cardView.frame];
        frontView.backgroundColor = [UIColor clearColor];
        [frontView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
        [cardView addSubview:frontView];
        
    
        backgroundGutter = [[UIView alloc] initWithFrame:CGRectMake(13, 36, 294, 300)];
        backgroundGutter.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
        backgroundGutter.layer.cornerRadius = 2;
        backgroundGutter.layer.masksToBounds = YES;
        backgroundGutter.layer.borderColor = [UIColor colorWithWhite:0.8 alpha:1].CGColor;
        backgroundGutter.layer.borderWidth = 1;
        [backgroundGutter setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
        [frontView addSubview:backgroundGutter];
        
        
        progressBar = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
        progressBar.frame = CGRectMake(0, 0, 180, progressBar.frame.size.height);
        progressBar.center = backgroundGutter.center;
        progressBar.trackTintColor = [UIColor colorWithWhite:0.7 alpha:1];
        [progressBar setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin];
        [frontView addSubview:progressBar];
        
        
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(14, 37, 292, 298)];
        imageView.layer.masksToBounds = YES;
        imageView.opaque = NO;
        imageView.layer.cornerRadius = 2;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.layer.opacity = 0;
        imageView.userInteractionEnabled = YES;
        [imageView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
        [frontView addSubview:imageView];
        
        UITapGestureRecognizer *imageTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(logPhotoID)];
        [frontView addGestureRecognizer:imageTap];
        
        
        dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 13, 170, 20)];
        dateLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:15];
        dateLabel.textColor = [UIColor colorWithWhite:0.3 alpha:1];
        dateLabel.backgroundColor = [UIColor clearColor];
        [dateLabel setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
        [frontView addSubview:dateLabel];
        
        
        ownerLabel = [[UILabel alloc] initWithFrame:CGRectMake(185, 14, 120, 20)];
        ownerLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12];
        ownerLabel.textColor = [UIColor colorWithWhite:0.4 alpha:1];
        ownerLabel.textAlignment = UITextAlignmentRight;
        ownerLabel.layer.masksToBounds = YES;
        ownerLabel.backgroundColor = [UIColor clearColor];
        [dateLabel setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
        [frontView addSubview:ownerLabel];
        
        
        favoriteUsers = [[EMTLMagicUserList alloc] initWithFrame:CGRectMake(52, 350, 250, 20) emtpyString:@"0 Likes"];
        favoriteUsers.prefix = @"Liked by";
        favoriteUsers.numericSuffix = @"likes";
        favoriteUsers.font = [UIFont fontWithName:@"MarkerSD" size:14];
        favoriteUsers.textColor = [UIColor colorWithWhite:0.4 alpha:1];
        [favoriteUsers setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth];
        [frontView addSubview:favoriteUsers];
        
        
        favoriteIndicator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"FavoriteButton_Off.png"]];
        favoriteIndicator.frame = CGRectMake(8, 340, 45, 35);
        favoriteIndicator.userInteractionEnabled = YES;
        [favoriteIndicator setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin];
        [frontView addSubview:favoriteIndicator];
        
        favoriteTapGesture = [[UITapGestureRecognizer alloc] init];
        [favoriteIndicator addGestureRecognizer:favoriteTapGesture];
        
        
        commentsButton = [UIButton buttonWithType:UIButtonTypeCustom];
        commentsButton.frame = CGRectMake(52, 378, 288, 16);
        commentsButton.titleLabel.font = [UIFont fontWithName:@"MarkerSD" size:14];
        [commentsButton setTitleColor:[UIColor colorWithWhite:0.4 alpha:1] forState:UIControlStateNormal];
        [commentsButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [commentsButton setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth];
        [frontView addSubview:commentsButton];
        
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self.contentView addSubview:cardView];
        _frontFacingForward = YES;
        
        
        backView = [[UIView alloc] initWithFrame:frontView.frame];
        backView.backgroundColor = [UIColor clearColor];
        backView.hidden = YES;
        [backView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
        [cardView addSubview:backView];
        
        UILabel *titleText = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 100, 20)];
        titleText.backgroundColor = [UIColor clearColor];
        titleText.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:15];
        titleText.textColor = [UIColor colorWithWhite:0.3 alpha:1];
        titleText.text = @"Title:";
        [backView addSubview:titleText];
        
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(25, 40, 252, 40)];
        titleLabel.font = [UIFont fontWithName:@"MarkerSD" size:18];
        titleLabel.textColor = [UIColor colorWithWhite:0.4 alpha:1];
        titleLabel.textAlignment = UITextAlignmentLeft;
        titleLabel.layer.masksToBounds = YES;
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.lineBreakMode = UILineBreakModeWordWrap;
        titleLabel.numberOfLines = 0;
        [titleLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [backView addSubview:titleLabel];
        
        UILabel *takenOnText = [[UILabel alloc] initWithFrame:CGRectMake(20, 90, 100, 20)];
        takenOnText.backgroundColor = [UIColor clearColor];
        takenOnText.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:15];
        takenOnText.textColor = [UIColor colorWithWhite:0.3 alpha:1];
        takenOnText.text = @"Taken on:";
        [backView addSubview:takenOnText];
        
        dateTakenLabel = [[UILabel alloc] initWithFrame:CGRectMake(25, 110, 150, 30)];
        dateTakenLabel.font = [UIFont fontWithName:@"MarkerSD" size:18];
        dateTakenLabel.textColor = [UIColor colorWithWhite:0.4 alpha:1];
        dateTakenLabel.textAlignment = UITextAlignmentLeft;
        dateTakenLabel.layer.masksToBounds = YES;
        dateTakenLabel.backgroundColor = [UIColor clearColor];
        [dateTakenLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [backView addSubview:dateTakenLabel];
        
        locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(140, 110, 90, 30)];
        locationLabel.font = [UIFont fontWithName:@"MarkerSD" size:18];
        locationLabel.textColor = [UIColor colorWithWhite:0.4 alpha:1];
        locationLabel.textAlignment = UITextAlignmentLeft;
        locationLabel.layer.masksToBounds = YES;
        locationLabel.backgroundColor = [UIColor clearColor];
        [locationLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [backView addSubview:locationLabel];
        
        
        descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 150, 280, 250)];
        descriptionLabel.font = [UIFont fontWithName:@"MarkerSD" size:14];
        descriptionLabel.textColor = [UIColor colorWithWhite:0.4 alpha:1];
        descriptionLabel.textAlignment = UITextAlignmentLeft;
        descriptionLabel.layer.masksToBounds = YES;
        descriptionLabel.backgroundColor = [UIColor clearColor];
        descriptionLabel.numberOfLines = 0;
        descriptionLabel.lineBreakMode = UILineBreakModeWordWrap;

        [descriptionLabel setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
        [backView addSubview:descriptionLabel];
        
    }
    return self;
}

- (void)logPhotoID
{
    NSLog(@"Photo is: %@", _photoID);
}



- (void)prepareForReuse
{

    //imageView.layer.opacity = 0;
    //progressBar.layer.opacity = 1;
    //[favoritesButton setTitle:@"" forState:UIControlStateNormal];
    //[commentsButton setTitle:@"" forState:UIControlStateNormal];

}



- (void)flipCard
{


    [UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.6];
	
    
    if(_frontFacingForward) {
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight
                               forView:cardView
                                 cache:YES];
        
        frontView.hidden = YES;
        backView.hidden = NO;
        //[frontView removeFromSuperview];
        //[cardView addSubview:backView];
        _frontFacingForward = NO;
        
    }
    else {
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft
                               forView:cardView
                                 cache:YES];
        frontView.hidden = NO;
        backView.hidden = YES;
        //[backView removeFromSuperview];
        //[cardView addSubview:frontView];
        _frontFacingForward = YES;
    }
    

	[UIView commitAnimations];
}


- (void)setFrontFacingForward:(BOOL)frontFacingForward
{
    _frontFacingForward = frontFacingForward;
    
    if(frontFacingForward && backView.superview) {
        //[backView removeFromSuperview];
        //[cardView addSubview:frontView];
        //frontView.frame = cardView.frame;
        frontView.hidden = NO;
        backView.hidden = YES;
    }
    else if (!frontFacingForward && frontView.superview) {
        //[frontView removeFromSuperview];
        //[cardView addSubview:backView];
        //backView.frame = cardView.frame;
        frontView.hidden = YES;
        backView.hidden = NO;
    }
    
}



- (void)setImage:(UIImage *)image
{
    // Skip if the image is already set.
    if (image == imageView.image) {
        imageView.layer.opacity = 1;
        progressBar.layer.opacity = 0;
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
}


- (void)setCommentsString:(NSString *)commentsString
{
    [commentsButton setTitle:commentsString forState:UIControlStateNormal];
    
}

- (void)setDate:(NSString *)dateString
{
    dateLabel.text = dateString;
    
    // Resize the owner label so that we don't overlap and we maximize free space.
    CGSize dateSize = [dateString sizeWithFont:dateLabel.font];
    
    int newLeft = dateSize.width + dateLabel.frame.origin.x + 35;
    int oldLeft = ownerLabel.frame.origin.x;
    
    int newWidth = ownerLabel.frame.size.width + (oldLeft - newLeft);
    ownerLabel.frame = CGRectMake(newLeft, ownerLabel.frame.origin.y, newWidth, ownerLabel.frame.size.height);
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

- (NSString *)description
{
    return [NSString stringWithFormat:@"Cell for PhotoID: %@", _photoID];
}

@end
