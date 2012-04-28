//
//  EMTLPhotoListViewController.m
//  Flickrgram
//
//  Created by Ian White on 4/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EMTLPhotoListViewController.h"
#import "EMTLProgressIndicatorViewController.h"
#import "EMTLPhotoCell.h"
#import "EMTLPhoto.h"

#import <QuartzCore/QuartzCore.h>


@implementation EMTLPhotoListViewController

@synthesize table;
@synthesize spinner;
@synthesize source;

- (id)init
{
    self = [super init];
    if (self) {
        

        
    }
    return self;
}




#pragma mark - PhotoConsumer methods

- (void)photoSourceMayChangePhotoList:(EMTLPhotoSource *)photoSource
{
    
}

- (void)photoSourceMayAddPhotosToPhotoList:(EMTLPhotoSource *)photoSource
{
    
}

- (void)photoSource:(EMTLPhotoSource *)photoSource didChangePhotoList:(NSDictionary *)changes
{
    
}

- (void)photoSource:(EMTLPhotoSource *)photoSource didChangePhotosAtIndexPaths:(NSArray *)indexPaths
{
    
}

- (void)photoSourceDoneChangingPhotoList:(EMTLPhotoSource *)photoSource
{
    
}


#pragma mark - View Lifecycle
- (void)loadView
{
    
    UIView *parent = [[UIView alloc] init];

    // Set a background image.
    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ClothBackground.png"]];
    
    // Get a table ready that fills the screen and is transparent. Give it a header so that the first cell
    // is not occluded by the iOS status bar.
    table = [[UITableView alloc] initWithFrame:backgroundImage.frame style:UITableViewStylePlain];
    table.separatorColor = [UIColor clearColor];
    table.delegate = self;
    table.dataSource = self;
    table.backgroundColor = [UIColor clearColor];
    table.layer.masksToBounds = YES;
    table.showsVerticalScrollIndicator = NO;
    table.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
    
    // Put a large progress spinner into the view to appease the user while the first set of
    // EMTLPhotos is loaded.
    spinner = [EMTLProgressIndicatorViewController indicatorWithSize:kLargeProgressIndicator];
    spinner.view.center = table.center;
    spinner.view.layer.opacity = 0.2;
    
    // Throw everything into the view, and make it fullscreen.
    [parent addSubview:backgroundImage];
    [parent addSubview:table];
    [parent addSubview:spinner.view];
    self.view = parent;
    self.wantsFullScreenLayout = YES;
    
    // Start the progress indicator spinning.
    [spinner spin];
            
}


#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    // When the EMTLPhotos are returned to us using the photoSource:retreivedMorePhotos:
    // method, we stored the heights needed for each cell in the heights array.
    return 10;
}

#pragma mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Grab a cell from the queue or create a new one.
    EMTLPhotoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PhotoCell"];
    
    if (cell == nil) {
        cell = [[EMTLPhotoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PhotoCell"];
    }
    
   
    return cell;
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
}


- (void) preload
{

}

- (void) preloadImages:(int)num
{

    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    
}



@end
