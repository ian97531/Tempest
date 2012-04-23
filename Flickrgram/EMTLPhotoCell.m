//
//  EMTLPhotoCell.m
//  Flickrgram
//
//  Created by Ian White on 4/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EMTLPhotoCell.h"
#import "EMTLPhoto.h"
#import "EMTLProgressIndicatorViewController.h"
#import "EMTLComment.h"
#import "EMTLFavorite.h"
#import <QuartzCore/QuartzCore.h>

@implementation EMTLPhotoCell

@synthesize imageView;
@synthesize cardView;
@synthesize backgroundView;
@synthesize backgroundGutter;
@synthesize ownerLabel;
@synthesize dateLabel;
@synthesize favoritesLabel;
@synthesize commentsLabel;
@synthesize isFavorite;
@synthesize numFavorites;
@synthesize numComments;
@synthesize photo;
@synthesize indicator;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        
        backgroundView = [[UIView alloc] initWithFrame:CGRectMake(2, 10, 314, 385)];
        backgroundView.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1];
        backgroundView.layer.cornerRadius = 2.8;
        
        cardView = [[UIView alloc] initWithFrame:CGRectMake(1, 0, 314, 383)];
        cardView.backgroundColor = [UIColor whiteColor];
        cardView.layer.cornerRadius = 2;
        
        [backgroundView addSubview:cardView];
        
        backgroundGutter = [[UIImageView alloc] initWithFrame:CGRectMake(6, 35, 302, 302)];
        backgroundGutter.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
        backgroundGutter.layer.borderWidth = 1;
        backgroundGutter.layer.borderColor = [UIColor colorWithWhite:0.9 alpha:1].CGColor;
        backgroundGutter.layer.cornerRadius = 2.7;
        
                
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(7, 36, 300, 300)];
        imageView.layer.cornerRadius = 2;
        imageView.layer.masksToBounds = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFill;

        
        dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 8, 170, 24)];
        dateLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:20];
        dateLabel.textColor = [UIColor colorWithWhite:0.3 alpha:1];
        
        ownerLabel = [[UILabel alloc] initWithFrame:CGRectMake(185, 13, 120, 20)];
        ownerLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12];
        ownerLabel.textColor = [UIColor colorWithWhite:0.44 alpha:1];
        ownerLabel.textAlignment = UITextAlignmentRight;
        ownerLabel.layer.masksToBounds = YES;
        
        indicator = [[EMTLProgressIndicatorViewController alloc] initWithSmallSize:YES];
        indicator.view.center = imageView.center;
        indicator.view.layer.opacity = 0.1;
        
        favoritesLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 343, 290, 14)];
        favoritesLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:12];
        favoritesLabel.textColor = [UIColor colorWithWhite:0.3 alpha:1];
        
        commentsLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 361, 100, 14)];
        commentsLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:12];
        commentsLabel.textColor = [UIColor colorWithWhite:0.3 alpha:1];
        
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        //[self.contentView addSubview:backgroundGutter];
        
        [cardView addSubview:backgroundGutter];
        [cardView addSubview:indicator.view];
        [cardView addSubview:imageView];
        [cardView addSubview:dateLabel];
        [cardView addSubview:ownerLabel];
        
        [cardView addSubview:favoritesLabel];
        [cardView addSubview:commentsLabel];
        
        
        [self.contentView addSubview:backgroundView];
        
        
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setImage:(UIImage *)image animated:(BOOL)animated
{
    
    imageView.image = image;
    
    if (animated) {
        imageView.layer.opacity = 0;
        
        
        [UIView animateWithDuration:0.6 animations:^(void) {
            imageView.layer.opacity = 1;
            
        } completion:^(BOOL finished) {
            indicator.value = 0;
        }];
    }
    
    
}

- (void)setFavorites:(NSArray *)favorites animated:(BOOL)animated
{
    if (favorites.count) {
        NSString *favoritesString = [NSString stringWithFormat:@"Liked by %@", [[favorites objectAtIndex:0] username]];
        
        // If there are fewer than five favorites, we'll see if the names fit on a single line.
        if(favorites.count < 5) {
            
            for (int i = 1; i < favorites.count && i < 5; i++) {
                EMTLFavorite *favorite = [favorites objectAtIndex:i];
                favoritesString = [NSString stringWithFormat:@"%@, %@", favoritesString, favorite.username];
            }
            
            float stringWidth = [favoritesString sizeWithFont:favoritesLabel.font].width;
            
            // If the names do fit on a single line, set the favorites label to the string of names 
            if (stringWidth < 280) {
                favoritesLabel.text = favoritesString;
            }
            
            // Otherwise, the favorites label should display the total number of likes. 
            else {
                favoritesLabel.text = [NSString stringWithFormat:@"%i likes", favorites.count];
            }
        }
        else {
            favoritesLabel.text = [NSString stringWithFormat:@"%i likes", favorites.count];
        }

    }
    else {
        favoritesLabel.text = @"0 likes";
    }
        
    if(animated) {
        favoritesLabel.layer.opacity = 0;
        
        [UIView animateWithDuration:0.6 animations:^(void) {
            favoritesLabel.layer.opacity = 1;
            
        }];
    }
    
}

- (void)setComments:(NSArray *)comments animated:(BOOL)animated
{
    if(comments.count == 1) {
        commentsLabel.text = @"1 comment";
    }
    else {
        commentsLabel.text = [NSString stringWithFormat:@"%i comments", comments.count];
    }
    
    if(animated) {
        commentsLabel.layer.opacity = 0;
        
        [UIView animateWithDuration:0.6 animations:^(void) {
            commentsLabel.layer.opacity = 1;
            
        }];
    }
    
    
}

- (void)setImageHeight:(int)height
{
    int difference = height - imageView.frame.size.height;
    backgroundView.frame = CGRectMake(backgroundView.frame.origin.x, backgroundView.frame.origin.y, backgroundView.frame.size.width, backgroundView.frame.size.height + difference);
    cardView.frame = CGRectMake(cardView.frame.origin.x, cardView.frame.origin.y, cardView.frame.size.width, cardView.frame.size.height + difference);
    backgroundGutter.frame = CGRectMake(backgroundGutter.frame.origin.x, backgroundGutter.frame.origin.y, backgroundGutter.frame.size.width, height + 2);
    imageView.frame = CGRectMake(imageView.frame.origin.x, imageView.frame.origin.y, imageView.frame.size.width, height);
    indicator.view.center = imageView.center;
    favoritesLabel.frame = CGRectMake(favoritesLabel.frame.origin.x, favoritesLabel.frame.origin.y + difference, favoritesLabel.frame.size.width, favoritesLabel.frame.size.height);
    commentsLabel.frame = CGRectMake(commentsLabel.frame.origin.x, commentsLabel.frame.origin.y + difference, commentsLabel.frame.size.width, commentsLabel.frame.size.height);
}

- (void)prepareForReuse
{
    if(photo) {
        [photo removeFromCell:self];
        photo = nil;
        imageView.image = nil;
        commentsLabel.text = nil;
        favoritesLabel.text = nil;
        
    }
}






@end
