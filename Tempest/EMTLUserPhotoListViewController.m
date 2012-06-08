//
//  EMTLUserPhotoListViewController.m
//  Tempest
//
//  Created by Ian White on 6/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EMTLUserPhotoListViewController.h"
#import "EMTLUser.h"

@interface EMTLUserPhotoListViewController ()

@end

@implementation EMTLUserPhotoListViewController

- (id)initWithPhotoQuery:(EMTLPhotoQuery *)query user:(EMTLUser *)user
{
    self = [super initWithPhotoQuery:query];
    if (self) {
        _user = user;
    }
    
    return self;
}

- (void)loadView
{
    
    [super loadView];
    
    _tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 148)];
    
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 30, 300, 113)];
    label.text = [NSString stringWithFormat:@"Photos for %@", _user.username];
    label.font = [UIFont fontWithName:@"MarkerSD" size:20];
    [_tableHeaderView addSubview:label];
    
    _reloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_reloadButton setImage:[UIImage imageNamed:@"Reload.png"] forState:UIControlStateNormal];
    _reloadButton.frame = CGRectMake(238, 72, 35, 35);
    _reloadButton.alpha = 0.8;
    [_reloadButton addTarget:self action:@selector(reloadQuery) forControlEvents:UIControlEventTouchUpInside];
    [_tableHeaderView addSubview:_reloadButton];
    
    _tableView.tableHeaderView = _tableHeaderView;
    
}

@end
