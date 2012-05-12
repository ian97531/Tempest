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

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@interface EMTLPhotoListViewController ()
@property (nonatomic, strong) NSString *photoQueryID;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) EMTLProgressIndicatorViewController *spinner;
@end

@implementation EMTLPhotoListViewController

@synthesize photoQueryID = _photoQueryID;
@synthesize tableView = _tableView;
@synthesize spinner;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    // We shouldn't be using the UIViewController init methods since we have a custom one that's required
    NSAssert(NO, @"EMTLPhotoListViewController: use initWithPhotoQueryID:");
    return nil;
}
             
- (id)initWithPhotoQueryID:(NSString *)queryID
{
    self = [super initWithNibName:nil bundle:nil];
    if (self != nil)
    {
        self.photoQueryID = queryID;
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
    spinner = [EMTLProgressIndicatorViewController indicatorWithSize:kLargeProgressIndicator];
    spinner.view.center = self.tableView.center;
    spinner.view.layer.opacity = 0.2;
    
    // Throw everything into the view, and make it fullscreen.
    [parent addSubview:backgroundImage];
    [parent addSubview:self.tableView];
    [parent addSubview:spinner.view];
    self.view = parent;
    self.wantsFullScreenLayout = YES;
    
    // Start the progress indicator spinning.
    [spinner spin];
            
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

- (void)photoSource:(EMTLPhotoSource *)photoSource willUpdateQuery:(NSString *)queryID
{
    // Sanity Check
    NSAssert([self.photoQueryID isEqualToString:queryID], @"EMTLPhotoListViewController: got photo query delegate callback with the wrong query ID");
}

- (void)photosource:(EMTLPhotoSource *)photoSource didUpdateQuery:(NSString *)queryID
{
    // Sanity Check
    NSAssert([self.photoQueryID isEqualToString:queryID], @"EMTLPhotoListViewController: got photo query delegate callback with the wrong query ID");
}

- (void)photoSource:(EMTLPhotoSource *)photoSource willChangePhoto:(EMTLPhoto *)photo
{
    // Sanity Check
}

- (void)photoSource:(EMTLPhotoSource *)photoSource didChangePhoto:(EMTLPhoto *)photo
{
    // Sanity Check
}

#pragma mark -
#pragma mark EMTLImageDelegate

- (void)photoSource:(EMTLPhotoSource *)photoSource willRequestImageForPhoto:(EMTLPhoto *)photo size:(EMTLImageSize)size
{
    
}

- (void)photosource:(EMTLPhotoSource *)photoSource didRequestImageForPhoto:(EMTLPhoto *)photo size:(EMTLImageSize)size progress:(float)progress
{
    
}

- (void)photoSource:(EMTLPhotoSource *)photoSource didLoadImageForPhoto:(EMTLPhoto *)photo size:(EMTLImageSize)size image:(UIImage *)image
{
    
}


@end
