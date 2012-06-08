//
//  EMTLPhotoListViewController.m
//  Flickrgram
//
//  Created by Ian White on 4/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EMTLPhotoListViewController.h"
#import "EMTLPhotoCell.h"
#import "EMTLPhoto.h"
#import "EMTLLocation.h"
#import "EMTLUser.h"
#import "EMTLMagicUserList.h"

#import "Math.h"

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@interface EMTLPhotoListViewController ()
@property (nonatomic, strong) EMTLPhotoQuery *photoQuery;
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation EMTLPhotoListViewController

@synthesize photoQuery = _photoQuery;
@synthesize tableView = _tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    // We shouldn't be using the UIViewController init methods since we have a custom one that's required
    NSAssert(NO, @"EMTLPhotoListViewController: use initWithPhotoQueryID:");
    return nil;
}
             
- (id)initWithPhotoQuery:(EMTLPhotoQuery *)query;
{
    self = [super initWithNibName:nil bundle:nil];
    if (self != nil)
    {

        _flipState = [NSMutableDictionary dictionary];
        //NSLog(@"in view controller\n%@", query.queryArguments);
        _photoQuery = query;
        _photoQuery.delegate = self;
        [self reloadQuery];
    }
    
    return self;
}


- (void)reloadQuery
{

    [_photoQuery reloadPhotos];
}

- (void)toggleChromeVisibility
{
    
    BOOL statusBarVisible = ![UIApplication sharedApplication].statusBarHidden;
    [[UIApplication sharedApplication] setStatusBarHidden:statusBarVisible withAnimation:UIStatusBarAnimationFade];
        
}


- (void)favoriteButtonPushed:(id)sender
{
    UITapGestureRecognizer *favoriteGesture = (UITapGestureRecognizer *)sender;
    
    EMTLPhoto *photo = [_photoQuery.photoList objectAtIndex:favoriteGesture.view.tag];
    
    [photo setFavorite:!photo.isFavorite];
    
    EMTLPhotoCell *cell = (EMTLPhotoCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:favoriteGesture.view.tag inSection:0]];
    
    if (cell)
    {
        cell.favoriteIndicatorTurnedOn = photo.isFavorite;
        cell.favoriteUsers.users = photo.favoritesUsers;
    }
    
}

// If the photo got flipped, we want to record that incase we need to reload that cell.
- (void)photoFlipped:(id)sender
{
    UITapGestureRecognizer *flipGesture = (UITapGestureRecognizer *)sender;
    
    EMTLPhotoCell *cell = (EMTLPhotoCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:flipGesture.view.tag inSection:0]];
    
    [_flipState setValue:[NSNumber numberWithBool:cell.frontFacingForward] forKey:cell.photoID];    
}

- (void)loadView
{
    
    UIView *parent = [[UIView alloc] init];
    
    _hideChromeGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleChromeVisibility)];
    [parent addGestureRecognizer:_hideChromeGestureRecognizer];

    // Set a background image.
    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ClothBackground.png"]];
    
    
    _tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 148)];

    UIImageView *headerImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LabelTempest2.png"]];
    headerImage.frame = CGRectMake(10, 30, 300, 113);
    [_tableHeaderView addSubview:headerImage];
    
    _reloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_reloadButton setImage:[UIImage imageNamed:@"Reload.png"] forState:UIControlStateNormal];
    _reloadButton.frame = CGRectMake(238, 72, 35, 35);
    _reloadButton.layer.opacity = 0.8;
    [_reloadButton addTarget:self action:@selector(reloadQuery) forControlEvents:UIControlEventTouchUpInside];
    [_tableHeaderView addSubview:_reloadButton];
    
    // Get a table ready that fills the screen and is transparent. Give it a header so that the first cell
    // is not occluded by the iOS status bar.
    self.tableView = [[UITableView alloc] initWithFrame:backgroundImage.frame style:UITableViewStylePlain];
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.layer.masksToBounds = YES; // TODO BSEELY: does it matter? This can be expensive so if it's not already the default or not needed, we should remove it
    self.tableView.tableHeaderView = _tableHeaderView;
    
    // Put a large progress spinner into the view to appease the user while the first set of
    // EMTLPhotos is loaded.
//    spinner = [EMTLProgressIndicatorViewController indicatorWithSize:kLargeProgressIndicator];
//    spinner.view.center = self.tableView.center;
//    spinner.view.layer.opacity = 0.2;
    
    // Throw everything into the view, and make it fullscreen.
    [parent addSubview:backgroundImage];
    [parent addSubview:self.tableView];
    //[parent addSubview:spinner.view];
    self.view = parent;
    self.wantsFullScreenLayout = YES;
    
    // Start the progress indicator spinning.
    //[spinner spin];
            
}


#pragma mark -
#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    // When the EMTLPhotos are returned to us using the photoSource:retreivedMorePhotos:
    // method, we stored the heights needed for each cell in the heights array.
    EMTLPhoto *photo = [_photoQuery.photoList objectAtIndex:indexPath.row];
    return roundf((294 / photo.aspectRatio.floatValue) + 150);
    
}

