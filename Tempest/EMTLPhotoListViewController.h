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

@interface EMTLPhotoListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, EMTLPhotoConsumer>

@property (nonatomic, strong) EMTLPhotoSource *source;
@property (nonatomic, strong) UITableView *table;
@property (nonatomic, strong) EMTLProgressIndicatorViewController *spinner;


// EMTLPhotoConsumer methods
- (void)photoSourceMayChangePhotoList:(EMTLPhotoSource *)photoSource;
- (void)photoSourceMayAddPhotosToPhotoList:(EMTLPhotoSource *)photoSource;
- (void)photoSource:(EMTLPhotoSource *)photoSource didChangePhotoList:(NSDictionary *)changes;
- (void)photoSource:(EMTLPhotoSource *)photoSource didChangePhotosAtIndexPaths:(NSArray *)indexPaths;
- (void)photoSourceDoneChangingPhotoList:(EMTLPhotoSource *)photoSource;

// UITableViewDelegate methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;

// UITableViewDataSource methods
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;



@end
