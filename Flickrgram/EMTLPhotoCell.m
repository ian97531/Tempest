//
//  EMTLPhotoCell.m
//  Flickrgram
//
//  Created by Ian White on 4/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EMTLPhotoCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation EMTLPhotoCell

@synthesize imageView;
@synthesize ownerLabel;
@synthesize dateLabel;
@synthesize isFavorite;
@synthesize numFavorites;
@synthesize numComments;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        UIImageView *backgroundGutter = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Item4.png"]];
        backgroundGutter.frame = CGRectMake(5, 55, 310, 310);
        backgroundGutter.layer.opacity = 0.6;
        
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(7, 57, 306, 306)];
        imageView.layer.cornerRadius = 2;
        imageView.layer.masksToBounds = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        
        dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 20, 170, 40)];
        dateLabel.backgroundColor = [UIColor clearColor];
        dateLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:28];
        dateLabel.textColor = [UIColor colorWithWhite:0.2 alpha:1];
        dateLabel.shadowColor = [UIColor colorWithWhite:1 alpha:0.6];
        dateLabel.shadowOffset = CGSizeMake(0, 1);
        
        ownerLabel = [[UILabel alloc] initWithFrame:CGRectMake(190, 37, 120, 20)];
        ownerLabel.backgroundColor = [UIColor clearColor];
        ownerLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12];
        ownerLabel.textColor = [UIColor colorWithWhite:0.44 alpha:1];
        ownerLabel.textAlignment = UITextAlignmentRight;
        ownerLabel.layer.masksToBounds = YES;
        
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self.contentView addSubview:backgroundGutter];
        [self.contentView addSubview:imageView];
        [self.contentView addSubview:dateLabel];
        [self.contentView addSubview:ownerLabel];
        
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
            
        }];
    }
    
    
}




@end
