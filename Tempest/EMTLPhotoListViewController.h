//
//  EMTLPhotoListViewController.h
//  Flickrgram
//
//  Created by Ian White on 4/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EMTLPhotoSource.h"

@interface EMTLPhotoListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, EMTLPhotoQueryDelegate, EMTLImageDelegate>
{
    @protected
    NSString *_photoQueryID;
    UITableView *_tableView;
}

- (id)initWithPhotoQueryID:(NSString *)photoQueryID;

@end
