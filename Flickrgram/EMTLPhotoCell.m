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
@synthesize owner;
@synthesize date;
@synthesize isFavorite;
@synthesize numFavorites;
@synthesize numComments;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 20, 310, 310)];
        imageView.layer.borderColor = [UIColor blackColor].CGColor;
        imageView.backgroundColor = [UIColor grayColor];
        imageView.layer.cornerRadius = 4;
        imageView.layer.masksToBounds = YES;
        owner = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 150, 12)];
        owner.backgroundColor = [UIColor whiteColor];
        owner.font = [UIFont systemFontOfSize:16];
        owner.textColor = [UIColor blackColor];
        self.frame = CGRectMake(0, 0, 310, 335);
        self.layer.masksToBounds = YES;
        [self.contentView addSubview:imageView];
        [self.contentView addSubview:owner];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


@end
