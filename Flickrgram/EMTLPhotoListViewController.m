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

#import <QuartzCore/QuartzCore.h>


@implementation EMTLPhotoListViewController

@synthesize photos;
@synthesize table;

- (id)init
{
    self = [super init];
    if (self) {
        sources = [[NSMutableArray alloc] initWithCapacity:4];
        photos = [[NSMutableArray alloc] initWithCapacity:80];
        
    }
    return self;
}

- (void)addSource:(id <PhotoSource>)source
{
    NSLog(@"Adding the source %@ to the photolistview controller", source.key);
    source.photoDelegate = self;
    [source morePhotos:50];
}

- (void)photoSource:(id <PhotoSource>)photoSource addedPhotosToArray:(NSArray *)photoArray atIndex:(int)index;
{
    NSLog(@"photos added to array for service %@ at index %i", photoSource.key, index);
    for (EMTLPhoto *photo in photoArray) {
        [photos addObject:photo];
        NSLog(@"%@", photo.URL.absoluteString);
    }
    
    [table reloadData];
}


- (void)photoSource:(id <PhotoSource>)photoSource encounteredAnError:(NSError *)error
{
    NSLog(@"photos could not be added to any array for %@ because %@", photoSource.key, error.localizedDescription);
}


- (void)loadView
{
    
    UIView *parent = [[UIView alloc] init];
    parent.backgroundColor = [UIColor blackColor];
    
    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TableBackground.png"]];
    
    
    table = [[UITableView alloc] initWithFrame:CGRectMake(backgroundImage.frame.origin.x, backgroundImage.frame.origin.y + 1, backgroundImage.frame.size.width, backgroundImage.frame.size.height - 2)];
    table.separatorColor = [UIColor clearColor];
    table.delegate = self;
    table.dataSource = self;
    table.backgroundColor = [UIColor clearColor];
    table.layer.masksToBounds = YES;
    
    [parent addSubview:backgroundImage];
    [parent addSubview:table];
    
    self.view = parent;
            
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
    return 380;
}

#pragma mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EMTLPhotoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PhotoCell"];
    
    if (cell == nil) {
        cell = [[EMTLPhotoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PhotoCell"];
        
    }
    cell.imageView.image = nil;
    EMTLPhoto *photo = [photos objectAtIndex:indexPath.row];
    [photo loadPhotoIntoCell:cell];
    cell.ownerLabel.text = photo.username;
    cell.dateLabel.text = [photo datePostedString];
    
    return cell;
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
    
}


@end
