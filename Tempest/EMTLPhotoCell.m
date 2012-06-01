//
//  EMTLPhotoCell.m
//  Flickrgram
//
//  Created by Ian White on 4/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EMTLPhotoCell.h"
#import "EMTLPhoto.h"
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

@synthesize favoritesButton;
@synthesize commentsButton;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        // Setup photo card
        cardView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 405)];
        cardView.backgroundColor = [UIColor clearColor];
        
        UIImage *cardImage = [[UIImage imageNamed:@"PolaroidTextured4.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(38, 0, 70, 0)];
        cardImageView = [[UIImageView alloc] initWithImage:cardImage];
        cardImageView.frame = CGRectMake(0, 0, 320, 405);
        [cardView addSubview:cardImageView];
                
        backgroundGutter = [[UIImageView alloc] initWithFrame:CGRectMake(13, 36, 294, 300)];
        backgroundGutter.backgroundColor = [UIColor colorWithWhite:0.9 alpha:0.89];
        backgroundGutter.layer.borderWidth = 1;
        backgroundGutter.layer.borderColor = [UIColor colorWithWhite:0.8 alpha:1].CGColor;
        backgroundGutter.layer.cornerRadius = 3;
        backgroundGutter.layer.masksToBounds = YES;
                
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(13, 36, 294, 300)];
        imageView.layer.masksToBounds = YES;
        imageView.opaque = NO;
        imageView.layer.cornerRadius = 3;
        imageView.layer.borderWidth = 1;
        imageView.layer.borderColor = [UIColor colorWithWhite:0.9 alpha:1].CGColor;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.layer.opacity = 0;
        
        dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 13, 170, 20)];
        dateLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:15];
        dateLabel.textColor = [UIColor colorWithWhite:0 alpha:0.7];
        dateLabel.backgroundColor = [UIColor clearColor];
        
        ownerLabel = [[UILabel alloc] initWithFrame:CGRectMake(185, 14, 120, 20)];
        ownerLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12];
        ownerLabel.textColor = [UIColor colorWithWhite:0 alpha:0.6];
        ownerLabel.textAlignment = UITextAlignmentRight;
        ownerLabel.layer.masksToBounds = YES;
        ownerLabel.backgroundColor = [UIColor clearColor];
        
        favoritesButton = [UIButton buttonWithType:UIButtonTypeCustom];
        favoritesButton.frame = CGRectMake(16, 347, 288, 16);
        favoritesButton.titleLabel.font = [UIFont fontWithName:@"Whatever" size:14];
        [favoritesButton setTitleColor:[UIColor colorWithWhite:0 alpha:0.6] forState:UIControlStateNormal];
        [favoritesButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [favoritesButton addTarget:self action:@selector(switchToFavoritesView) forControlEvents:UIControlEventTouchUpInside];
        
        commentsButton = [UIButton buttonWithType:UIButtonTypeCustom];
        commentsButton.frame = CGRectMake(16, 369, 288, 16);
        commentsButton.titleLabel.font = [UIFont fontWithName:@"Whatever" size:14];
        [commentsButton setTitleColor:[UIColor colorWithWhite:0 alpha:0.6] forState:UIControlStateNormal];
        [commentsButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        
        progressBar = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
        progressBar.frame = CGRectMake(0, 0, 180, progressBar.frame.size.height);
        progressBar.center = imageView.center;
        progressBar.trackTintColor = [UIColor colorWithWhite:0.7 alpha:1];
        
        
        //progressBar.view.layer.opacity = 0.2;
        
        
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        
        [cardView addSubview:backgroundGutter];
        [cardView addSubview:progressBar];
        [cardView addSubview:imageView];
        [cardView addSubview:dateLabel];
        [cardView addSubview:ownerLabel];
        
        [cardView addSubview:commentsButton];
        [cardView addSubview:favoritesButton];
        
        [self.contentView addSubview:cardView];
        
    }
    return self;
}




- (void)setFrame:(CGRect)frame
{
    
    [super setFrame:frame];
    
    CGRect cardRect = CGRectMake(cardView.frame.origin.x, cardView.frame.origin.y, cardView.frame.size.width, frame.size.height - 20);
    cardView.frame = cardRect;
    cardImageView.frame = cardRect;
    
    CGRect imageRect = CGRectMake(imageView.frame.origin.x, imageView.frame.origin.y, imageView.frame.size.width, frame.size.height - 150);
    imageView.frame = imageRect;
    backgroundGutter.frame = imageRect;
    progressBar.center = backgroundGutter.center;
    
    favoritesButton.frame = CGRectMake(favoritesButton.frame.origin.x, frame.size.height - 102, favoritesButton.frame.size.width, favoritesButton.frame.size.height);
    commentsButton.frame = CGRectMake(commentsButton.frame.origin.x, frame.size.height - 78, commentsButton.frame.size.width, commentsButton.frame.size.height);
    
}



- (void)prepareForReuse
{

    //imageView.image = nil;
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
    [favoritesButton removeFromSuperview];
    [commentsButton removeFromSuperview];
    

	[UIView commitAnimations];
}


#pragma mark - UITableViewDelegate methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 25;
    
}



#pragma mark - EMTLPhotoDelegate methods
- (void)setFavoritesString:(NSString *)favoritesString
{
    [favoritesButton setTitle:favoritesString forState:UIControlStateNormal];
    

    
}

- (void)setCommentsString:(NSString *)commentsString
{
    [commentsButton setTitle:commentsString forState:UIControlStateNormal];
    
}

- (void)setImage:(UIImage *)image animated:(BOOL)animated
{
    [imageView setImage:image];
    if(animated) {
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


@end
