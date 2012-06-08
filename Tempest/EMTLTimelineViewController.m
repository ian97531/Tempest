//
//  EMTLPhotoListViewController.m
//  Flickrgram
//
//  Created by Ian White on 4/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EMTLTimelineViewController.h"
#import "EMTLPhotoCell.h"
#import "EMTLPhoto.h"
#import "EMTLLocation.h"
#import "EMTLUser.h"
#import "EMTLMagicUserList.h"

#import "Math.h"

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>


@implementation EMTLTimelineViewController


- (id)initWithPhotoQuery:(EMTLPhotoQuery *)query;
{
    self = [super initWithPhotoQuery:query];
    if (self != nil)
    {
        

    }
    
    return self;
}


// Load our special header.
- (void)loadView
{
    
    [super loadView];
    
    _tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 148)];
    
    UIImageView *headerImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LabelTempest2.png"]];
    headerImage.frame = CGRectMake(10, 30, 300, 113);
    [_tableHeaderView addSubview:headerImage];
    
    _reloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_reloadButton setImage:[UIImage imageNamed:@"Reload.png"] forState:UIControlStateNormal];
    _reloadButton.frame = CGRectMake(238, 72, 35, 35);
    _reloadButton.alpha = 0.8;
    [_reloadButton addTarget:self action:@selector(reloadQuery) forControlEvents:UIControlEventTouchUpInside];
    [_tableHeaderView addSubview:_reloadButton];
    
    _tableView.tableHeaderView = _tableHeaderView;
    
}


- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBar.hidden = YES;
}












@end