#pragma mark -
#pragma mark UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //NSLog(@"Getting cell at index path: %i", indexPath.row);
    // Grab a cell from the queue or create a new one.
    EMTLPhotoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PhotoCell"];
    
    if (cell == nil) {
        cell = [[EMTLPhotoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PhotoCell"];
        [cell.favoriteTapGesture addTarget:self action:@selector(favoriteButtonPushed:)];
        [cell.flipGesture addTarget:self action:@selector(photoFlipped:)];
        [_hideChromeGestureRecognizer requireGestureRecognizerToFail:cell.flipGesture];
        cell.favoriteUsers.delegate = self;
        cell.favoriteUsers.highlightSelectableRangesWithColor = NULL;//[UIColor colorWithRed:1 green:1 blue:0.69 alpha:1];
        cell.favoriteUsers.backgroundColor = [UIColor clearColor];
    }
    
    EMTLPhoto *photo = [_photoQuery.photoList objectAtIndex:indexPath.row];
    
    // Adjust the flippedness of the cell if necessary.
    NSNumber *frontFacingForward = [_flipState objectForKey:photo.photoID];
    if (frontFacingForward) {
        cell.frontFacingForward = frontFacingForward.boolValue;
    }
    else {
        cell.frontFacingForward = YES;
    }
    
    // Start requesting more photos if necessary.
    if (indexPath.row + 12 > _photoQuery.totalPhotos) {
        [_photoQuery morePhotos];
    }
    
    // Setup the front face of the photo
    cell.photoID = photo.photoID;
    cell.cardView.tag = indexPath.row;
    
    cell.ownerLabel.text = photo.user.username;
    cell.dateLabel.text = [photo datePostedString];
    
    cell.favoriteUsers.photoID = photo.photoID;
    cell.favoriteUsers.signedInUser = _photoQuery.source.user;
    cell.favoriteUsers.users = photo.favoritesUsers;
    
    [cell setCommentsString:[NSString stringWithFormat:@"%i Comments", photo.comments.count]];
    
    cell.favoriteIndicator.tag = indexPath.row;
    cell.favoriteIndicatorTurnedOn = photo.isFavorite;
    
    // If an image is available, put it in the cell. If not, set the progress bar value.
    UIImage *image = [photo loadImageWithSize:EMTLImageSizeMediumAspect delegate:self];
    if(image) {
        [cell setImage:image];
    }
    else {
        [cell setProgress:photo.imageProgress];
    }
    
    
    // Setup the rearface of the cell
    cell.titleLabel.text = photo.title;
    cell.dateTakenLabel.text = photo.dateTakenString;
    cell.locationLabel.text = photo.location.name;
    cell.descriptionLabel.text = photo.photoDescription;

        
    return cell;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _photoQuery.photoList.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
}





#pragma mark -
#pragma mark EMTLPhotoQueryDelegate

- (void)photoQueryWillUpdate:(EMTLPhotoQuery *)query
{
    //NSLog(@"will get new photos");
}


- (void)photoQueryDidUpdate:(EMTLPhotoQuery *)query
{
    //NSLog(@"got new photos, %i", query.photoList.count);
    [_tableView reloadData];
}

- (void)photoQueryIsUpdating:(EMTLPhotoQuery *)query progress:(float)progress
{
    //NSLog(@"New photos are loading");
}

- (void)photoQueryFinishedUpdating:(EMTLPhotoQuery *)query
{
    NSLog(@"Query finished loading");

}


#pragma mark -
#pragma mark EMTLImageDelegate

- (void)photo:(EMTLPhoto *)photo willRequestImageWithSize:(EMTLImageSize)size
{
    
}

- (void)photo:(EMTLPhoto *)photo didRequestImageWithSize:(EMTLImageSize)size progress:(float)progress
{
    int photoIndex = [_photoQuery.photoList indexOfObject:photo];
    if (photoIndex != NSNotFound) {
        
        EMTLPhotoCell *cell = (EMTLPhotoCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:photoIndex inSection:0]];
        
        if (cell) {
            [cell setProgress:progress];
        }

    }
    
}


- (void)photo:(EMTLPhoto *)photo didLoadImage:(UIImage *)image withSize:(EMTLImageSize)size
{
    int photoIndex = [_photoQuery.photoList indexOfObject:photo];
    if (photoIndex != NSNotFound) {
        
        EMTLPhotoCell *cell = (EMTLPhotoCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:photoIndex inSection:0]];
        
        if (cell) {
            [cell setImage:image];
        }
    }

}



#pragma mark -
#pragma mark EMTLMagicUserListDelegate methods

- (void) userList:(EMTLMagicUserList *)list didTapUser:(EMTLUser *)user
{
    NSLog(@"Tapped User: %@", user);
}

- (void) userListDidTapRemainderItem:(EMTLMagicUserList *)list
{
    NSLog(@"Tapped remainder item");
}

- (void) userList:(EMTLMagicUserList *)list didLongPressUser:(EMTLUser *)user
{
    NSLog(@"Long Pressed User: %@", user);
}


#pragma mark -
#pragma mark Memory Management

- (void)didReceiveMemoryWarning
{
    NSLog(@"--------");
    NSLog(@"-------- RECIEVED MEMORY WARNING --------");
    NSLog(@"--------");
}



@end
