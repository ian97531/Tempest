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
        NSLog(@"in view controller");
        NSLog([query.queryArguments description]);
        _photoQuery = query;
        _photoQuery.delegate = self;
        [_photoQuery morePhotos];
    }
    
    return self;
}

- (void)loadView
{
    
    UIView *parent = [[UIView alloc] init];

    // Set a background image.
    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ClothBackground.png"]];
    
    // Get a table ready that fills the screen and is transparent. Give it a header so that the first cell
    // is not occluded by the iOS status bar.
    self.tableView = [[UITableView alloc] initWithFrame:backgroundImage.frame style:UITableViewStylePlain];
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.layer.masksToBounds = YES; // TODO BSEELY: does it matter? This can be expensive so if it's not already the default or not needed, we should remove it
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
    
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
    return 10;
}

#pragma mark -
#pragma mark UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Grab a cell from the queue or create a new one.
    EMTLPhotoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PhotoCell"];
    
    if (cell == nil) {
        cell = [[EMTLPhotoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PhotoCell"];
    }
    
   
    return cell;
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

#pragma mark -
#pragma mark UIScrollViewDelegate

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    
}

#pragma mark -
#pragma mark EMTLPhotoQueryDelegate

- (void)photoSource:(EMTLPhotoSource *)source willUpdatePhotoQuery:(EMTLPhotoQuery *)photoQuery
{
    NSLog(@"will get new photos");
}

- (void)photoSource:(EMTLPhotoSource *)source didUpdatePhotoQuery:(EMTLPhotoQuery *)photoQuery
{
    NSLog(@"got new photos, %i", photoQuery.photoList.count);
    [_tableView reloadData];
}

- (void)photoSource:(EMTLPhotoSource *)source isUpdatingPhotoQuery:(EMTLPhotoQuery *)photoQuery progress:(float)progress
{
    NSLog(@"New photos are loading");
}


#pragma mark -
#pragma mark EMTLImageDelegate

- (void)photo:(EMTLPhoto *)photo willRequestImageWithSize:(EMTLImageSize)size
{
    
}

- (void)photo:(EMTLPhoto *)photo didRequestImageWithSize:(EMTLImageSize)size progress:(float)progress
{
    
}

- (void)photo:(EMTLPhoto *)photo didLoadImage:(UIImage *)image withSize:(EMTLImageSize)size
{
    
}



@end
