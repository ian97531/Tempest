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
#import "EMTLMagicUserList.h"

@interface EMTLPhotoListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, EMTLPhotoQueryDelegate, EMTLImageDelegate, EMTLMagicUserListDelegate>
{
    @protected
    EMTLPhotoQuery *_photoQuery;
    UITableView *_tableView;
    UIView *_tableHeaderView;
    UIButton *_reloadButton;
    NSMutableDictionary *_flipState;
    UITapGestureRecognizer *_hideChromeGestureRecognizer;
}

- (id)initWithPhotoQuery:(EMTLPhotoQuery *)query;
- (void)reloadQuery;
- (void)toggleChromeVisibility;
- (void)favoriteButtonPushed:(id)sender;
- (void)photoFlipped:(id)sender;

// EMTLPhotoQueryDelegate methods
- (void)photoQueryWillUpdate:(EMTLPhotoQuery *)query;
- (void)photoQueryDidUpdate:(EMTLPhotoQuery *)query;
- (void)photoQueryIsUpdating:(EMTLPhotoQuery *)query progress:(float)progress;
- (void)photoQueryFinishedUpdating:(EMTLPhotoQuery *)query;

// EMTLImageDelegate methods
- (void)photo:(EMTLPhoto *)photo willRequestImageWithSize:(EMTLImageSize)size;
- (void)photo:(EMTLPhoto *)photo didRequestImageWithSize:(EMTLImageSize)size progress:(float)progress;
- (void)photo:(EMTLPhoto *)photo didLoadImage:(UIImage *)image withSize:(EMTLImageSize)size;

// EMTLMagicUserListDelegate methods
- (void) userList:(EMTLMagicUserList *)list didTapUser:(EMTLUser *)user;
- (void) userListDidTapRemainderItem:(EMTLMagicUserList *)list;
- (void) userList:(EMTLMagicUserList *)list didLongPressUser:(EMTLUser *)user;

@end
