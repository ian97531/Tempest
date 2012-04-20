//
//  EMTLPhotoListViewController.h
//  Flickrgram
//
//  Created by Ian White on 4/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EMTLPhotoSource.h"

@class EMTLProgressIndicatorViewController;

@interface EMTLPhotoListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, PhotoConsumer>

{
    NSMutableArray *sources;
}

@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) UITableView *table;
@property (nonatomic, strong) EMTLProgressIndicatorViewController *spinner;

- (void)addSource:(id <PhotoSource>)source;

// UITableViewDelegate methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;

// UITableViewDataSource methods
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;

// PhotoConsumer methods
- (void)photoSource:(id <PhotoSource>)photoSource retreivedMorePhotos:(NSArray *)photoArray;
- (void)photoSource:(id <PhotoSource>)photoSource encounteredAnError:(NSError *)error;


@end
