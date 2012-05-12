//
//  EMTLPhotoCell.m
//  Tempest
//
//  Created by Blake Seely on 5/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EMTLPhotoCell.h"

@implementation EMTLPhotoCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews
{
    // Lay out from top to bottom
    CGRect viewFrame;
    viewFrame.size.width = [self bounds].size.width;
    viewFrame.origin.x = 0.0;
    
    // Top image
    viewFrame.size.height = [_topImageView bounds].size.height;
    viewFrame.origin.y = viewFrame.size.height;
    [_topImageView setFrame:viewFrame];
    
    // Middle Image
    
    
    // Bottom Image
}

- (void)setProgressValue:(CGFloat)progress
{
    if ([_topImageView image] != nil)
    {
        if (_progressView == nil)
        {
            _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
            [self addSubview:_progressView];
        }
        
        [_progressView setProgress:progress];
    }
}

- (void)setTopImage:(UIImage *)topImage
{
    if (_topImageView == nil)
    {
        _topImageView = [[UIImageView alloc] initWithImage:topImage];
        [_topImageView setContentMode:UIViewContentModeScaleAspectFit];
        [self addSubview:_topImageView];
    }
    else
    {
        [_topImageView setImage:topImage];
    }
}

- (void)setMiddleImage:(UIImage *)middleImage
{
    if (_middleImageView == nil)
    {
        _middleImageView = [[UIImageView alloc] initWithImage:middleImage];
        [_middleImageView setContentMode:UIViewContentModeScaleToFill];
        [self addSubview:_middleImageView];
    }
    else
    {
        [_middleImageView setImage:middleImage];
    }
}

- (void)setBottomImage:(UIImage *)bottomImage
{
    if (_bottomImageView == nil)
    {
        _bottomImageView = [[UIImageView alloc] initWithImage:bottomImage];
        [_bottomImageView setContentMode:UIViewContentModeScaleAspectFit];
        [self addSubview:_bottomImageView];
    }
    else
    {
        [_bottomImageView setImage:bottomImage];
    }
}

- (void)setPhotoImage:(UIImage *)photoImage
{
    if (_photoImageView == nil)
    {
        _photoImageView = [[UIImageView alloc] initWithImage:photoImage];
        [_photoImageView setContentMode:UIViewContentModeScaleAspectFit];
        [UIView transitionFromView:_progressView toView:_photoImageView duration:0.25 options:UIViewAnimationOptionLayoutSubviews completion:^(BOOL finished) {
            _progressView = nil;
        }];
    }
    else
    {
        [_photoImageView setImage:photoImage];
    }
}

@end
