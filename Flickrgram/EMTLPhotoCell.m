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
        
        
        backgroundView = [[UIView alloc] initWithFrame:CGRectMake(2, 10, 316, 392)];
        backgroundView.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1];
        backgroundView.layer.cornerRadius = 2.8;
        
        cardView = [[UIView alloc] initWithFrame:CGRectMake(1, 0, 314, 390)];
        cardView.backgroundColor = [UIColor whiteColor];
        //cardView.layer.shadowColor = [UIColor colorWithWhite:0 alpha:1].CGColor;
        //cardView.layer.shadowOffset = CGSizeMake(0, 1);
        //cardView.layer.shadowRadius = 1;
        //cardView.layer.shadowOpacity = 0.4;
        cardView.layer.cornerRadius = 2;
        
        [backgroundView addSubview:cardView];
        
        backgroundGutter = [[UIImageView alloc] initWithFrame:CGRectMake(6, 44, 302, 302)];
        backgroundGutter.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
        backgroundGutter.layer.borderWidth = 1;
        backgroundGutter.layer.borderColor = [UIColor colorWithWhite:0.9 alpha:1].CGColor;
        backgroundGutter.layer.cornerRadius = 2.7;
        
                
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(7, 45, 300, 300)];
        //imageView.center = backgroundGutter.center;
        imageView.layer.cornerRadius = 2;
        imageView.layer.masksToBounds = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFill;

        
        dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 170, 40)];
        dateLabel.backgroundColor = [UIColor clearColor];
        dateLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:28];
        dateLabel.textColor = [UIColor colorWithWhite:0.2 alpha:1];
        
        ownerLabel = [[UILabel alloc] initWithFrame:CGRectMake(185, 21, 120, 20)];
        ownerLabel.backgroundColor = [UIColor clearColor];
        ownerLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12];
        ownerLabel.textColor = [UIColor colorWithWhite:0.44 alpha:1];
        ownerLabel.textAlignment = UITextAlignmentRight;
        ownerLabel.layer.masksToBounds = YES;
        
        indicator = [[EMTLProgressIndicatorViewController alloc] initWithSmallSize:YES];
        indicator.view.center = imageView.center;
        indicator.view.layer.opacity = 0.1;
        
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        //[self.contentView addSubview:backgroundGutter];
        
        [cardView addSubview:backgroundGutter];
        [cardView addSubview:indicator.view];
        [cardView addSubview:imageView];
        [cardView addSubview:dateLabel];
        [cardView addSubview:ownerLabel];
        
        
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
        
        
        [UIView animateWithDuration:0.4 animations:^(void) {
            imageView.layer.opacity = 1;
            
        } completion:^(BOOL finished) {
            indicator.value = 0;
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
}

- (void)prepareForReuse
{
    if(photo) {
        [photo removeFromCell:self];
        photo = nil;
        imageView.image = nil;
        
    }
}






@end
