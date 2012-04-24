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
@synthesize isFavorite;
@synthesize numFavorites;
@synthesize numComments;
@synthesize photo;
@synthesize indicator;
@synthesize favoritesButton;
@synthesize commentsButton;

@synthesize favoritesTitle;
@synthesize commentsTitle;
@synthesize listTable;
@synthesize currentTableData;
@synthesize commentsArray;
@synthesize favoritesArray;

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
        
        favoritesButton = [UIButton buttonWithType:UIButtonTypeCustom];
        favoritesButton.frame = CGRectMake(16, 347, 288, 16);
        favoritesButton.titleLabel.font = [UIFont fontWithName:@"MarkerSD" size:14];
        [favoritesButton setTitleColor:[UIColor colorWithWhite:0 alpha:0.6] forState:UIControlStateNormal];
        [favoritesButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [favoritesButton addTarget:self action:@selector(switchToFavoritesView) forControlEvents:UIControlEventTouchUpInside];
        
        commentsButton = [UIButton buttonWithType:UIButtonTypeCustom];
        commentsButton.frame = CGRectMake(16, 369, 100, 16);
        commentsButton.titleLabel.font = [UIFont fontWithName:@"MarkerSD" size:14];
        [commentsButton setTitleColor:[UIColor colorWithWhite:0 alpha:0.6] forState:UIControlStateNormal];
        [commentsButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        
        [cardView addSubview:backgroundGutter];
        [cardView addSubview:indicator.view];
        [cardView addSubview:imageView];
        [cardView addSubview:dateLabel];
        [cardView addSubview:ownerLabel];
        
        [cardView addSubview:commentsButton];
        [cardView addSubview:favoritesButton];
        
        
        [self.contentView addSubview:cardView];
        
        
        // Setup favorites card
        favoritesTitle = [UIButton buttonWithType:UIButtonTypeCustom];
        favoritesTitle.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:15];
        [favoritesTitle setTitle:@"Favorites" forState:UIControlStateNormal];
        [favoritesTitle setTitleColor:[UIColor colorWithWhite:0 alpha:0.6] forState:UIControlStateNormal];
        favoritesTitle.frame = CGRectMake(0, 13, cardView.frame.size.width/2, 20);
        
        
        
        commentsTitle = [UIButton buttonWithType:UIButtonTypeCustom];
        commentsTitle.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:15];
        [commentsTitle setTitle:@"Comments" forState:UIControlStateNormal];
        [commentsTitle setTitleColor:[UIColor colorWithWhite:0 alpha:0.6] forState:UIControlStateNormal];
        commentsTitle.frame = CGRectMake(cardView.frame.size.width/2, 13, cardView.frame.size.width/2, 20);
        
        listTable = [[UITableView alloc] initWithFrame:CGRectMake(20, 35, 280, 300) style:UITableViewStylePlain];
        listTable.delegate = self;
        listTable.dataSource = self;
        listTable.backgroundColor = [UIColor clearColor];
        listTable.separatorColor = [UIColor clearColor];
        
        currentTableData = nil;
        
        
        
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

- (void)setFavoritesString:(NSString *)favoritesString animated:(BOOL)animated
{
    
    [favoritesButton setTitle:favoritesString forState:UIControlStateNormal];
    
    if(animated) {
        favoritesButton.layer.opacity = 0;
        
        [UIView animateWithDuration:0.6 animations:^(void) {
            favoritesButton.layer.opacity = 1;
            
        }];
    }
    
}

- (float)favoriteStringSize
{
    return favoritesButton.frame.size.width;
}

- (UIFont *)favoritesFont
{
    return favoritesButton.titleLabel.font;
}

- (void)setComments:(NSArray *)comments animated:(BOOL)animated
{
    if(comments.count == 1) {
        [commentsButton setTitle:@"1 comment" forState:UIControlStateNormal];
    }
    else {
        [commentsButton setTitle:[NSString stringWithFormat:@"%i comments", comments.count] forState:UIControlStateNormal];
    }
    
    if(animated) {
        commentsButton.layer.opacity = 0;
        
        [UIView animateWithDuration:0.6 animations:^(void) {
            commentsButton.layer.opacity = 1;
            
        }];
    }
    
    
}

- (void)setImageHeight:(int)height
{
    int difference = height - imageView.frame.size.height;

    
    cardView.frame = CGRectMake(cardView.frame.origin.x, cardView.frame.origin.y, cardView.frame.size.width, cardView.frame.size.height + difference);
    cardImageView.frame = CGRectMake(cardImageView.frame.origin.x, cardImageView.frame.origin.y, cardImageView.frame.size.width, cardImageView.frame.size.height + difference);
    backgroundGutter.frame = CGRectMake(backgroundGutter.frame.origin.x, backgroundGutter.frame.origin.y, backgroundGutter.frame.size.width, height);
    imageView.frame = CGRectMake(imageView.frame.origin.x, imageView.frame.origin.y, imageView.frame.size.width, height);
    indicator.view.center = imageView.center;
    favoritesButton.frame = CGRectMake(favoritesButton.frame.origin.x, favoritesButton.frame.origin.y + difference, favoritesButton.frame.size.width, favoritesButton.frame.size.height);
    commentsButton.frame = CGRectMake(commentsButton.frame.origin.x, commentsButton.frame.origin.y + difference, commentsButton.frame.size.width, commentsButton.frame.size.height);
    
    
    
}

- (void)prepareForReuse
{
    if(photo) {
        [photo removeFromCell:self];
        photo = nil;
        imageView.image = nil;
        [favoritesButton setTitle:@"" forState:UIControlStateNormal];
        [commentsButton setTitle:@"" forState:UIControlStateNormal];
        [indicator resetValue];
        currentTableData = nil;
        commentsArray = nil;
        favoritesArray = nil;
        
        [favoritesTitle removeFromSuperview];
        [commentsTitle removeFromSuperview];
        [listTable removeFromSuperview];
        
        [self.contentView addSubview:backgroundGutter];
        [self.contentView addSubview:indicator.view];
        [self.contentView addSubview:imageView];
        [self.contentView addSubview:ownerLabel];
        [self.contentView addSubview:dateLabel];
        [self.contentView addSubview:favoritesButton];
        [self.contentView addSubview:commentsButton];
        
    }
}


- (void)switchToFavoritesView
{
    currentTableData = favoritesArray;
    [listTable reloadData];
    listTable.frame = imageView.frame;

    [UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.6];
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight
						   forView:cardView
							 cache:YES];
    
    [backgroundGutter removeFromSuperview];
    [imageView removeFromSuperview];
    [dateLabel removeFromSuperview];
    [ownerLabel removeFromSuperview];
    [indicator.view removeFromSuperview];
    [favoritesButton removeFromSuperview];
    [commentsButton removeFromSuperview];
    
	[cardView addSubview:favoritesTitle];
    [cardView addSubview:commentsTitle];
    [cardView addSubview:listTable];
	[UIView commitAnimations];
}


- (void)switchToCommentsView
{
    
}


- (void)flipPhoto
{
    
}

#pragma mark - UITableViewDelegate methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 25;
    
}

#pragma mark - UITableViewDataSource methods
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FavoritesCell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"FavoritesCell"];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.font = [UIFont fontWithName:@"MarkerSD" size:14];
        
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"Liked by %@", [[currentTableData objectAtIndex:indexPath.row] username]];
    
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (currentTableData) {
        return currentTableData.count;
    }
    else {
        return 0;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}



@end
