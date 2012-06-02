//
//  EMTLPhotoListViewController.h
//  Flickrgram
//
//  Created by Ian White on 4/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EMTLPhoto.h"
#import "EMTLPhotoQuery.h"

@interface EMTLPhotoListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, EMTLPhotoQueryDelegate, EMTLImageDelegate>
{
    @protected
    EMTLPhotoQuery *_photoQuery;
    UITableView *_tableView;
    UIView *_tableHeaderView;
    UIButton *_reloadButton;
}

- (id)initWithPhotoQuery:(EMTLPhotoQuery *)query;
- (void)reloadQuery;
- (void)toggleChromeVisibility;
- (void)favoriteButtonPushed:(id)sender;

// EMTLPhotoQueryDelegate
- (void)photoQueryWillUpdate:(EMTLPhotoQuery *)query;
- (void)photoQueryDidUpdate:(EMTLPhotoQuery *)query;
- (void)photoQueryIsUpdating:(EMTLPhotoQuery *)query progress:(float)progress;
- (void)photoQueryFinishedUpdating:(EMTLPhotoQuery *)query;

//EMTLImageDelegate
- (void)photo:(EMTLPhoto *)photo willRequestImageWithSize:(EMTLImageSize)size;
- (void)photo:(EMTLPhoto *)photo didRequestImageWithSize:(EMTLImageSize)size progress:(float)progress;
- (void)photo:(EMTLPhoto *)photo didLoadImage:(UIImage *)image withSize:(EMTLImageSize)size;

@end
