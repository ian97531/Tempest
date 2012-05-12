//
//  EMTLPhotoCell.h
//  Tempest
//
//  Created by Blake Seely on 5/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EMTLPhotoCell : UITableViewCell
{
    UIProgressView *_progressView;
    UIImageView *_topImageView;
    UIImageView *_middleImageView;
    UIImageView *_bottomImageView;
    UIImageView *_photoImageView;
}

- (void)setProgressValue:(CGFloat)progress; // Accepts values from 0-1. Not displayed if there is a photoImage.
- (void)setTopImage:(UIImage *)topImage;
- (void)setMiddleImage:(UIImage *)middleImage;
- (void)setBottomImage:(UIImage *)bottomImage;
- (void)setPhotoImage:(UIImage *)photoImage; // Hides the progress view if it was previously being shown (i.e. if setProgressValue had previously been called)
@end
