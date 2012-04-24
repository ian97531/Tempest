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
@synthesize cardImageView;
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
        
        
//        backgroundView = [[UIView alloc] initWithFrame:CGRectMake(2, 10, 314, 385)];
//        backgroundView.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1];
//        backgroundView.layer.cornerRadius = 2.8;
        
        
        
//        cardView = [[UIView alloc] initWithFrame:CGRectMake(1, 0, 314, 383)];
//        cardView.backgroundColor = [UIColor whiteColor];
//        cardView.layer.cornerRadius = 2;
        
        cardView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 405)];
        cardView.backgroundColor = [UIColor clearColor];
        
        UIImage *cardImage = [[UIImage imageNamed:@"PolaroidTextured4.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(38, 0, 70, 0)];
        
        cardImageView = [[UIImageView alloc] initWithImage:cardImage];
        cardImageView.frame = CGRectMake(0, 0, 320, 405);
        
        [cardView addSubview:cardImageView];
        
        //[backgroundView addSubview:cardView];
        
        backgroundGutter = [[UIImageView alloc] initWithFrame:CGRectMake(13, 36, 294, 300)];
        backgroundGutter.backgroundColor = [UIColor colorWithWhite:0 alpha:0.89];
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
        
        indicator = [[EMTLProgressIndicatorViewController alloc] initWithSmallSize:YES];
        indicator.view.center = imageView.center;
        indicator.view.layer.opacity = 0.1;
        
        favoritesLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 347, 290, 16)];
        favoritesLabel.font = [UIFont fontWithName:@"MarkerSD" size:14];
        favoritesLabel.textColor = [UIColor colorWithWhite:0 alpha:0.6];
        favoritesLabel.backgroundColor = [UIColor clearColor];
        
        commentsLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 369, 100, 16)];
        commentsLabel.font = [UIFont fontWithName:@"MarkerSD" size:14];
        commentsLabel.textColor = [UIColor colorWithWhite:0 alpha:0.6];
        commentsLabel.backgroundColor = [UIColor clearColor];
        
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        
        [cardView addSubview:backgroundGutter];
        [cardView addSubview:indicator.view];
        [cardView addSubview:imageView];
        [cardView addSubview:dateLabel];
        [cardView addSubview:ownerLabel];
        
        [cardView addSubview:favoritesLabel];
        [cardView addSubview:commentsLabel];
        
        
        [self.contentView addSubview:cardView];
        
        
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
            [indicator resetValue];
        }];
    }
    
    
}

- (void)setFavorites:(NSArray *)favorites animated:(BOOL)animated
{
    
    if (favorites.count) {
        
        NSString *favoritesString = nil;
        
        if(favorites.count == 1) {
            favoritesString = [NSString stringWithFormat:@"Liked by %@", [[favorites objectAtIndex:0] username]];
            
        }
        else if (favorites.count > 1){
            favoritesString = [NSString stringWithFormat:@"%i likes", favorites.count];
            
            int availableWidth = 284;
            NSString *testString = @"";
            NSString *formatString = @"Liked by %@ and %i other%@";
            NSString *fillerString = [[favorites objectAtIndex:0] username];
            NSString *endString = @"s";
            int remaining = favorites.count - 1;
            if (remaining == 1) {
                endString = @"";
            }

            testString = [NSString stringWithFormat:formatString, fillerString, remaining, endString];
            
            for (int i = 1; i < favorites.count && i < 8; i++) {
                
                if ([testString sizeWithFont:favoritesLabel.font].width < availableWidth) {
                    favoritesString = testString;
                    
                    if (remaining == 1) {
                        testString = [NSString stringWithFormat:@"Liked by %@ and %@", fillerString, [favorites.lastObject username]];
                        if ([testString sizeWithFont:favoritesLabel.font].width < availableWidth) {
                            favoritesString = testString;   
                        }
                        break;
                    }
                    
                    fillerString = [NSString stringWithFormat:@"%@, %@", fillerString, [[favorites objectAtIndex:i] username]];
                    remaining--;
                    if (remaining == 1) {
                        endString = @"";
                    }
                    testString = [NSString stringWithFormat:formatString, fillerString, remaining, endString];
                    
                }
                else {
                    break;
                }
                
            }
            
            // If we have a dangling "and 1 other", see if we can just fit the name.
            
            
        }
        else {
            favoritesString = @"0 likes";
        }
        
        favoritesLabel.text = favoritesString;

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
    //backgroundView.frame = CGRectMake(backgroundView.frame.origin.x, backgroundView.frame.origin.y, backgroundView.frame.size.width, backgroundView.frame.size.height + difference);
    cardView.frame = CGRectMake(cardView.frame.origin.x, cardView.frame.origin.y, cardView.frame.size.width, cardView.frame.size.height + difference);
    cardImageView.frame = CGRectMake(cardImageView.frame.origin.x, cardImageView.frame.origin.y, cardImageView.frame.size.width, cardImageView.frame.size.height + difference);
    backgroundGutter.frame = CGRectMake(backgroundGutter.frame.origin.x, backgroundGutter.frame.origin.y, backgroundGutter.frame.size.width, height);
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
        [indicator resetValue];
        
    }
}






@end
