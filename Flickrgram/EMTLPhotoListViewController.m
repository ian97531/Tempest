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

@synthesize photos;
@synthesize heights;
@synthesize table;
@synthesize spinner;
@synthesize currentIndex;

- (id)init
{
    self = [super init];
    if (self) {
        
        // An array of photo sources that provide photos id <PhotoSource>
        sources = [[NSMutableArray alloc] initWithCapacity:4];
        
        // An array of EMTLPhoto objects sorted by date.
        // This is the data source for the table that is the feed.
        photos = [[NSMutableArray alloc] initWithCapacity:100];
        
        // The heights of each cell needed for the photo object at the
        // same index.
        heights = [[NSMutableArray alloc] initWithCapacity:100];
        
    }
    return self;
}

/* 
 * addSource:
 *
 * Takes an object that conforms to the PhotoSource protocol to be used as the
 * table loads to supply EMTLPhotos.
 *
 */
- (void)addSource:(id <PhotoSource>)source
{
    #ifdef DEBUG
    NSLog(@"Adding the source %@ to the photolistview controller", source.key);
    #endif
    
    // Once added, we request the first set of photos.
    source.photoDelegate = self;
    [source morePhotos];
    [sources addObject:source];
}


#pragma mark - PhotoConsumer methods

/* 
 * photoSource:retreivedMorePhotos:
 *
 * This a method required by the PhotoConsumer protocol. When a PhotoSource object
 * retreives additional photos from it's service provider, it sends them back via
 * this method. The photoArray contains EMTLPhoto objects.
 *
 */
- (void)photoSource:(id <PhotoSource>)photoSource retreivedMorePhotos:(NSArray *)photoArray;
{
    
    // If we're currently showing the feed loading progress spinner,
    // we should remove it, so that the feed table can be viewed.
    if(spinner) {
        [UIView animateWithDuration:0.2 animations:^(void) {
            spinner.view.layer.opacity = 0;
        } completion:^(BOOL finished) {
            [spinner stop];
            [spinner.view removeFromSuperview];
            spinner = nil;
        }];
    }
    
    // Save the photos to our array
    [photos addObjectsFromArray:photoArray];
    
    // Calculate the heights needed for each photo cell in the photoArray and save them.
    for (EMTLPhoto *photo in photoArray) {
        [heights addObject:[NSNumber numberWithInt:(int)((294 / photo.aspect_ratio.floatValue) + 150)]];
    }

    #ifdef DEBUG
    NSLog(@"Got %i more photos from %@", photoArray.count, photoSource.key);
    #endif
    
    // Load the data into the table feed, and start pre-loading some of the EMTLPhotos
    // The preloading grabs the actual image, and comments and favorites.
    [table reloadData];
    [self preload];
}



/* 
 * photoSource:encounteredAnError:
 *
 * This a method required by the PhotoConsumer protocol. When a PhotoSource object
 * is unable to load additional photos as requested, it will call this method.
 *
 */
- (void)photoSource:(id <PhotoSource>)photoSource encounteredAnError:(NSError *)error
{
    NSLog(@"photos could not be added to any array for %@ because %@", photoSource.key, error.localizedDescription);
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
    return [[heights objectAtIndex:indexPath.row] intValue];

}

#pragma mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Grab a cell from the queue or create a new one.
    EMTLPhotoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PhotoCell"];
    
    if (cell == nil) {
        cell = [[EMTLPhotoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PhotoCell"];
    }
    
    // Get the photo for this cell from the photos array, pass in the cell
    EMTLPhoto *photo = [photos objectAtIndex:indexPath.row];
    
    [cell loadPhoto:photo];
    
    //[cell setImageHeight:photo.height];

    
    currentIndex = indexPath;
    
    
    return cell;
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [self preloadImages:15];
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self preloadImages:15];
}


- (void) preload
{
    [self preloadImages:5];
}

- (void) preloadImages:(int)num
{
    // Preload the next 3 images if they exist.
    for (int i = 1; i < num; i++) {
        if(currentIndex.row + i < photos.count) {
            [[photos objectAtIndex:(currentIndex.row + i)] loadData];
        }
        else {
            break;
        }
    }
    
    if(currentIndex.row > photos.count - 20) {
        [[sources objectAtIndex:0] morePhotos];
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return photos.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    EMTLPhoto *photo = [photos objectAtIndex:indexPath.row];
    NSLog(@"That image is %@", photo.photo_id);
    
}



@end
