//
//  EMTLPhotoCell.h
//  Flickrgram
//
//  Created by Ian White on 4/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EMTLPhoto;
@class EMTLProgressIndicatorViewController;

@interface EMTLPhotoCell : UITableViewCell <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *cardImageView;
@property (nonatomic, strong) UIView *cardView;
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIView *backgroundGutter;
@property (nonatomic, strong) UILabel *ownerLabel;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UIButton *favoritesButton;
@property (nonatomic, strong) UIButton *commentsButton;

@property (nonatomic, strong) UIButton *favoritesTitle;
@property (nonatomic, strong) UIButton *commentsTitle;
@property (nonatomic, strong) UITableView *listTable;
@property (nonatomic, strong) NSArray *currentTableData;
@property (nonatomic, strong) NSArray *favoritesArray;
@property (nonatomic, strong) NSArray *commentsArray;


@property (nonatomic) BOOL isFavorite;
@property (nonatomic) int numFavorites;
@property (nonatomic) int numComments;
@property (nonatomic, strong) EMTLPhoto* photo;
@property (nonatomic, strong) EMTLProgressIndicatorViewController *indicator;

- (void)setImage:(UIImage *)image animated:(BOOL)animated;
- (void)setImageHeight:(int)height;
- (void)setFavorites:(NSArray *)favorites;
- (void)setFavoritesString:(NSString *)favoritesString animated:(BOOL)animated;
- (void)setComments:(NSArray *)comments animated:(BOOL)animated;
- (void)switchToFavoritesView;
- (void)switchToCommentsView;
- (void)flipPhoto;
- (float)favoriteStringSize;
- (UIFont *)favoritesFont;


// UITableViewDelegate methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;

// UITableViewDataSource methods
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;

@end
