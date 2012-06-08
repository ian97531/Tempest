//
//  EMTLUserPhotoListViewController.h
//  Tempest
//
//  Created by Ian White on 6/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EMTLPhotoListViewController.h"

@class EMTLUser;

@interface EMTLUserPhotoListViewController : EMTLPhotoListViewController
{
    UIView *_tableHeaderView;
    EMTLUser *_user;
}

- (id)initWithPhotoQuery:(EMTLPhotoQuery *)query user:(EMTLUser *)user;

@end
