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
}

- (id)initWithPhotoQuery:(EMTLPhotoQuery *)query;

// EMTLPhotoQueryDelegate
- (void)photoSource:(EMTLPhotoSource *)source willUpdatePhotoQuery:(EMTLPhotoQuery *)photoQuery;
- (void)photoSource:(EMTLPhotoSource *)source didUpdatePhotoQuery:(EMTLPhotoQuery *)photoQuery;
- (void)photoSource:(EMTLPhotoSource *)source isUpdatingPhotoQuery:(EMTLPhotoQuery *)photoQuery progress:(float)progress;

//EMTLImageDelegate
- (void)photo:(EMTLPhoto *)photo willRequestImageWithSize:(EMTLImageSize)size;
- (void)photo:(EMTLPhoto *)photo didRequestImageWithSize:(EMTLImageSize)size progress:(float)progress;
- (void)photo:(EMTLPhoto *)photo didLoadImage:(UIImage *)image withSize:(EMTLImageSize)size;

@end
