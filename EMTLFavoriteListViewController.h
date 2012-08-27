//
//  EMTLFavoriteListViewController.h
//  Tempest
//
//  Created by Ian White on 8/26/12.
//
//

#import <UIKit/UIKit.h>
#import "EMTLPhoto.h"
#import "EMTLUser.h"



@interface EMTLFavoriteListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, EMTLUserDelegate>
{
    EMTLPhoto *_photo;
    UITableView *_tableView;
    NSArray *_users;
}

- (id)initWithPhoto:(EMTLPhoto *)photo;
- (void)backToPhotos;

- (void)userWillLoad:(EMTLUser *)user;
- (void)userDidLoad:(EMTLUser *)user;

@end
