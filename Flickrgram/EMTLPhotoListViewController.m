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
        sources = [[NSMutableArray alloc] initWithCapacity:4];
        photos = [[NSMutableArray alloc] initWithCapacity:100];
        heights = [[NSMutableArray alloc] initWithCapacity:100];
        
    }
    return self;
}

- (void)addSource:(id <PhotoSource>)source
{
    NSLog(@"Adding the source %@ to the photolistview controller", source.key);
    source.photoDelegate = self;
    [source morePhotos];
    [sources addObject:source];
}

- (void)photoSource:(id <PhotoSource>)photoSource retreivedMorePhotos:(NSArray *)photoArray;
{
    NSLog(@"photos added to array for service %@ at index", photoSource.key);
    
    // If we've got a spinner, we should stop it.
    if(spinner) {
        [UIView animateWithDuration:0.2 animations:^(void) {
            spinner.view.layer.opacity = 0;
        } completion:^(BOOL finished) {
            [spinner stop];
            [spinner.view removeFromSuperview];
            spinner = nil;
        }];
    }
    
    [photos addObjectsFromArray:photoArray];
    
    for (EMTLPhoto *photo in photoArray) {
        [heights addObject:[NSNumber numberWithInt:(int)((294 / photo.aspect_ratio.floatValue) + 150)]];
    }

    NSLog(@"Got %i more photos from %@", photoArray.count, photoSource.key);
    
    [table reloadData];
    [self preload];
}




- (void)photoSource:(id <PhotoSource>)photoSource encounteredAnError:(NSError *)error
{
    NSLog(@"photos could not be added to any array for %@ because %@", photoSource.key, error.localizedDescription);
}


- (void)loadView
{
    
    UIView *parent = [[UIView alloc] init];
    parent.backgroundColor = [UIColor blackColor];
    
    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ClothBackground.png"]];
    
    table = [[UITableView alloc] initWithFrame:CGRectMake(backgroundImage.frame.origin.x, backgroundImage.frame.origin.y + 1, backgroundImage.frame.size.width, backgroundImage.frame.size.height - 2)];
    table.separatorColor = [UIColor clearColor];
    table.delegate = self;
    table.dataSource = self;
    table.backgroundColor = [UIColor clearColor];
    table.layer.masksToBounds = YES;
    table.showsVerticalScrollIndicator = NO;
    table.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
    
    
    spinner = [[EMTLProgressIndicatorViewController alloc] initWithSmallSize:NO];
    spinner.view.center = table.center;
    spinner.view.layer.opacity = 0.2;
    
    [parent addSubview:backgroundImage];
    [parent addSubview:table];
    [parent addSubview:spinner.view];
    
    self.view = parent;
    self.wantsFullScreenLayout = YES;
    
    [spinner spin];
            
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [[heights objectAtIndex:indexPath.row] intValue];

}

#pragma mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EMTLPhotoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PhotoCell"];
    
    if (cell == nil) {
        cell = [[EMTLPhotoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PhotoCell"];
        
    }
    EMTLPhoto *photo = [photos objectAtIndex:indexPath.row];
    [photo loadPhotoIntoCell:cell];
    [cell setImageHeight:photo.height];
    cell.ownerLabel.text = photo.username;
    cell.dateLabel.text = [photo datePostedString];
    
    currentIndex = indexPath;
    
    
    if(indexPath.row > photos.count - 10) {
        [[sources objectAtIndex:0] morePhotos];
    }
    
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
            [[photos objectAtIndex:(currentIndex.row + i)] loadImage];
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
