//
//  EMTLPhotoCell.h
//  Flickrgram
//
//  Created by Ian White on 4/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EMTLPhotoCell : UITableViewCell

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *owner;
@property (nonatomic, strong) UILabel *date;
@property (nonatomic) BOOL isFavorite;
@property (nonatomic) int numFavorites;
@property (nonatomic) int numComments;


@end
